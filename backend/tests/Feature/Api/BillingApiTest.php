<?php

namespace Tests\Feature\Api;

use App\Models\Invoice;
use App\Models\Patient;
use App\Models\Service;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class BillingApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed();
    }

    public function test_invoice_create_calculates_totals_and_items(): void
    {
        $headers = $this->authHeaders('owner@clinic.test', 'password');
        $me = $this->getJson('/api/auth/me', $headers)->json('data');
        $tenantId = (int) $me['tenant']['id'];
        $branchId = (int) $me['branch']['id'];

        $patient = Patient::query()->where('tenant_id', $tenantId)->where('branch_id', $branchId)->firstOrFail();
        $service = Service::query()->where('tenant_id', $tenantId)->where('branch_id', $branchId)->firstOrFail();

        $response = $this->postJson('/api/invoices', [
            'patient_id' => $patient->id,
            'branch_id' => $branchId,
            'issued_at' => '2030-01-01 10:00:00',
            'due_at' => '2030-01-08 10:00:00',
            'discount' => 10,
            'tax' => 5,
            'items' => [
                [
                    'service_id' => $service->id,
                    'quantity' => 2,
                    'unit_price' => 100,
                ],
                [
                    'description' => 'Custom line item',
                    'quantity' => 1,
                    'unit_price' => 50,
                ],
            ],
        ], $headers);

        $response->assertCreated()
            ->assertJsonPath('data.subtotal', '250.00')
            ->assertJsonPath('data.discount', '10.00')
            ->assertJsonPath('data.tax', '5.00')
            ->assertJsonPath('data.total', '245.00')
            ->assertJsonPath('data.summary.items_count', 2);
    }

    public function test_payment_create_updates_invoice_status_and_overpayment_blocked(): void
    {
        $headers = $this->authHeaders('owner@clinic.test', 'password');
        $invoice = $this->createInvoice($headers, 200.00);

        $first = $this->postJson('/api/payments', [
            'invoice_id' => $invoice['id'],
            'amount' => 50,
            'payment_method' => 'cash',
            'payment_date' => '2030-01-02',
        ], $headers);
        $first->assertCreated();

        $invoiceAfterFirst = $this->getJson('/api/invoices/'.$invoice['id'], $headers);
        $invoiceAfterFirst->assertOk()
            ->assertJsonPath('data.status', 'partially_paid')
            ->assertJsonPath('data.summary.paid_amount', '50.00')
            ->assertJsonPath('data.summary.remaining_amount', '150.00');

        $overpay = $this->postJson('/api/payments', [
            'invoice_id' => $invoice['id'],
            'amount' => 500,
            'payment_method' => 'card',
            'payment_date' => '2030-01-03',
        ], $headers);

        $overpay->assertStatus(422)
            ->assertJsonPath('message', 'Payment exceeds remaining invoice balance.');
    }

    public function test_payment_delete_recalculates_invoice_status(): void
    {
        $headers = $this->authHeaders('owner@clinic.test', 'password');
        $invoice = $this->createInvoice($headers, 120.00);

        $p1 = $this->postJson('/api/payments', [
            'invoice_id' => $invoice['id'],
            'amount' => 60,
            'payment_method' => 'cash',
            'payment_date' => '2030-02-02',
        ], $headers)->json('data');

        $p2 = $this->postJson('/api/payments', [
            'invoice_id' => $invoice['id'],
            'amount' => 60,
            'payment_method' => 'transfer',
            'payment_date' => '2030-02-03',
        ], $headers)->json('data');

        $paidInvoice = $this->getJson('/api/invoices/'.$invoice['id'], $headers);
        $paidInvoice->assertOk()
            ->assertJsonPath('data.status', 'paid')
            ->assertJsonPath('data.summary.paid_amount', '120.00')
            ->assertJsonPath('data.summary.remaining_amount', '0.00');

        $delete = $this->deleteJson('/api/payments/'.$p2['id'], [], $headers);
        $delete->assertOk();

        $recalculated = $this->getJson('/api/invoices/'.$invoice['id'], $headers);
        $recalculated->assertOk()
            ->assertJsonPath('data.status', 'partially_paid')
            ->assertJsonPath('data.summary.paid_amount', '60.00')
            ->assertJsonPath('data.summary.remaining_amount', '60.00');
    }

    public function test_doctor_cannot_manage_payments_or_invoices(): void
    {
        $doctorHeaders = $this->authHeaders('doctor@clinic.test', 'password');
        $invoice = Invoice::query()->firstOrFail();

        $createInvoiceAsDoctor = $this->postJson('/api/invoices', [
            'patient_id' => $invoice['patient_id'],
            'branch_id' => $invoice['branch_id'],
            'issued_at' => '2030-03-01 09:00:00',
            'items' => [['description' => 'x', 'quantity' => 1, 'unit_price' => 80]],
        ], $doctorHeaders);
        $createInvoiceAsDoctor->assertForbidden();

        $createPaymentAsDoctor = $this->postJson('/api/payments', [
            'invoice_id' => $invoice['id'],
            'amount' => 10,
            'payment_method' => 'cash',
            'payment_date' => '2030-03-02',
        ], $doctorHeaders);
        $createPaymentAsDoctor->assertForbidden();
    }

    public function test_invoice_and_payment_listing_filters_and_pagination(): void
    {
        $headers = $this->authHeaders('owner@clinic.test', 'password');
        $invoice = $this->createInvoice($headers, 100.00);

        $this->postJson('/api/payments', [
            'invoice_id' => $invoice['id'],
            'amount' => 20,
            'payment_method' => 'card',
            'payment_date' => '2030-04-02',
            'reference_number' => 'REF-XYZ-123',
        ], $headers)->assertCreated();

        $listInvoices = $this->getJson('/api/invoices?search='.$invoice['invoice_number'].'&sort=total&per_page=5', $headers);
        $listInvoices->assertOk()
            ->assertJsonPath('data.pagination.per_page', 5)
            ->assertJsonPath('data.items.0.invoice_number', $invoice['invoice_number']);

        $listPayments = $this->getJson('/api/payments?search=REF-XYZ-123&payment_method=card&per_page=5', $headers);
        $listPayments->assertOk()
            ->assertJsonPath('data.pagination.per_page', 5)
            ->assertJsonPath('data.items.0.payment_method', 'card');
    }

    /**
     * @return array<string,mixed>
     */
    private function createInvoice(array $headers, float $amount): array
    {
        $me = $this->getJson('/api/auth/me', $headers)->json('data');
        $tenantId = (int) $me['tenant']['id'];
        $branchId = (int) $me['branch']['id'];
        $patient = Patient::query()->where('tenant_id', $tenantId)->where('branch_id', $branchId)->firstOrFail();

        $created = $this->postJson('/api/invoices', [
            'patient_id' => $patient->id,
            'branch_id' => $branchId,
            'issued_at' => '2030-01-01 10:00:00',
            'items' => [
                [
                    'description' => 'Base service',
                    'quantity' => 1,
                    'unit_price' => $amount,
                ],
            ],
        ], $headers);

        $created->assertCreated();

        return $created->json('data');
    }

    /**
     * @return array<string,string>
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
