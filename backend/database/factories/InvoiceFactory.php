<?php

namespace Database\Factories;

use App\Enums\InvoiceStatus;
use App\Models\Appointment;
use App\Models\Invoice;
use App\Models\Patient;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Invoice>
 */
class InvoiceFactory extends Factory
{
    protected $model = Invoice::class;

    public function definition(): array
    {
        $patient = Patient::factory()->create();

        $subtotal = fake()->randomFloat(2, 200, 3500);
        $discount = fake()->randomFloat(2, 0, min(200, $subtotal * 0.1));
        $tax = round(($subtotal - $discount) * 0.05, 2);
        $total = round($subtotal - $discount + $tax, 2);

        return [
            'tenant_id' => $patient->tenant_id,
            'branch_id' => $patient->branch_id,
            'patient_id' => $patient->id,
            'appointment_id' => null,
            'invoice_number' => 'INV-'.now()->format('Y').'-'.fake()->unique()->numerify('######'),
            'subtotal' => $subtotal,
            'discount' => $discount,
            'tax' => $tax,
            'total' => $total,
            'status' => fake()->randomElement([
                InvoiceStatus::Draft,
                InvoiceStatus::Unpaid,
                InvoiceStatus::Paid,
                InvoiceStatus::PartiallyPaid,
            ]),
            'issued_at' => now()->subDays(fake()->numberBetween(0, 20)),
            'due_at' => now()->addDays(fake()->numberBetween(0, 14)),
            'created_by' => null,
        ];
    }

    public function forPatient(Patient $patient): static
    {
        return $this->state(fn (array $attributes) => [
            'tenant_id' => $patient->tenant_id,
            'branch_id' => $patient->branch_id,
            'patient_id' => $patient->id,
        ]);
    }

    public function forAppointment(Appointment $appointment): static
    {
        return $this->state(fn (array $attributes) => [
            'tenant_id' => $appointment->tenant_id,
            'branch_id' => $appointment->branch_id,
            'patient_id' => $appointment->patient_id,
            'appointment_id' => $appointment->id,
        ]);
    }
}
