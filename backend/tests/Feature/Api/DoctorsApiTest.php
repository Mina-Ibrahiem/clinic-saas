<?php

namespace Tests\Feature\Api;

use App\Enums\AppointmentStatus;
use App\Enums\UserStatus;
use App\Models\Appointment;
use App\Models\Branch;
use App\Models\Doctor;
use App\Models\Patient;
use App\Models\Role;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class DoctorsApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed();
    }

    public function test_admin_can_list_doctors_with_filters_and_pagination(): void
    {
        $headers = $this->authHeaders('admin@clinic.test', 'password');
        $doctor = Doctor::query()->firstOrFail();

        $response = $this->getJson(
            '/api/doctors?search='.urlencode((string) $doctor->doctor_code).'&status=active&sort=full_name&per_page=5',
            $headers
        );

        $response->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.pagination.per_page', 5);
    }

    public function test_owner_can_create_update_and_delete_doctor_without_appointments(): void
    {
        $headers = $this->authHeaders('owner@clinic.test', 'password');
        $context = $this->getJson('/api/auth/me', $headers)->json('data');
        $tenantId = (int) $context['tenant']['id'];
        $branchId = (int) $context['branch']['id'];

        $linkedUser = User::query()->create([
            'tenant_id' => $tenantId,
            'branch_id' => $branchId,
            'full_name' => 'Dr. Linked Profile',
            'email' => 'linked.doctor@test.local',
            'phone' => '+971500007001',
            'password' => Hash::make('password'),
            'status' => UserStatus::Active,
        ]);

        $create = $this->postJson('/api/doctors', [
            'user_id' => $linkedUser->id,
            'doctor_code' => 'DR-TST-001',
            'full_name' => 'Dr. Test Owner',
            'specialization' => 'Neurology',
            'license_number' => 'DHA-NEU-990011',
            'consultation_fee' => 420,
            'bio' => 'Owner test doctor profile',
            'status' => 'active',
            'branch_id' => $branchId,
        ], $headers);

        $create->assertCreated()
            ->assertJsonPath('data.doctor_code', 'DR-TST-001')
            ->assertJsonPath('data.user.id', $linkedUser->id);

        $doctorId = (int) $create->json('data.id');

        $update = $this->putJson('/api/doctors/'.$doctorId, [
            'specialization' => 'Cardiology',
            'consultation_fee' => 480,
            'status' => 'on_leave',
        ], $headers);

        $update->assertOk()
            ->assertJsonPath('data.specialization', 'Cardiology')
            ->assertJsonPath('data.consultation_fee', '480.00')
            ->assertJsonPath('data.status', 'on_leave');

        $delete = $this->deleteJson('/api/doctors/'.$doctorId, [], $headers);
        $delete->assertOk()->assertJsonPath('success', true);
        $this->assertSoftDeleted('doctors', ['id' => $doctorId]);
    }

    public function test_delete_doctor_with_appointments_is_blocked(): void
    {
        $headers = $this->authHeaders('owner@clinic.test', 'password');
        $doctor = Doctor::query()->firstOrFail();
        $patient = Patient::query()
            ->where('tenant_id', $doctor->tenant_id)
            ->where('branch_id', $doctor->branch_id)
            ->firstOrFail();

        Appointment::query()->create([
            'tenant_id' => $doctor->tenant_id,
            'branch_id' => $doctor->branch_id,
            'patient_id' => $patient->id,
            'doctor_id' => $doctor->id,
            'service_id' => null,
            'appointment_date' => now()->addDays(5)->toDateString(),
            'start_time' => '11:00:00',
            'end_time' => '11:30:00',
            'status' => AppointmentStatus::Booked,
            'notes' => 'Delete safety test',
            'created_by' => User::query()->where('email', 'owner@clinic.test')->firstOrFail()->id,
        ]);

        $delete = $this->deleteJson('/api/doctors/'.$doctor->id, [], $headers);
        $delete->assertStatus(422)
            ->assertJsonPath('message', 'Cannot delete doctor with linked appointments.');
    }

    public function test_receptionist_can_read_doctors_but_cannot_manage(): void
    {
        $ownerHeaders = $this->authHeaders('owner@clinic.test', 'password');
        $context = $this->getJson('/api/auth/me', $ownerHeaders)->json('data');

        $receptionist = User::query()->create([
            'tenant_id' => $context['tenant']['id'],
            'branch_id' => $context['branch']['id'],
            'full_name' => 'Reception Doctors',
            'email' => 'reception.doctors@test.local',
            'phone' => '+971500008001',
            'password' => Hash::make('password'),
            'status' => UserStatus::Active,
        ]);
        $receptionist->roles()->sync([Role::query()->where('slug', 'receptionist')->firstOrFail()->id]);

        $headers = $this->authHeaders('reception.doctors@test.local', 'password');

        $list = $this->getJson('/api/doctors', $headers);
        $list->assertOk()->assertJsonPath('success', true);

        $create = $this->postJson('/api/doctors', [
            'full_name' => 'Not Allowed Doctor',
            'specialization' => 'Internal Medicine',
        ], $headers);
        $create->assertForbidden();
    }

    public function test_doctor_can_only_view_own_profile_not_others(): void
    {
        $headers = $this->authHeaders('doctor@clinic.test', 'password');
        $doctor = Doctor::query()->whereHas('user', fn ($q) => $q->where('email', 'doctor@clinic.test'))->firstOrFail();
        $otherDoctor = Doctor::query()->whereKeyNot($doctor->id)->firstOrFail();

        $own = $this->getJson('/api/doctors/'.$doctor->id, $headers);
        $own->assertOk()->assertJsonPath('data.id', $doctor->id);

        $other = $this->getJson('/api/doctors/'.$otherDoctor->id, $headers);
        $other->assertForbidden();
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
