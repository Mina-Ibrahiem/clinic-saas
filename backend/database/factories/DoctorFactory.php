<?php

namespace Database\Factories;

use App\Enums\DoctorStatus;
use App\Models\Branch;
use App\Models\Doctor;
use App\Models\Tenant;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Doctor>
 */
class DoctorFactory extends Factory
{
    protected $model = Doctor::class;

    public function definition(): array
    {
        $tenant = Tenant::factory()->create();
        $branch = Branch::factory()->for($tenant)->create();

        return [
            'tenant_id' => $tenant->id,
            'branch_id' => $branch->id,
            'user_id' => null,
            'doctor_code' => 'D-'.fake()->unique()->numerify('####'),
            'full_name' => 'Dr. '.fake()->lastName(),
            'specialization' => fake()->randomElement([
                'General Practice',
                'Dermatology',
                'Pediatrics',
                'Orthodontics',
                'Cardiology',
            ]),
            'license_number' => fake()->optional(0.8)->bothify('DHCC-####-??'),
            'consultation_fee' => fake()->randomFloat(2, 150, 450),
            'bio' => fake()->optional(0.6)->paragraph(),
            'status' => DoctorStatus::Active,
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
