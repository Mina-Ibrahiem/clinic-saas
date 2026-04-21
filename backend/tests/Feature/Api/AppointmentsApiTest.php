<?php

namespace Tests\Feature\Api;

use App\Models\Appointment;
use App\Models\Doctor;
use App\Models\Patient;
use App\Models\Service;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AppointmentsApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed();
    }

    public function test_admin_can_list_appointments_with_filters_and_pagination(): void
    {
        $headers = $this->authHeaders('admin@clinic.test', 'password');
        $appointment = Appointment::query()->firstOrFail();

        $response = $this->getJson(
            sprintf(
                '/api/appointments?doctor_id=%d&appointment_date=%s&per_page=5&sort=appointment_date',
                $appointment->doctor_id,
                $appointment->appointment_date?->toDateString()
            ),
            $headers
        );

        $response->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.pagination.per_page', 5)
            ->assertJsonPath('data.items.0.doctor_id', $appointment->doctor_id);
    }

    public function test_owner_can_create_appointment_and_overlap_is_blocked(): void
    {
        $headers = $this->authHeaders('owner@clinic.test', 'password');
        $ownerProfile = $this->getJson('/api/auth/me', $headers)->json('data');
        $branchId = (int) $ownerProfile['branch']['id'];
        $tenantId = (int) $ownerProfile['tenant']['id'];

        $doctor = Doctor::query()
            ->where('tenant_id', $tenantId)
            ->where('branch_id', $branchId)
            ->firstOrFail();

        $patient = Patient::query()
            ->where('tenant_id', $tenantId)
            ->where('branch_id', $branchId)
            ->firstOrFail();

        $service = Service::query()
            ->where('tenant_id', $tenantId)
            ->where('branch_id', $branchId)
            ->firstOrFail();

        $payload = [
            'doctor_id' => $doctor->id,
            'patient_id' => $patient->id,
            'service_id' => $service->id,
            'appointment_date' => '2030-01-15',
            'start_time' => '10:00',
            'end_time' => '11:00',
            'status' => 'booked',
            'branch_id' => $branchId,
            'notes' => 'Initial booking',
        ];

        $create = $this->postJson('/api/appointments', $payload, $headers);
        $create->assertCreated()
            ->assertJsonPath('data.doctor_id', $doctor->id)
            ->assertJsonPath('data.patient_id', $patient->id);

        $overlap = $this->postJson('/api/appointments', [
            ...$payload,
            'start_time' => '10:30',
            'end_time' => '11:15',
        ], $headers);

        $overlap->assertStatus(422)
            ->assertJsonPath('success', false)
            ->assertJsonPath('message', 'Doctor already has an overlapping appointment in this time slot.');
    }

    public function test_doctor_cannot_create_appointment(): void
    {
        $headers = $this->authHeaders('doctor@clinic.test', 'password');
        $doctorProfile = $this->getJson('/api/auth/me', $headers)->json('data');

        $branchId = (int) $doctorProfile['branch']['id'];
        $tenantId = (int) $doctorProfile['tenant']['id'];
        $doctorId = (int) Doctor::query()->where('tenant_id', $tenantId)->where('branch_id', $branchId)->firstOrFail()->id;

        $patient = Patient::query()->where('tenant_id', $tenantId)->where('branch_id', $branchId)->firstOrFail();
        $service = Service::query()->where('tenant_id', $tenantId)->where('branch_id', $branchId)->firstOrFail();

        $response = $this->postJson('/api/appointments', [
            'doctor_id' => $doctorId,
            'patient_id' => $patient->id,
            'service_id' => $service->id,
            'appointment_date' => '2030-02-01',
            'start_time' => '09:00',
            'end_time' => '09:30',
            'branch_id' => $branchId,
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
        $token = (string) $login->json('data.access_token');

        return [
            'Authorization' => 'Bearer '.$token,
            'Accept' => 'application/json',
        ];
    }
}
