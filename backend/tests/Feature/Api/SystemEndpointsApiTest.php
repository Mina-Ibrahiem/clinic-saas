<?php

namespace Tests\Feature\Api;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class SystemEndpointsApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed();
    }

    public function test_health_and_meta_endpoints_are_available_and_safe(): void
    {
        $health = $this->getJson('/api/health');
        $health->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.status', 'ok')
            ->assertJsonPath('data.version', 'v1')
            ->assertJsonPath('errors', null);

        $meta = $this->getJson('/api/meta/app');
        $meta->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.api_version', 'v1')
            ->assertJsonPath('data.status', 'ok')
            ->assertJsonPath('errors', null);
    }

    public function test_unauthenticated_response_uses_standard_error_shape(): void
    {
        $response = $this->getJson('/api/patients');
        $response->assertUnauthorized()
            ->assertJsonPath('success', false)
            ->assertJsonPath('data', null)
            ->assertJsonPath('errors', null);
    }
}
