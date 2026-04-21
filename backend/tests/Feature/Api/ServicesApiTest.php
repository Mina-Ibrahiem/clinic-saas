<?php

namespace Tests\Feature\Api;

use App\Enums\UserStatus;
use App\Models\Role;
use App\Models\Service;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class ServicesApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed();
    }

    public function test_admin_can_list_services_with_filters(): void
    {
        $headers = $this->authHeaders('admin@clinic.test', 'password');
        $service = Service::query()->firstOrFail();

        $response = $this->getJson(
            '/api/services?search='.urlencode($service->name).'&status=active&sort=price&per_page=5',
            $headers
        );

        $response->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.pagination.per_page', 5);
    }

    public function test_owner_can_create_update_and_delete_service(): void
    {
        $headers = $this->authHeaders('owner@clinic.test', 'password');
        $owner = $this->getJson('/api/auth/me', $headers)->json('data');

        $create = $this->postJson('/api/services', [
            'name' => 'Physiotherapy Session',
            'code' => 'PT-001',
            'description' => 'Seeded by test',
            'price' => 300,
            'duration_minutes' => 45,
            'status' => 'active',
            'branch_id' => $owner['branch']['id'],
        ], $headers);

        $create->assertCreated()
            ->assertJsonPath('data.code', 'PT-001');

        $id = (int) $create->json('data.id');

        $update = $this->putJson('/api/services/'.$id, [
            'price' => 320,
            'status' => 'inactive',
        ], $headers);

        $update->assertOk()
            ->assertJsonPath('data.price', '320.00')
            ->assertJsonPath('data.status', 'inactive');

        $delete = $this->deleteJson('/api/services/'.$id, [], $headers);
        $delete->assertOk()->assertJsonPath('success', true);
        $this->assertSoftDeleted('services', ['id' => $id]);
    }

    public function test_receptionist_can_read_services_but_cannot_create(): void
    {
        $ownerHeaders = $this->authHeaders('owner@clinic.test', 'password');
        $owner = $this->getJson('/api/auth/me', $ownerHeaders)->json('data');

        $receptionist = User::query()->create([
            'tenant_id' => $owner['tenant']['id'],
            'branch_id' => $owner['branch']['id'],
            'full_name' => 'Reception Agent',
            'email' => 'receptionist.module@test.local',
            'phone' => '+971500001111',
            'password' => Hash::make('password'),
            'status' => UserStatus::Active,
        ]);
        $receptionist->roles()->sync([Role::query()->where('slug', 'receptionist')->firstOrFail()->id]);

        $headers = $this->authHeaders('receptionist.module@test.local', 'password');

        $list = $this->getJson('/api/services', $headers);
        $list->assertOk()->assertJsonPath('success', true);

        $create = $this->postJson('/api/services', [
            'name' => 'Not Allowed Service',
            'price' => 100,
            'branch_id' => $owner['branch']['id'],
        ], $headers);

        $create->assertForbidden();
    }

    /**
     * @return array<string, string>
     */
    private function authHeaders(string $email, string $password): array
    {
        $login = $this->postJson('/api/auth/login', [
            'email' => $email,
            'password' => $password,
        ]);

        $login->assertOk();
        $token = (string) $login->json('data.access_token');

        return [
            'Authorization' => 'Bearer '.$token,
            'Accept' => 'application/json',
        ];
    }
}
