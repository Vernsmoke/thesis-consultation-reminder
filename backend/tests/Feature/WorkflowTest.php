<?php

namespace Tests\Feature;

use App\Services\Automation;
use App\Services\SimulatedTransport;
use Carbon\Carbon;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class WorkflowTest extends TestCase
{
    use RefreshDatabase;

    private array $tokens = [];

    protected function setUp(): void
    {
        parent::setUp();
        foreach (['student', 'adviser', 'panel', 'coordinator', 'otherstudent'] as $i => $role) {
            DB::table('users')->insert(['id' => $i + 1, 'name' => 'Fictional '.$role, 'email' => $role.'@example.test', 'password' => Hash::make('Test-only-fixture!'), 'role' => $role === 'otherstudent' ? 'student' : $role, 'created_at' => now(), 'updated_at' => now()]);
            $this->tokens[$role] = $this->postJson('/api/login', ['email' => $role.'@example.test', 'password' => 'Test-only-fixture!'])->assertOk()->json('token');
        }
    }

    private function headers(string $role = 'student', string $key = 'fixture_key_001'): array
    {
        return ['Authorization' => 'Bearer '.$this->tokens[$role], 'Idempotency-Key' => $key];
    }

    private function payload(): array
    {
        return ['agenda' => 'Review controlled research progress', 'scheduled_at' => now()->addHours(4)->format('Y-m-d\TH:i:s\Z'), 'adviser_id' => 2, 'panel_id' => 3];
    }

    private function create(): int
    {
        return $this->postJson('/api/consultations', $this->payload(), $this->headers())->assertCreated()->json('id');
    }

    public function test_complete_workflow_and_owner_follow_up(): void
    {
        $id = $this->create();
        $this->patchJson('/api/consultations/'.$id, ['status' => 'confirmed'], $this->headers('adviser'))->assertOk();
        $aid = $this->postJson("/api/consultations/$id/actions", ['description' => 'Revise interview questions', 'due_at' => now()->addDays(2)->format('Y-m-d\TH:i:s\Z')], $this->headers('adviser'))->assertCreated()->json('id');
        $this->patchJson("/api/actions/$aid/complete", [], $this->headers())->assertOk();
        $this->patchJson('/api/consultations/'.$id, ['status' => 'completed'], $this->headers('adviser'))->assertOk();
        $this->getJson('/api/consultations', $this->headers('panel'))->assertOk()->assertJsonPath('data.0.status', 'completed')->assertJsonPath('data.0.action_items.0.status', 'done');
    }

    public function test_invalid_missing_and_past_schedule(): void
    {
        $this->postJson('/api/consultations', [], $this->headers())->assertUnprocessable();
        $this->postJson('/api/consultations', array_merge($this->payload(), ['scheduled_at' => '2020-01-01T00:00:00Z']), $this->headers())->assertUnprocessable();
        $this->postJson('/api/consultations', array_merge($this->payload(), ['agenda' => str_repeat('x', 1001)]), $this->headers())->assertUnprocessable();
    }

    public function test_unauthenticated_expired_and_wrong_credentials(): void
    {
        $this->getJson('/api/consultations')->assertUnauthorized();
        DB::table('api_sessions')->update(['expires_at' => now()->subMinute()]);
        $this->getJson('/api/consultations', $this->headers())->assertUnauthorized();
        $this->postJson('/api/login', ['email' => 'student@example.test', 'password' => 'wrong'])->assertUnauthorized();
    }

    public function test_forbidden_roles_and_other_owner(): void
    {
        $id = $this->create();
        $this->patchJson("/api/consultations/$id", ['status' => 'confirmed'], $this->headers())->assertForbidden();
        $this->getJson('/api/consultations', $this->headers('otherstudent'))->assertJsonCount(0, 'data');
        $this->patchJson("/api/consultations/$id", ['status' => 'confirmed'], $this->headers('otherstudent'))->assertForbidden();
        $this->getJson('/api/automation', $this->headers('panel'))->assertForbidden();
    }

    public function test_duplicate_key_and_payload_conflict(): void
    {
        $payload = $this->payload();
        $first = $this->postJson('/api/consultations', $payload, $this->headers())->assertCreated()->json('id');
        $this->postJson('/api/consultations', $payload, $this->headers())->assertOk()->assertJsonPath('id', $first)->assertJsonPath('replayed', true);
        $payload['agenda'] = 'Changed agenda for conflict';
        $this->postJson('/api/consultations', $payload, $this->headers())->assertConflict();
        $this->assertDatabaseCount('consultations', 1);
    }

    public function test_missing_entity_invalid_transition_and_role_selection(): void
    {
        $this->patchJson('/api/consultations/999', ['status' => 'confirmed'], $this->headers('adviser'))->assertNotFound();
        $id = $this->create();
        $this->patchJson("/api/consultations/$id", ['status' => 'completed'], $this->headers('adviser'))->assertConflict();
        $this->postJson('/api/consultations', array_merge($this->payload(), ['adviser_id' => 1]), $this->headers('student', 'new_key_0002'))->assertUnprocessable();
    }

    private function event(string $mode): object
    {
        app(Automation::class)->enqueue('test:'.$mode, 'progress_summary', 1);
        DB::table('outbox')->where('event_key', 'test:'.$mode)->update(['simulation' => $mode]);

        return DB::table('outbox')->where('event_key', 'test:'.$mode)->first();
    }

    public function test_success_and_duplicate_worker_no_duplicate_receipt(): void
    {
        $o = $this->event('success');
        app(Automation::class)->work();
        app(Automation::class)->work();
        app(Automation::class)->enqueue('test:success', 'progress_summary', 1);
        $this->assertDatabaseCount('outbox', 1);
        $this->assertDatabaseCount('notification_receipts', 1);
        $this->assertDatabaseHas('outbox', ['id' => $o->id, 'attempts' => 1, 'status' => 'delivered']);
    }

    public function test_transient_failure_backoff_then_recovery(): void
    {
        $o = $this->event('transient');
        app(Automation::class)->work();
        $this->assertDatabaseHas('outbox', ['id' => $o->id, 'attempts' => 1, 'status' => 'retry']);
        $this->assertDatabaseCount('notification_receipts', 0);
        app(Automation::class)->work();
        $this->assertDatabaseHas('outbox', ['id' => $o->id, 'attempts' => 1]);
        $this->travel(76)->seconds();
        app(Automation::class)->work();
        $this->assertDatabaseHas('outbox', ['id' => $o->id, 'attempts' => 2, 'status' => 'delivered']);
        $this->assertDatabaseCount('notification_receipts', 1);
    }

    public function test_permanent_failure_manual_handling_without_resend(): void
    {
        $o = $this->event('permanent');
        app(Automation::class)->work();
        $this->assertDatabaseHas('outbox', ['id' => $o->id, 'attempts' => 1, 'status' => 'manual_review']);
        $this->postJson("/api/automation/$o->id/resolve", ['resolution' => 'Controlled manual follow-up recorded.'], $this->headers())->assertForbidden();
        $this->postJson("/api/automation/$o->id/resolve", ['resolution' => 'Controlled manual follow-up recorded.'], $this->headers('coordinator'))->assertOk();
        app(Automation::class)->work();
        $this->assertDatabaseCount('notification_receipts', 0);
        $this->assertDatabaseHas('outbox', ['id' => $o->id, 'attempts' => 1, 'status' => 'resolved']);
    }

    public function test_exhausted_timeout_stops_after_three_attempts(): void
    {
        $o = $this->event('timeout');
        for ($i = 0; $i < 5; $i++) {
            app(Automation::class)->work();
            $this->travel(6)->minutes();
        }
        $this->assertDatabaseHas('outbox', ['id' => $o->id, 'attempts' => 3, 'status' => 'manual_review']);
        $this->assertDatabaseCount('notification_receipts', 0);
    }

    public function test_scans_cover_four_automations_and_are_idempotent(): void
    {
        $this->travelTo(Carbon::parse('2030-01-01T10:00:00Z'));
        DB::table('api_sessions')->update(['expires_at' => now()->addHours(2)]);
        $id = $this->create();
        DB::table('consultations')->where('id', $id)->update(['status' => 'confirmed']);
        $past = DB::table('consultations')->insertGetId(['student_id' => 1, 'adviser_id' => 2, 'agenda' => 'Fictional missed session', 'scheduled_at' => now()->subHours(2), 'status' => 'confirmed', 'created_at' => now(), 'updated_at' => now()]);
        DB::table('action_items')->insert(['consultation_id' => $past, 'description' => 'Controlled overdue action', 'due_at' => now()->subMinute(), 'status' => 'open', 'created_at' => now(), 'updated_at' => now()]);
        app(Automation::class)->scan();
        $count = DB::table('outbox')->count();
        app(Automation::class)->scan();
        $this->assertDatabaseCount('outbox', $count);
        foreach (['consultation_reminder', 'missed_session', 'action_deadline', 'progress_summary'] as $kind) {
            $this->assertDatabaseHas('outbox', ['kind' => $kind]);
        }
        $this->assertDatabaseHas('consultations', ['id' => $past, 'status' => 'missed']);
        app(Automation::class)->work();
        $this->assertDatabaseCount('notification_receipts', $count);
        $summary = json_decode(DB::table('notification_receipts')->where('kind', 'progress_summary')->where('recipient_id', 1)->value('payload'), true);
        $this->assertSame(1, $summary['meetings_missed']);
        $this->assertSame(1, $summary['open_actions']);
        $this->getJson('/api/consultations', $this->headers())->assertJsonCount(4, 'notifications');
        $this->getJson('/api/consultations', $this->headers('otherstudent'))->assertJsonCount(1, 'notifications');
    }

    public function test_cancelled_reminder_is_superseded(): void
    {
        $id = $this->create();
        DB::table('consultations')->where('id', $id)->update(['status' => 'confirmed']);
        app(Automation::class)->scan();
        DB::table('consultations')->where('id', $id)->update(['status' => 'cancelled']);
        app(Automation::class)->work();
        $this->assertDatabaseHas('outbox', ['event_key' => "reminder:$id", 'status' => 'superseded', 'attempts' => 0]);
        $this->assertSame(0, DB::table('notification_receipts')->where('kind', 'consultation_reminder')->count());
    }

    public function test_transaction_rolls_back_receipt_if_delivery_crashes(): void
    {
        $o = $this->event('success');
        $mock = \Mockery::mock(SimulatedTransport::class);
        $mock->shouldReceive('deliver')->once()->andReturnUsing(function ($event) {
            DB::table('notification_receipts')->insert(['outbox_id' => $event->id, 'kind' => $event->kind, 'recipient_id' => 1, 'payload' => '{}', 'delivered_at' => now()]);
            throw new \RuntimeException('Controlled process crash');
        });
        try {
            (new Automation($mock))->work();
            $this->fail('Expected controlled crash');
        } catch (\RuntimeException $e) {
            $this->assertSame('Controlled process crash',$e->getMessage());
        }
        $this->assertDatabaseCount('notification_receipts',0);
        $this->assertDatabaseHas('outbox',['id' => $o->id, 'status' => 'pending', 'attempts' => 0]);
        app(Automation::class)->work();
        $this->assertDatabaseCount('notification_receipts',1);
    }
}
