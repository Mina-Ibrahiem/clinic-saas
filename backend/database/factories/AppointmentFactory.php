<?php

namespace Database\Factories;

use App\Enums\AppointmentStatus;
use App\Models\Appointment;
use App\Models\Doctor;
use App\Models\Patient;
use App\Models\Service;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Appointment>
 */
class AppointmentFactory extends Factory
{
    protected $model = Appointment::class;

    public function definition(): array
    {
        $patient = Patient::factory()->create();
        $branch = $patient->branch;

        $doctor = Doctor::factory()->forBranch($branch)->create();
        $service = Service::factory()->forBranch($branch)->create();

        $date = fake()->dateTimeBetween('now', '+30 days')->format('Y-m-d');
        $start = fake()->time('H:i:s');
        $end = fake()->dateTimeBetween($start, '+2 hours')->format('H:i:s');

        return [
            'tenant_id' => $patient->tenant_id,
            'branch_id' => $patient->branch_id,
            'patient_id' => $patient->id,
            'doctor_id' => $doctor->id,
            'service_id' => $service->id,
            'appointment_date' => $date,
            'start_time' => $start,
            'end_time' => $end,
            'status' => fake()->randomElement(AppointmentStatus::cases()),
            'notes' => fake()->optional(0.35)->sentence(),
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
}
