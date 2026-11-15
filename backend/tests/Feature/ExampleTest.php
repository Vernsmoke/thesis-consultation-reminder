<?php

namespace Tests\Feature;

use Illuminate\Support\Facades\DB;
use Tests\TestCase;

class ExampleTest extends TestCase
{
    /**
     * A basic test example.
     */
    public function test_the_application_returns_a_successful_response(): void
    {
        $response = $this->get('/');

        $response->assertStatus(200);
    }

    public function test_liveness_endpoint_does_not_disclose_application_details(): void
    {
        $this->get('/up')
            ->assertOk();
    }

    public function test_readiness_endpoint_reports_database_dependency(): void
    {
        $this->getJson('/ready')
            ->assertOk()
            ->assertJsonPath('status', 'ready')
            ->assertJsonPath('checks.database', 'up')
            ->assertHeader('Cache-Control', 'no-store, private');
    }

    public function test_readiness_endpoint_fails_closed_without_database_details(): void
    {
        DB::shouldReceive('select')->once()->andThrow(new \RuntimeException('controlled dependency failure'));

        $response = $this->getJson('/ready')
            ->assertStatus(503)
            ->assertJsonPath('status', 'not_ready')
            ->assertJsonPath('checks.database', 'down');

        $response->assertJsonMissing(['exception' => 'controlled dependency failure']);
    }
}
