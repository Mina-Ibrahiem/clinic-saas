<?php

namespace Database\Factories;

use App\Models\Invoice;
use App\Models\InvoiceItem;
use App\Models\Service;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<InvoiceItem>
 */
class InvoiceItemFactory extends Factory
{
    protected $model = InvoiceItem::class;

    public function definition(): array
    {
        $quantity = fake()->numberBetween(1, 3);
        $unit = fake()->randomFloat(2, 75, 900);
        $total = round($quantity * $unit, 2);

        return [
            'invoice_id' => Invoice::factory(),
            'service_id' => null,
            'description' => fake()->randomElement([
                'Consultation',
                'Procedure',
                'Follow-up visit',
                'Diagnostic service',
            ]),
            'quantity' => $quantity,
            'unit_price' => $unit,
            'total_price' => $total,
        ];
    }

    public function forInvoice(Invoice $invoice): static
    {
        return $this->state(fn (array $attributes) => [
            'invoice_id' => $invoice->id,
        ]);
    }

    public function forService(Service $service): static
    {
        return $this->state(fn (array $attributes) => [
            'service_id' => $service->id,
            'description' => $service->name,
            'unit_price' => $service->price,
            'quantity' => 1,
            'total_price' => $service->price,
        ]);
    }
}
