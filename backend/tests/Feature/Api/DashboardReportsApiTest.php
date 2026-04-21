<?php

namespace Tests\Feature\Api;

use App\Enums\AppointmentStatus;
use App\Enums\UserStatus;
use App\Models\Appointment;
use App\Models\Doctor;
use App\Models\Patient;
use App\Models\Role;
use App\Models\Service;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class DashboardReportsApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed();
    }

    public function test_receptionist_can_access_dashboard_overview(): void
    {
        $ownerHeaders = $this->authHeaders('owner@clinic.test', 'password');
        $context = $this->getJson('/api/auth/me', $ownerHeaders)->json('data');

        $receptionist = User::query()->create([
            'tenant_id' => $context['tenant']['id'],
            'branch_id' => $context['branch']['id'],
            'full_name' => 'Dashboard Reception',
            'email' => 'dashboard.reception@test.local',
            'phone' => '+971500090001',
            'password' => Hash::make('password'),
            'status' => UserStatus::Active,
        ]);
        $receptionist->roles()->sync([Role::query()->where('slug', 'receptionist')->firstOrFail()->id]);

        $headers = $this->authHeaders('dashboard.reception@test.local', 'password');
        $response = $this->getJson('/api/dashboard/overview', $headers);

        $response->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('message', 'Dashboard overview fetched successfully.');
    }

    public function test_doctor_cannot_access_dashboard_or_reports(): void
    {
        $headers = $this->authHeaders('doctor@clinic.test', 'password');

        $dashboard = $this->getJson('/api/dashboard/overview', $headers);
        $dashboard->assertForbidden();

        $report = $this->getJson('/api/reports/revenue', $headers);
        $report->assertForbidden();
    }

    public function test_revenue_report_returns_correct_totals_for_date_range(): void
    {
        $headers = $this->authHeaders('owner@clinic.test', 'password');
        $invoice = $this->createInvoice($headers, [
            'issued_at' => '2040-05-10 09:00:00',
            'tax' => 10,
            'items' => [
                ['description' => 'Revenue test item', 'quantity' => 1, 'unit_price' => 100],
            ],
        ]);

        $this->postJson('/api/payments', [
            'invoice_id' => $invoice['id'],
            'amount' => 60,
            'payment_method' => 'cash',
            'payment_date' => '2040-05-11',
        ], $headers)->assertCreated();

        $response = $this->getJson('/api/reports/revenue?date_from=2040-05-01&date_to=2040-05-31', $headers);
        $response->assertOk()
            ->assertJsonPath('data.summary.total_invoiced', '110.00')
            ->assertJsonPath('data.summary.paid_total', '60.00')
            ->assertJsonPath('data.summary.remaining_total', '50.00')
            ->assertJsonPath('data.summary.invoices_count', 1);
    }

    public function test_appointments_report_summary_counts_are_correct(): void
    {
        $headers = $this->authHeaders('owner@clinic.test', 'password');
        $context = $this->getJson('/api/auth/me', $headers)->json('data');
        $tenantId = (int) $context['tenant']['id'];
        $branchId = (int) $context['branch']['id'];
        $ownerId = User::query()->where('email', 'owner@clinic.test')->firstOrFail()->id;

        $doctor = Doctor::query()->where('tenant_id', $tenantId)->where('branch_id', $branchId)->firstOrFail();
        $patient = Patient::query()->where('tenant_id', $tenantId)->where('branch_id', $branchId)->firstOrFail();
        $service = Service::query()->where('tenant_id', $tenantId)->where('branch_id', $branchId)->firstOrFail();

        foreach ([
            AppointmentStatus::Booked->value,
            AppointmentStatus::Completed->value,
            AppointmentStatus::Cancelled->value,
            AppointmentStatus::NoShow->value,
        ] as $i => $status) {
            Appointment::query()->create([
                'tenant_id' => $tenantId,
                'branch_id' => $branchId,
                'patient_id' => $patient->id,
                'doctor_id' => $doctor->id,
                'service_id' => $service->id,
                'appointment_date' => '2042-01-1'.($i + 1),
                'start_time' => '10:00:00',
                'end_time' => '10:30:00',
                'status' => $status,
                'notes' => 'Report summary check',
                'created_by' => $ownerId,
            ]);
        }

        $response = $this->getJson('/api/reports/appointments?date_from=2042-01-01&date_to=2042-01-31', $headers);
        $response->assertOk()
            ->assertJsonPath('data.summary.total_count', 4)
            ->assertJsonPath('data.summary.booked_count', 1)
            ->assertJsonPath('data.summary.completed_count', 1)
            ->assertJsonPath('data.summary.cancelled_count', 1)
            ->assertJsonPath('data.summary.no_show_count', 1);
    }

    public function test_payments_report_filter_by_payment_method_and_date_range(): void
    {
        $headers = $this->authHeaders('owner@clinic.test', 'password');
        $invoice = $this->createInvoice($headers, [
            'issued_at' => '2041-07-10 09:00:00',
            'items' => [
                ['description' => 'Payment filter test', 'quantity' => 1, 'unit_price' => 150],
            ],
        ]);

        $this->postJson('/api/payments', [
            'invoice_id' => $invoice['id'],
            'amount' => 50,
            'payment_method' => 'cash',
            'payment_date' => '2041-07-11',
        ], $headers)->assertCreated();

        $this->postJson('/api/payments', [
            'invoice_id' => $invoice['id'],
            'amount' => 100,
            'payment_method' => 'card',
            'payment_date' => '2041-07-12',
        ], $headers)->assertCreated();

        $response = $this->getJson(
            '/api/reports/payments?payment_method=card&date_from=2041-07-01&date_to=2041-07-31',
            $headers
        );

        $response->assertOk()
            ->assertJsonPath('data.summary.payments_count', 1)
            ->assertJsonPath('data.summary.total_amount', '100.00')
            ->assertJsonPath('data.items.0.payment_method', 'card');
    }

    /**
     * @param array<string,mixed> $override
     * @return array<string,mixed>
     */
    private function createInvoice(array $headers, array $override = []): array
    {
        $context = $this->getJson('/api/auth/me', $headers)->json('data');
        $tenantId = (int) $context['tenant']['id'];
        $branchId = (int) $context['branch']['id'];
        $patient = Patient::query()->where('tenant_id', $tenantId)->where('branch_id', $branchId)->firstOrFail();

        $payload = array_merge([
            'patient_id' => $patient->id,
            'branch_id' => $branchId,
            'issued_at' => '2040-01-01 10:00:00',
            'discount' => 0,
            'tax' => 0,
            'items' => [
                ['description' => 'Default invoice item', 'quantity' => 1, 'unit_price' => 100],
            ],
        ], $override);

        $created = $this->postJson('/api/invoices', $payload, $headers);
        $created->assertCreated();

        return $created->json('data');
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
