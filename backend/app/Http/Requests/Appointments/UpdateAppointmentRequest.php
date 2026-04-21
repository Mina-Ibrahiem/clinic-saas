<?php

namespace App\Http\Requests\Appointments;

use App\Enums\AppointmentStatus;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateAppointmentRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'patient_id' => ['sometimes', 'required', 'integer', 'exists:patients,id'],
            'doctor_id' => ['sometimes', 'required', 'integer', 'exists:doctors,id'],
            'service_id' => ['sometimes', 'nullable', 'integer', 'exists:services,id'],
            'appointment_date' => ['sometimes', 'required', 'date'],
            'start_time' => ['sometimes', 'required', 'date_format:H:i'],
            'end_time' => ['sometimes', 'required', 'date_format:H:i', 'after:start_time'],
            'status' => ['sometimes', 'nullable', Rule::enum(AppointmentStatus::class)],
            'notes' => ['sometimes', 'nullable', 'string'],
            'tenant_id' => ['sometimes', 'nullable', 'integer', 'exists:tenants,id'],
            'branch_id' => ['sometimes', 'nullable', 'integer', 'exists:branches,id'],
        ];
    }
}
