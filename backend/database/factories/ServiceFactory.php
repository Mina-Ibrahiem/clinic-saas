<?php

namespace Database\Factories;

use App\Enums\ServiceStatus;
use App\Models\Branch;
use App\Models\Service;
use App\Models\Tenant;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Service>
 */
class ServiceFactory extends Factory
{
    protected $model = Service::class;

    public function definition(): array
    {
        $tenant = Tenant::factory()->create();
        $branch = Branch::factory()->for($tenant)->create();

        return [
            'tenant_id' => $tenant->id,
            'branch_id' => $branch->id,
            'name' => fake()->randomElement([
                'Consultation',
                'Follow-up',
                'Cleaning',
                'X-Ray',
                'Minor Procedure',
            ]),
            'code' => strtoupper(fake()->bothify('SRV-###')),
            'description' => fake()->optional(0.7)->sentence(),
            'price' => fake()->randomFloat(2, 75, 1200),
            'duration_minutes' => fake()->randomElement([15, 20, 30, 45, 60]),
            'status' => ServiceStatus::Active,
        ];
    }

    public function forBranch(Branch $branch): static
    {
        return $this->state(fn (array $attributes) => [
            'tenant_id' => $branch->tenant_id,
            'branch_id' => $branch->id,
        ]);
    }
}
