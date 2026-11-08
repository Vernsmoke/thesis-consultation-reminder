<?php

namespace App\Http\Controllers;

use App\Services\Audit;
use App\Services\SecureExchange;
use Carbon\Carbon;
use Illuminate\Database\QueryException;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Symfony\Component\HttpKernel\Exception\HttpException;

class ConsultationController extends Controller
{
    private function actor(Request $r)
    {
        return $r->attributes->get('actor');
    }

    private function cid(Request $r): string
    {
        return $r->attributes->get('correlation_id');
    }

    public function login(Request $r)
    {
        $v = $r->validate(['email' => 'required|email|max:100', 'password' => 'required|string|max:128']);
        $u = DB::table('users')->where('email', $v['email'])->first();
        abort_unless($u && Hash::check($v['password'], $u->password), 401, 'Invalid sign-in details.');
        $token = Str::random(64);
        DB::table('api_sessions')->insert(['user_id' => $u->id, 'token_hash' => hash('sha256', $token), 'expires_at' => now()->addHours(2)]);

        return ['token' => $token, 'user' => ['id' => $u->id, 'name' => $u->name, 'role' => $u->role]];
    }

    public function logout(Request $r)
    {
        DB::table('api_sessions')->where('token_hash', hash('sha256', $r->bearerToken()))->delete();

        return ['message' => 'Signed out.'];
    }

    private function visible(Request $r)
    {
        $u = $this->actor($r);
        $q = DB::table('consultations');
        if ($u->role === 'student') {
            $q->where('student_id', $u->id);
        } elseif ($u->role === 'adviser') {
            $q->where('adviser_id', $u->id);
        } elseif ($u->role === 'panel') {
            $q->where('panel_id', $u->id);
        } elseif ($u->role !== 'coordinator') {
            abort(403);
        }

        return $q;
    }

    private function item(Request $r, int $id)
    {
        abort_unless(DB::table('consultations')->where('id', $id)->exists(), 404, 'Consultation not found.');
        $c = $this->visible($r)->where('id', $id)->first();
        abort_unless($c, 403, 'This consultation is outside your assignment.');

        return $c;
    }

    public function index(Request $r)
    {
        return ['data' => $this->visible($r)->orderByDesc('id')->limit(100)->get()->map(function ($c) {
            $c->action_items = DB::table('action_items')->where('consultation_id', $c->id)->get();

            return $c;
        }), 'directory' => DB::table('users')->whereIn('role', ['adviser', 'panel'])->get(['id', 'name', 'role']),
            'notifications' => DB::table('notification_receipts')->where('recipient_id', $this->actor($r)->id)->orderByDesc('id')->limit(50)->get()->map(function ($n) {
                $n->payload = json_decode($n->payload, true);

                return $n;
            })];
    }

    public function store(Request $r)
    {
        $u = $this->actor($r);
        abort_unless($u->role === 'student', 403, 'Only students request consultations.');
        $v = $r->validate(['agenda' => 'required|string|min:5|max:1000', 'scheduled_at' => 'required|date_format:Y-m-d\TH:i:s\Z|after:now',
            'adviser_id' => 'required|integer|exists:users,id', 'panel_id' => 'nullable|integer|exists:users,id']);
        abort_unless(DB::table('users')->where('id', $v['adviser_id'])->where('role', 'adviser')->exists(), 422, 'Choose an adviser.');
        if (isset($v['panel_id'])) {
            abort_unless(DB::table('users')->where('id', $v['panel_id'])->where('role', 'panel')->exists(), 422, 'Choose a panel member.');
        }
        $key = $r->header('Idempotency-Key', '');
        abort_unless(preg_match('/^[A-Za-z0-9_-]{8,80}$/', $key), 422, 'Provide an 8–80 character idempotency key.');
        $hash = hash('sha256', json_encode($v));

        // User row serializes concurrent creation and key replay on MySQL as well as the unique index.
        return DB::transaction(function () use ($r, $u, $v, $key, $hash) {
            DB::table('users')->where('id', $u->id)->lockForUpdate()->first();
            $old = DB::table('idempotency_keys')->where('user_id', $u->id)->where('request_key', $key)->first();
            if ($old) {
                abort_unless($old->payload_hash === $hash, 409, 'Idempotency key already used with different input.');

                return response()->json(['id' => $old->consultation_id, 'replayed' => true]);
            }
            $id = DB::table('consultations')->insertGetId(['student_id' => $u->id, 'adviser_id' => $v['adviser_id'], 'panel_id' => $v['panel_id'] ?? null,
                'agenda' => $v['agenda'], 'scheduled_at' => Carbon::parse($v['scheduled_at'])->utc(), 'status' => 'requested', 'created_at' => now(), 'updated_at' => now()]);
            DB::table('idempotency_keys')->insert(['user_id' => $u->id, 'request_key' => $key, 'payload_hash' => $hash, 'consultation_id' => $id]);
            Audit::record('consultation.requested', $id, $this->cid($r), [], $u->id);

            return response()->json(['id' => $id, 'message' => 'Request saved. Awaiting adviser confirmation.'], 201);
        });
    }

