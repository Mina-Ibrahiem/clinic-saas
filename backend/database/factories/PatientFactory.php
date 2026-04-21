<?php

namespace Database\Factories;

use App\Enums\Gender;
use App\Enums\PatientStatus;
use App\Models\Branch;
use App\Models\Patient;
use App\Models\Tenant;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Patient>
 */
class PatientFactory extends Factory
{
    protected $model = Patient::class;

    public function definition(): array
    {
        $tenant = Tenant::factory()->create();
        $branch = Branch::factory()->for($tenant)->create();

        return [
            'tenant_id' => $tenant->id,
            'branch_id' => $branch->id,
            'patient_code' => 'P-'.fake()->unique()->numerify('######'),
            'full_name' => fake()->name(),
            'gender' => fake()->randomElement(Gender::cases()),
            'date_of_birth' => fake()->dateTimeBetween('-70 years', '-10 years'),
            'phone' => '+971'.fake()->numerify('5########'),
            'email' => fake()->optional(0.7)->safeEmail(),
            'address' => fake()->optional(0.8)->streetAddress().', UAE',
            'emergency_contact_name' => fake()->optional(0.6)->name(),
            'emergency_contact_phone' => fake()->optional(0.6)->numerify('+9715########'),
            'blood_group' => fake()->optional(0.4)->randomElement(['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-']),
            'allergies' => fake()->optional(0.25)->sentence(),
            'medical_notes' => fake()->optional(0.35)->sentence(),
            'status' => PatientStatus::Active,
        ];
    }

    public function forBranch(Branch $branch): static
    {
        return $this->state(fn (array $attributes) => [
            'tenant_id' => $branch->tenant_id,
            'branch_id' => $branch->id,
        ]);
    }

    public function forTenant(Tenant $tenant): static
    {
        return $this->state(fn (array $attributes) => [
            'tenant_id' => $tenant->id,
        ]);
    }
}
