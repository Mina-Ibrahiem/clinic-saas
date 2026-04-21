<?php

namespace Database\Factories;

use App\Enums\InvoiceStatus;
use App\Enums\PaymentMethod;
use App\Models\Invoice;
use App\Models\Payment;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Payment>
 */
class PaymentFactory extends Factory
{
    protected $model = Payment::class;

    public function definition(): array
    {
        $invoice = Invoice::factory()->create([
            'status' => InvoiceStatus::Unpaid,
        ]);

        $upper = max(1.0, (float) $invoice->total);
        $lower = min(50.0, $upper);
        $amount = fake()->randomFloat(2, $lower, $upper);

        return [
            'tenant_id' => $invoice->tenant_id,
            'branch_id' => $invoice->branch_id,
            'invoice_id' => $invoice->id,
            'payment_method' => fake()->randomElement(PaymentMethod::cases()),
            'amount' => $amount,
            'payment_date' => now()->subDays(fake()->numberBetween(0, 10)),
            'reference_number' => fake()->optional(0.5)->bothify('REF-########'),
            'notes' => fake()->optional(0.25)->sentence(),
            'received_by' => null,
        ];
    }

    public function forInvoice(Invoice $invoice): static
    {
        return $this->state(function (array $attributes) use ($invoice) {
            $upper = max(1.0, (float) $invoice->total);
            $lower = min(50.0, $upper);

            return [
                'tenant_id' => $invoice->tenant_id,
                'branch_id' => $invoice->branch_id,
                'invoice_id' => $invoice->id,
                'amount' => fake()->randomFloat(2, $lower, $upper),
            ];
        });
    }
}