    public function transition(Request $r, int $id)
    {
        $v = $r->validate(['status' => 'required|in:confirmed,completed,cancelled']);
        $u = $this->actor($r);
        $this->item($r, $id);
        abort_unless(in_array($u->role, ['adviser', 'coordinator']), 403, 'Adviser or coordinator required.');

        return DB::transaction(function () use ($r, $id, $u, $v) {
            $c = DB::table('consultations')->where('id', $id)->lockForUpdate()->first();
            $allowed = ['requested' => ['confirmed', 'cancelled'], 'confirmed' => ['completed', 'cancelled'], 'missed' => ['completed', 'cancelled']];
            abort_unless(in_array($v['status'], $allowed[$c->status] ?? []), 409, 'Invalid meeting transition.');
            if ($v['status'] === 'confirmed') {
                abort_unless($c->scheduled_at > now()->toDateTimeString(), 409, 'A past schedule cannot be confirmed.');
            }
            DB::table('consultations')->where('id', $id)->update(['status' => $v['status'], 'updated_at' => now()]);
            Audit::record('consultation.'.$v['status'], $id, $this->cid($r), ['previous' => $c->status], $u->id);

            return ['message' => 'Meeting status updated.'];
        });
    }

    public function addAction(Request $r, int $id)
    {
        $c = $this->item($r, $id);
        $u = $this->actor($r);
        abort_unless(in_array($u->role, ['adviser', 'coordinator']), 403, 'Adviser or coordinator required.');
        abort_unless(in_array($c->status, ['confirmed', 'completed', 'missed']), 409, 'Confirm the consultation first.');
        $v = $r->validate(['description' => 'required|string|min:5|max:500', 'due_at' => 'required|date_format:Y-m-d\TH:i:s\Z|after:now']);
        $aid = DB::table('action_items')->insertGetId(['consultation_id' => $id, 'description' => $v['description'], 'due_at' => Carbon::parse($v['due_at'])->utc(), 'status' => 'open', 'created_at' => now(), 'updated_at' => now()]);
        Audit::record('action.created', $aid, $this->cid($r), [], $u->id);

        return response()->json(['id' => $aid], 201);
    }

    public function completeAction(Request $r, int $id)
    {
        $a = DB::table('action_items')->find($id);
        abort_unless($a, 404, 'Action item not found.');
        $c = $this->item($r, $a->consultation_id);
        $u = $this->actor($r);
        abort_unless($u->id === $c->student_id || $u->role === 'coordinator', 403, 'Student owner or coordinator required.');
        DB::table('action_items')->where('id', $id)->update(['status' => 'done', 'updated_at' => now()]);
        Audit::record('action.completed', $id, $this->cid($r), [], $u->id);

        return ['message' => 'Action item completed.'];
    }

    public function automation(Request $r)
    {
        abort_unless($this->actor($r)->role === 'coordinator', 403, 'Coordinator required.');

        return ['data' => DB::table('outbox')->orderByDesc('id')->limit(100)->get(), 'metrics' => [
            'pending' => DB::table('outbox')->whereIn('status', ['pending', 'retry'])->count(),
            'manual_review' => DB::table('outbox')->where('status', 'manual_review')->count(),
            'delivered' => DB::table('notification_receipts')->count(), 'attempts' => (int) DB::table('outbox')->sum('attempts')]];
    }

    public function resolve(Request $r, int $id)
    {
        abort_unless($this->actor($r)->role === 'coordinator', 403, 'Coordinator required.');
        $v = $r->validate(['resolution' => 'required|string|min:10|max:500']);

        return DB::transaction(function () use ($r, $id, $v) {
            $o = DB::table('outbox')->where('id', $id)->lockForUpdate()->first();
            abort_unless($o, 404);
            abort_unless($o->status === 'manual_review', 409, 'Only manual-review items can be resolved.');
            DB::table('outbox')->where('id', $id)->update(['status' => 'resolved', 'resolution' => $v['resolution'], 'updated_at' => now()]);
            Audit::record('outbox.resolved', $id, $this->cid($r), [], $this->actor($r)->id);

            return ['message' => 'Human handling recorded. No automatic resend.'];
        });
    }

