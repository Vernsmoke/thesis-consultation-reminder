<?php

namespace App\Services;

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class Automation
{
    public function __construct(private SimulatedTransport $transport) {}

    public function enqueue(string $key, string $kind, int $entity): void
    {
        DB::table('outbox')->insertOrIgnore(['event_key' => $key, 'kind' => $kind, 'entity_id' => $entity, 'status' => 'pending', 'attempts' => 0,
            'available_at' => now(), 'correlation_id' => (string) Str::uuid(), 'simulation' => 'success', 'created_at' => now(), 'updated_at' => now()]);
    }

    public function scan(): void
    {
        DB::transaction(function () {
            foreach (DB::table('consultations')->where('status', 'confirmed')->lockForUpdate()->get() as $c) {
                if ($c->scheduled_at <= now()->subMinutes(config('automation.missed_grace_minutes'))->toDateTimeString()) {
                    DB::table('consultations')->where('id', $c->id)->update(['status' => 'missed', 'updated_at' => now()]);
                    $this->enqueue("missed:$c->id", 'missed_session', $c->id);
                } elseif ($c->scheduled_at > now()->toDateTimeString() && $c->scheduled_at <= now()->addHours(config('automation.reminder_hours'))->toDateTimeString()) {
                    $this->enqueue("reminder:$c->id", 'consultation_reminder', $c->id);
                }
            }
            foreach (DB::table('action_items')->where('status', 'open')->where('due_at', '<=', now())->get() as $a) {
                $this->enqueue("deadline:$a->id", 'action_deadline', $a->id);
            }
            if (now()->timezone('Asia/Manila')->hour >= config('automation.summary_hour_manila')) {
                foreach (DB::table('users')->where('role', 'student')->get() as $u) {
                    $this->enqueue('summary:'.$u->id.':'.now()->timezone('Asia/Manila')->toDateString(), 'progress_summary', $u->id);
                }
            }
        }, 3);
    }

    public function work(): array
    {
        $started = microtime(true);
        $processed = 0;
        $transient = 0;
        $ids = DB::table('outbox')->whereIn('status', ['pending', 'retry'])->where('available_at', '<=', now())->orderBy('id')->limit(config('automation.batch_size'))->pluck('id');
        foreach ($ids as $id) {
            $result = DB::transaction(function () use ($id) {
                $o = DB::table('outbox')->where('id', $id)->lockForUpdate()->first();
                if (! in_array($o->status, ['pending', 'retry']) || $o->available_at > now()->toDateTimeString()) {
                    return 'skipped';
                }
                if (($o->kind === 'consultation_reminder' && ! DB::table('consultations')->where('id', $o->entity_id)->where('status', 'confirmed')->where('scheduled_at', '>', now())->exists())
                    || ($o->kind === 'action_deadline' && ! DB::table('action_items')->where('id', $o->entity_id)->where('status', 'open')->exists())) {
                    DB::table('outbox')->where('id', $id)->update(['status' => 'superseded', 'updated_at' => now()]);
                    Audit::record('outbox.superseded', $id, $o->correlation_id);

                    return 'superseded';
                }
                $attempt = $o->attempts + 1;
                $outcome = $this->transport->deliver($o, $attempt);
                $status = $outcome === 'success' ? 'delivered' : ($outcome === 'permanent' || $attempt >= config('automation.max_attempts') ? 'manual_review' : 'retry');
                $delay = config('automation.base_delay_seconds') * (2 ** ($attempt - 1)) + random_int(0, 15);
                DB::table('outbox')->where('id', $id)->update(['status' => $status, 'attempts' => $attempt,
                    'failure_code' => $outcome === 'success' ? null : ($outcome === 'permanent' ? 'recipient_invalid' : 'service_unavailable'),
                    'available_at' => now()->addSeconds($delay), 'updated_at' => now()]);
                Audit::record('outbox.'.$status, $id, $o->correlation_id, ['attempt' => $attempt, 'outcome' => $outcome, 'delay_seconds' => $status === 'retry' ? $delay : 0]);

                return $outcome;
            }, 3);
            if ($result !== 'skipped') {
                $processed++;
            }
            if ($result === 'transient' && ++$transient >= 3) {
                break;
            }
        }

        return ['processed' => $processed, 'transient_failures' => $transient, 'elapsed_ms' => round((microtime(true) - $started) * 1000, 2),
            'pending' => DB::table('outbox')->whereIn('status', ['pending', 'retry'])->count(), 'manual_review' => DB::table('outbox')->where('status','manual_review')->count()];
    }
}
