<?php

namespace App\Http\Requests\Doctors;

use App\Enums\DoctorStatus;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateDoctorRequest extends FormRequest
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
            'user_id' => ['sometimes', 'nullable', 'integer', 'exists:users,id'],
            'doctor_code' => ['sometimes', 'nullable', 'string', 'max:32'],
            'full_name' => ['sometimes', 'required', 'string', 'max:255'],
            'specialization' => ['sometimes', 'required', 'string', 'max:255'],
            'license_number' => ['sometimes', 'nullable', 'string', 'max:100'],
            'consultation_fee' => ['sometimes', 'nullable', 'numeric', 'min:0'],
            'bio' => ['sometimes', 'nullable', 'string'],
            'status' => ['sometimes', 'nullable', Rule::enum(DoctorStatus::class)],
            'tenant_id' => ['sometimes', 'nullable', 'integer', 'exists:tenants,id'],
            'branch_id' => ['sometimes', 'nullable', 'integer', 'exists:branches,id'],
        ];
    }
}
