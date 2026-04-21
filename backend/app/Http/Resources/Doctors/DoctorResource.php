<?php

namespace App\Http\Resources\Doctors;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class DoctorResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'tenant_id' => $this->tenant_id,
            'branch_id' => $this->branch_id,
            'user_id' => $this->user_id,
            'doctor_code' => $this->doctor_code,
            'full_name' => $this->full_name,
            'specialization' => $this->specialization,
            'license_number' => $this->license_number,
            'consultation_fee' => $this->consultation_fee,
            'bio' => $this->bio,
            'status' => $this->status?->value ?? $this->status,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
            'stats' => [
                'appointments_count' => (int) ($this->appointments_count ?? 0),
                'notes_count' => (int) ($this->notes_count ?? 0),
            ],
            'user' => $this->whenLoaded('user', function () {
                return [
                    'id' => $this->user?->id,
                    'full_name' => $this->user?->full_name,
                    'email' => $this->user?->email,
                    'phone' => $this->user?->phone,
                    'status' => $this->user?->status?->value ?? $this->user?->status,
                ];
            }),
            'branch' => $this->whenLoaded('branch', function () {
                return [
                    'id' => $this->branch?->id,
                    'name' => $this->branch?->name,
                    'code' => $this->branch?->code,
                ];
            }),
            'tenant' => $this->whenLoaded('tenant', function () {
                return [
                    'id' => $this->tenant?->id,
                    'uuid' => $this->tenant?->uuid,
                    'name' => $this->tenant?->name,
                    'slug' => $this->tenant?->slug,
                ];
            }),
        ];
    }
}
