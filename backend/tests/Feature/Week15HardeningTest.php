<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class Week15HardeningTest extends TestCase
{
    use RefreshDatabase;

    private array $tokens = [];

    protected function setUp(): void
    {
        parent::setUp();

        foreach (['student', 'adviser', 'panel', 'coordinator'] as $index => $role) {
            DB::table('users')->insert([
                'id' => $index + 1,
                'name' => 'Week 15 '.$role,
                'email' => 'week15-'.$role.'@example.test',
                'password' => Hash::make('Week15-fixture-only!'),
                'role' => $role,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
            $this->tokens[$role] = $this->postJson('/api/login', [
                'email' => 'week15-'.$role.'@example.test',
                'password' => 'Week15-fixture-only!',
            ])->assertOk()->json('token');
        }
    }

    private function headers(string $role): array
    {
        return ['Authorization' => 'Bearer '.$this->tokens[$role]];
    }

    public function test_consultation_collection_has_bounded_pagination_contract(): void
    {
        for ($index = 1; $index <= 3; $index++) {
            DB::table('consultations')->insert([
                'student_id' => 1,
                'adviser_id' => 2,
                'panel_id' => 3,
                'agenda' => 'Controlled pagination record '.$index,
                'scheduled_at' => now()->addDays($index),
                'status' => 'requested',
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        $this->getJson('/api/consultations?per_page=2', $this->headers('student'))
            ->assertOk()
            ->assertJsonCount(2, 'data')
            ->assertJsonPath('pagination.per_page', 2)
            ->assertJsonPath('pagination.total', 3)
            ->assertJsonPath('pagination.has_more', true);

        $this->getJson('/api/consultations?per_page=0', $this->headers('student'))
            ->assertUnprocessable();
    }

    public function test_unauthorized_secure_receive_is_rejected_before_crypto_details(): void
    {
        $body = [
            'version' => 1,
            'key_id' => 'local-v1',
            'message_id' => '11111111-1111-4111-8111-111111111111',
            'issued_at' => now()->toIso8601String(),
            'expires_at' => now()->addMinutes(5)->toIso8601String(),
            'sender' => 'thesis-consultation-api',
            'recipient_user_id' => 3,
            'nonce' => 'invalid-but-structurally-bounded',
            'ciphertext' => 'invalid-but-structurally-bounded',
            'tag' => 'invalid-but-structurally-bounded',
        ];

        $this->postJson('/api/secure-exchange/receive', $body, $this->headers('panel'))
            ->assertForbidden()
            ->assertJsonPath('message', 'Assigned adviser required.');

        $this->assertDatabaseCount('secure_exchange_receipts', 0);
    }

    public function test_api_responses_include_browser_hardening_headers(): void
    {
        $this->withServerVariables(['HTTPS' => 'on'])
            ->getJson('/api/consultations', $this->headers('student'))
            ->assertOk()
            ->assertHeader('Content-Security-Policy', "default-src 'none'; frame-ancestors 'none'")
            ->assertHeader('Permissions-Policy', 'camera=(), microphone=(), geolocation=()')
            ->assertHeader('Strict-Transport-Security', 'max-age=31536000');
    }
}
