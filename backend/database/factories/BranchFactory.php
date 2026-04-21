<?php

namespace Database\Factories;

use App\Enums\BranchStatus;
use App\Models\Branch;
use App\Models\Tenant;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Branch>
 */
class BranchFactory extends Factory
{
    protected $model = Branch::class;

    public function definition(): array
    {
        return [
            'tenant_id' => Tenant::factory(),
            'name' => fake()->randomElement(['Main', 'Downtown', 'Marina', 'JLT']).' Branch',
            'code' => strtoupper(fake()->bothify('??##')),
            'phone' => '+971'.fake()->numerify('5########'),
            'email' => fake()->unique()->companyEmail(),
            'address' => fake()->streetAddress().', Dubai, UAE',
            'status' => BranchStatus::Active,
        ];
    }
}
