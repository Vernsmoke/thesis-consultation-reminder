<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use Tests\TestCase;

class SecureExchangeTest extends TestCase
{
    use RefreshDatabase;

    private array $tokens = [];

    private int $consultationId;

    protected function setUp(): void
    {
        parent::setUp();
        config([
            'secure_exchange.active_key_id' => 'test-v1',
            'secure_exchange.keys.test-v1' => base64_encode(str_repeat('K', 32)),
            'secure_exchange.keyring_file' => storage_path('framework/testing/nonexistent-secure-exchange-keyring.json'),
            'secure_exchange.ttl_seconds' => 300,
        ]);
        foreach (['student', 'adviser', 'panel', 'coordinator', 'otheradviser'] as $index => $role) {
            $actualRole = $role === 'otheradviser' ? 'adviser' : $role;
            DB::table('users')->insert([
                'id' => $index + 1,
                'name' => 'Fictional '.$role,
                'email' => $role.'@example.test',
                'password' => Hash::make('Test-only-fixture!'),
                'role' => $actualRole,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
            $this->tokens[$role] = $this->postJson('/api/login', [
                'email' => $role.'@example.test',
                'password' => 'Test-only-fixture!',
            ])->assertOk()->json('token');
        }
        $this->consultationId = DB::table('consultations')->insertGetId([
            'student_id' => 1,
            'adviser_id' => 2,
            'panel_id' => 3,
            'agenda' => 'Controlled fictional security review',
            'scheduled_at' => now()->addDay(),
            'status' => 'confirmed',
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    private function headers(string $role): array
    {
        return ['Authorization' => 'Bearer '.$this->tokens[$role]];
    }

    private function envelope(): array
    {
        return $this->postJson('/api/secure-exchange/envelopes', [
            'consultation_id' => $this->consultationId,
        ], $this->headers('coordinator'))->assertCreated()->json('envelope');
    }

    public function test_authenticated_envelope_is_accepted_once_by_assigned_adviser(): void
    {
        $envelope = $this->envelope();
        $this->assertSame(1, $envelope['version']);
        $this->assertSame(2, $envelope['recipient_user_id']);
        $this->assertArrayNotHasKey('agenda', $envelope);
        $this->postJson('/api/secure-exchange/receive', $envelope, $this->headers('adviser'))
            ->assertOk()
            ->assertJsonPath('record.consultation_id', $this->consultationId)
            ->assertJsonPath('record.agenda', 'Controlled fictional security review');
        $this->assertDatabaseCount('secure_exchange_receipts', 1);
        $this->postJson('/api/secure-exchange/receive', $envelope, $this->headers('adviser'))
            ->assertConflict()
            ->assertJsonPath('message', 'Envelope was already accepted.');
        $this->assertDatabaseCount('secure_exchange_receipts', 1);
    }

    public function test_altered_ciphertext_and_metadata_are_rejected_without_receipt(): void
    {
        $ciphertext = $this->envelope();
        $ciphertext['ciphertext'][4] = $ciphertext['ciphertext'][4] === 'A' ? 'B' : 'A';
        $this->postJson('/api/secure-exchange/receive', $ciphertext, $this->headers('adviser'))
            ->assertUnprocessable()
            ->assertJsonPath('message', 'Envelope authentication failed.');

        $metadata = $this->envelope();
        $metadata['recipient_user_id'] = 5;
        $this->postJson('/api/secure-exchange/receive', $metadata, $this->headers('otheradviser'))
            ->assertUnprocessable()
            ->assertJsonPath('message', 'Envelope authentication failed.');
        $this->assertDatabaseCount('secure_exchange_receipts', 0);
    }

    public function test_expired_envelope_is_rejected_without_decryption_or_receipt(): void
    {
        $envelope = $this->envelope();
        $this->travel(6)->minutes();
        $this->postJson('/api/secure-exchange/receive', $envelope, $this->headers('adviser'))
            ->assertUnprocessable()
            ->assertJsonPath('message', 'Envelope is expired or has an invalid validity window.');
        $this->assertDatabaseCount('secure_exchange_receipts', 0);
    }

    public function test_invalid_and_unauthorized_requests_fail_safely(): void
    {
        $this->postJson('/api/secure-exchange/receive', [], $this->headers('adviser'))->assertUnprocessable();
        $this->postJson('/api/secure-exchange/envelopes', ['consultation_id' => $this->consultationId], $this->headers('student'))->assertForbidden();
        $envelope = $this->envelope();
        $this->postJson('/api/secure-exchange/receive', $envelope, $this->headers('panel'))->assertForbidden();
        $this->postJson('/api/secure-exchange/receive', $envelope, $this->headers('otheradviser'))->assertForbidden();
        $this->assertDatabaseCount('secure_exchange_receipts', 0);
    }

    public function test_wrong_key_and_missing_key_fail_then_configuration_recovers(): void
    {
        $envelope = $this->envelope();
        config(['secure_exchange.keys.test-v1' => base64_encode(str_repeat('W', 32))]);
        $this->postJson('/api/secure-exchange/receive', $envelope, $this->headers('adviser'))
            ->assertUnprocessable()
            ->assertJsonPath('message', 'Envelope authentication failed.');

        config(['secure_exchange.keys.test-v1' => null]);
        $this->postJson('/api/secure-exchange/envelopes', ['consultation_id' => $this->consultationId], $this->headers('coordinator'))
            ->assertStatus(503)
            ->assertJsonPath('message', 'Service unavailable. Retry safely or contact the coordinator.');

        config(['secure_exchange.keys.test-v1' => base64_encode(str_repeat('K', 32))]);
        $recovered = $this->envelope();
        $this->postJson('/api/secure-exchange/receive', $recovered, $this->headers('adviser'))->assertOk();
        $this->assertDatabaseCount('secure_exchange_receipts', 1);
    }

    public function test_security_logs_exclude_ciphertext_and_key_material(): void
    {
        Log::shouldReceive('info')->once()->withArgs(function ($message, $context) {
            $encoded = json_encode($context);

            return $message === 'workflow'
                && ($context['event'] ?? null) === 'secure_exchange.created'
                && ! str_contains($encoded, 'ciphertext')
                && ! str_contains($encoded, (string) config('secure_exchange.keys.test-v1'));
        });
        $this->envelope();
    }
}
