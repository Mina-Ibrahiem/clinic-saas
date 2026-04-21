<?php

namespace Tests\Feature\Api;

use App\Models\Patient;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class PatientsApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed();
    }

    public function test_admin_can_list_patients_with_filters_and_pagination(): void
    {
        $patient = Patient::query()->firstOrFail();
        $headers = $this->authHeaders('admin@clinic.test', 'password');

        $response = $this->getJson('/api/patients?search='.$patient->patient_code.'&per_page=5&sort=full_name', $headers);

        $response->assertOk()
            ->assertJson([
                'success' => true,
                'message' => 'Patients fetched successfully.',
            ])
            ->assertJsonPath('data.pagination.per_page', 5)
            ->assertJsonPath('data.items.0.patient_code', $patient->patient_code);
    }

    public function test_clinic_owner_can_create_update_and_delete_patient(): void
    {
        $headers = $this->authHeaders('owner@clinic.test', 'password');
        $ownerProfile = $this->getJson('/api/auth/me', $headers)->json('data');

        $createPayload = [
            'full_name' => 'Mina Saleh',
            'gender' => 'male',
            'date_of_birth' => '1994-03-18',
            'phone' => '+971501234567',
            'email' => 'mina.saleh@example.com',
            'status' => 'active',
            'branch_id' => $ownerProfile['branch']['id'],
            'address' => 'Abu Dhabi, UAE',
        ];

        $create = $this->postJson('/api/patients', $createPayload, $headers);
        $create->assertCreated()
            ->assertJsonPath('data.full_name', 'Mina Saleh')
            ->assertJsonPath('data.branch_id', $ownerProfile['branch']['id']);

        $patientId = $create->json('data.id');

        $update = $this->putJson('/api/patients/'.$patientId, [
            'phone' => '+971509999999',
            'status' => 'inactive',
        ], $headers);

        $update->assertOk()
            ->assertJsonPath('data.phone', '+971509999999')
            ->assertJsonPath('data.status', 'inactive');

        $delete = $this->deleteJson('/api/patients/'.$patientId, [], $headers);
        $delete->assertOk()->assertJsonPath('success', true);

        $this->assertSoftDeleted('patients', ['id' => $patientId]);
    }

    public function test_doctor_cannot_create_patient(): void
    {
        $headers = $this->authHeaders('doctor@clinic.test', 'password');

        $response = $this->postJson('/api/patients', [
            'full_name' => 'Not Allowed',
            'phone' => '+971500000777',
        ], $headers);

        $response->assertForbidden();
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

        $token = $login->json('data.access_token');

        return [
            'Authorization' => 'Bearer '.$token,
            'Accept' => 'application/json',
        ];
    }
}
