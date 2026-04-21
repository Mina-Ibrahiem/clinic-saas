<?php

namespace App\Http\Requests\Patients;

use App\Enums\Gender;
use App\Enums\PatientStatus;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdatePatientRequest extends FormRequest
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
            'full_name' => ['sometimes', 'required', 'string', 'max:255'],
            'gender' => ['sometimes', 'nullable', Rule::enum(Gender::class)],
            'date_of_birth' => ['sometimes', 'nullable', 'date', 'before_or_equal:today'],
            'phone' => ['sometimes', 'required', 'string', 'max:32'],
            'email' => ['sometimes', 'nullable', 'email:rfc', 'max:255'],
            'address' => ['sometimes', 'nullable', 'string'],
            'emergency_contact_name' => ['sometimes', 'nullable', 'string', 'max:255'],
            'emergency_contact_phone' => ['sometimes', 'nullable', 'string', 'max:32'],
            'blood_group' => ['sometimes', 'nullable', 'string', 'max:8'],
            'allergies' => ['sometimes', 'nullable', 'string'],
            'medical_notes' => ['sometimes', 'nullable', 'string'],
            'status' => ['sometimes', 'nullable', Rule::enum(PatientStatus::class)],
            'tenant_id' => ['sometimes', 'nullable', 'integer', 'exists:tenants,id'],
            'branch_id' => ['sometimes', 'nullable', 'integer', 'exists:branches,id'],
        ];
    }
}
