<?php

namespace Database\Seeders;

use App\Enums\AppointmentStatus;
use App\Enums\BranchStatus;
use App\Enums\DoctorStatus;
use App\Enums\InvoiceStatus;
use App\Enums\PatientStatus;
use App\Enums\PaymentMethod;
use App\Enums\ServiceStatus;
use App\Enums\TenantStatus;
use App\Enums\UserStatus;
use App\Models\Appointment;
use App\Models\Branch;
use App\Models\Doctor;
use App\Models\Invoice;
use App\Models\InvoiceItem;
use App\Models\Patient;
use App\Models\Payment;
use App\Models\Role;
use App\Models\Service;
use App\Models\Setting;
use App\Models\Tenant;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class ClinicDemoSeeder extends Seeder
{
    public function run(): void
    {
        // Demo credentials (all passwords: password):
        // admin@clinic.test, owner@clinic.test, doctor@clinic.test,
        // receptionist@clinic.test, accountant@clinic.test
        $tenant = Tenant::query()->create([
            'name' => 'Demo Medical Center',
            'slug' => 'demo-medical-center',
            'legal_name' => 'Demo Medical Center LLC',
            'timezone' => 'Asia/Dubai',
            'currency' => 'AED',
            'status' => TenantStatus::Active,
            'trial_ends_at' => null,
        ]);

        $branch = Branch::query()->create([
            'tenant_id' => $tenant->id,
            'name' => 'Main Clinic',
            'code' => 'MAIN',
            'phone' => '+971500000001',
            'email' => 'main@demo-clinic.test',
            'address' => 'Sheikh Zayed Road, Dubai, UAE',
            'status' => BranchStatus::Active,
        ]);

        Setting::query()->create([
            'tenant_id' => $tenant->id,
            'branch_id' => null,
            'key' => 'clinic.locale',
            'value' => 'en_AE',
        ]);

        Setting::query()->create([
            'tenant_id' => $tenant->id,
            'branch_id' => $branch->id,
            'key' => 'branch.opening_hours',
            'value' => json_encode([
                'mon' => ['09:00', '18:00'],
                'tue' => ['09:00', '18:00'],
                'wed' => ['09:00', '18:00'],
                'thu' => ['09:00', '18:00'],
                'fri' => ['09:00', '13:00'],
            ]),
        ]);

        $admin = User::query()->create([
            'tenant_id' => $tenant->id,
            'branch_id' => $branch->id,
            'full_name' => 'Super Admin',
            'email' => 'admin@clinic.test',
            'phone' => '+971500000000',
            'password' => Hash::make('password'),
            'status' => UserStatus::Active,
        ]);
        $admin->roles()->sync([Role::query()->where('slug', 'super_admin')->firstOrFail()->id]);

        $owner = User::query()->create([
            'tenant_id' => $tenant->id,
            'branch_id' => $branch->id,
            'full_name' => 'Clinic Owner',
            'email' => 'owner@clinic.test',
            'phone' => '+971500000002',
            'password' => Hash::make('password'),
            'status' => UserStatus::Active,
        ]);
        $owner->roles()->sync([Role::query()->where('slug', 'clinic_owner')->firstOrFail()->id]);

        $doctorUser = User::query()->create([
            'tenant_id' => $tenant->id,
            'branch_id' => $branch->id,
            'full_name' => 'Dr. Amira Hassan',
            'email' => 'doctor@clinic.test',
            'phone' => '+971500000003',
            'password' => Hash::make('password'),
            'status' => UserStatus::Active,
        ]);
        $doctorUser->roles()->sync([Role::query()->where('slug', 'doctor')->firstOrFail()->id]);

        $receptionist = User::query()->create([
            'tenant_id' => $tenant->id,
            'branch_id' => $branch->id,
            'full_name' => 'Reception User',
            'email' => 'receptionist@clinic.test',
            'phone' => '+971500000004',
            'password' => Hash::make('password'),
            'status' => UserStatus::Active,
        ]);
        $receptionist->roles()->sync([Role::query()->where('slug', 'receptionist')->firstOrFail()->id]);

        $accountant = User::query()->create([
            'tenant_id' => $tenant->id,
            'branch_id' => $branch->id,
            'full_name' => 'Accountant User',
            'email' => 'accountant@clinic.test',
            'phone' => '+971500000005',
            'password' => Hash::make('password'),
            'status' => UserStatus::Active,
        ]);
        $accountant->roles()->sync([Role::query()->where('slug', 'accountant')->firstOrFail()->id]);

        $doctor = Doctor::query()->create([
            'tenant_id' => $tenant->id,
            'branch_id' => $branch->id,
            'user_id' => $doctorUser->id,
            'doctor_code' => 'D-1001',
            'full_name' => 'Dr. Amira Hassan',
            'specialization' => 'General Practice',
            'license_number' => 'DHA-GP-100200',
            'consultation_fee' => 250.00,
            'bio' => 'Family medicine and preventive care.',
            'status' => DoctorStatus::Active,
        ]);

        $doctorTwo = Doctor::query()->create([
            'tenant_id' => $tenant->id,
            'branch_id' => $branch->id,
            'user_id' => null,
            'doctor_code' => 'D-1002',
            'full_name' => 'Dr. Omar Rahman',
            'specialization' => 'Dermatology',
            'license_number' => 'DHA-DERM-220011',
            'consultation_fee' => 350.00,
            'bio' => null,
            'status' => DoctorStatus::Active,
        ]);

        $services = [
            ['name' => 'General Consultation', 'code' => 'CONS-GP', 'price' => 250, 'duration_minutes' => 30],
            ['name' => 'Follow-up Visit', 'code' => 'FU-30', 'price' => 150, 'duration_minutes' => 20],
            ['name' => 'Minor Procedure', 'code' => 'PROC-MIN', 'price' => 900, 'duration_minutes' => 60],
            ['name' => 'Dental Cleaning', 'code' => 'DEN-CLN', 'price' => 320, 'duration_minutes' => 45],
            ['name' => 'Specialist Consultation', 'code' => 'CONS-SP', 'price' => 450, 'duration_minutes' => 45],
        ];

        $serviceModels = collect($services)->map(fn (array $s) => Service::query()->create([
            'tenant_id' => $tenant->id,
            'branch_id' => $branch->id,
            'name' => $s['name'],
            'code' => $s['code'],
            'description' => 'Seeded catalog item',
            'price' => $s['price'],
            'duration_minutes' => $s['duration_minutes'],
            'status' => ServiceStatus::Active,
        ]));

        Patient::factory()
            ->count(18)
            ->forBranch($branch)
            ->create([
                'tenant_id' => $tenant->id,
                'status' => PatientStatus::Active,
            ]);

        $patients = Patient::query()->where('branch_id', $branch->id)->limit(6)->get();

        foreach ($patients as $index => $patient) {
            $doc = $index % 2 === 0 ? $doctor : $doctorTwo;
            $svc = $serviceModels[$index % $serviceModels->count()];

            Appointment::query()->create([
                'tenant_id' => $tenant->id,
                'branch_id' => $branch->id,
                'patient_id' => $patient->id,
                'doctor_id' => $doc->id,
                'service_id' => $svc->id,
                'appointment_date' => now()->addDays($index + 1)->toDateString(),
                'start_time' => '10:00:00',
                'end_time' => '10:45:00',
                'status' => AppointmentStatus::Booked,
                'notes' => 'Seeded appointment',
                'created_by' => $admin->id,
            ]);
        }

        $invoicePatient = $patients->first();
        $invoiceService = $serviceModels->first();

        $invoice = Invoice::query()->create([
            'tenant_id' => $tenant->id,
            'branch_id' => $branch->id,
            'patient_id' => $invoicePatient->id,
            'appointment_id' => null,
            'invoice_number' => 'INV-'.now()->format('Y').'-000001',
            'subtotal' => 500.00,
            'discount' => 0,
            'tax' => 25.00,
            'total' => 525.00,
            'status' => InvoiceStatus::PartiallyPaid,
            'issued_at' => now()->subDay(),
            'due_at' => now()->addWeek(),
            'created_by' => $admin->id,
        ]);

        InvoiceItem::query()->create([
            'invoice_id' => $invoice->id,
            'service_id' => $invoiceService->id,
            'description' => $invoiceService->name,
            'quantity' => 2,
            'unit_price' => 250.00,
            'total_price' => 500.00,
        ]);

        Payment::query()->create([
            'tenant_id' => $tenant->id,
            'branch_id' => $branch->id,
            'invoice_id' => $invoice->id,
            'payment_method' => PaymentMethod::Card,
            'amount' => 200.00,
            'payment_date' => now()->toDateString(),
            'reference_number' => 'SEED-PAY-200',
            'notes' => 'Seeded partial payment for dashboard/report demos',
            'received_by' => $accountant->id,
        ]);
    }
}