    public function createEnvelope(Request $r, SecureExchange $exchange)
    {
        $actor = $this->actor($r);
        abort_unless($actor->role === 'coordinator', 403, 'Coordinator required.');
        $validated = $r->validate(['consultation_id' => 'required|integer|exists:consultations,id']);
        $consultation = DB::table('consultations')->find($validated['consultation_id']);
        $openActions = DB::table('action_items')->where('consultation_id', $consultation->id)->where('status', 'open')->count();
        try {
            $envelope = $exchange->create([
                'record_type' => 'consultation_summary',
                'consultation_id' => $consultation->id,
                'agenda' => $consultation->agenda,
                'scheduled_at' => Carbon::parse($consultation->scheduled_at)->utc()->format('Y-m-d\TH:i:s\Z'),
                'status' => $consultation->status,
                'open_action_count' => $openActions,
            ], $consultation->adviser_id);
        } catch (HttpException $exception) {
            Audit::record('secure_exchange.unavailable', $consultation->id, $this->cid($r), ['reason' => 'key_or_cipher_unavailable'], $actor->id);
            throw $exception;
        }
        Audit::record('secure_exchange.created', $consultation->id, $this->cid($r), [
            'message_id' => $envelope['message_id'],
            'key_id' => $envelope['key_id'],
            'recipient_user_id' => $consultation->adviser_id,
        ], $actor->id);

        return response()->json(['envelope' => $envelope], 201);
    }

    public function receiveEnvelope(Request $r, SecureExchange $exchange)
    {
        $envelope = $r->validate([
            'version' => 'required|integer|in:1',
            'key_id' => 'required|string|max:40',
            'message_id' => 'required|uuid',
            'issued_at' => 'required|string|max:30',
            'expires_at' => 'required|string|max:30',
            'sender' => 'required|string|max:80',
            'recipient_user_id' => 'required|integer|min:1',
            'nonce' => 'required|string|max:64',
            'ciphertext' => 'required|string|max:8192',
            'tag' => 'required|string|max:64',
        ]);
        $actor = $this->actor($r);
        try {
            $payload = $exchange->open($envelope);
        } catch (HttpException $exception) {
            Audit::record('secure_exchange.rejected', null, $this->cid($r), ['reason' => match ($exception->getStatusCode()) {
                503 => 'key_unavailable',
                default => 'invalid_or_unauthenticated_envelope',
            }], $actor->id);
            throw $exception;
        }
        abort_unless($actor->role === 'adviser' && $actor->id === (int) $envelope['recipient_user_id'], 403, 'Assigned adviser required.');
        abort_unless(($payload['record_type'] ?? null) === 'consultation_summary' && is_int($payload['consultation_id'] ?? null), 422, 'Envelope payload is invalid.');
        $consultation = DB::table('consultations')->find($payload['consultation_id']);
        abort_unless($consultation && $consultation->adviser_id === $actor->id, 403, 'This consultation is outside your assignment.');

        try {
            DB::transaction(function () use ($envelope, $payload, $actor) {
                DB::table('secure_exchange_receipts')->insert([
                    'message_id' => $envelope['message_id'],
                    'key_id' => $envelope['key_id'],
                    'recipient_user_id' => $actor->id,
                    'consultation_id' => $payload['consultation_id'],
                    'payload_hash' => hash('sha256', json_encode($payload, JSON_UNESCAPED_SLASHES | JSON_THROW_ON_ERROR)),
                    'accepted_at' => now(),
                ]);
            });
        } catch (QueryException $exception) {
            if ((string) $exception->getCode() === '23000') {
                Audit::record('secure_exchange.replay_rejected', $payload['consultation_id'], $this->cid($r), ['message_id' => $envelope['message_id']], $actor->id);
                abort(409, 'Envelope was already accepted.');
            }
            throw $exception;
        }
        Audit::record('secure_exchange.accepted', $payload['consultation_id'], $this->cid($r), ['message_id' => $envelope['message_id'], 'key_id' => $envelope['key_id']], $actor->id);

        return ['message' => 'Secure consultation record accepted.', 'record' => $payload];
    }
}
