<?php

namespace App\Http\Resources\Appointments;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class AppointmentResource extends JsonResource
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
            'patient_id' => $this->patient_id,
            'doctor_id' => $this->doctor_id,
            'service_id' => $this->service_id,
            'appointment_date' => $this->appointment_date?->toDateString(),
            'start_time' => $this->start_time,
            'end_time' => $this->end_time,
            'status' => $this->status?->value ?? $this->status,
            'notes' => $this->notes,
            'created_by' => $this->created_by,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
            'patient' => $this->whenLoaded('patient', function () {
                return [
                    'id' => $this->patient?->id,
                    'patient_code' => $this->patient?->patient_code,
                    'full_name' => $this->patient?->full_name,
                    'phone' => $this->patient?->phone,
                ];
            }),
            'doctor' => $this->whenLoaded('doctor', function () {
                return [
                    'id' => $this->doctor?->id,
                    'doctor_code' => $this->doctor?->doctor_code,
                    'full_name' => $this->doctor?->full_name,
                    'specialization' => $this->doctor?->specialization,
                ];
            }),
            'service' => $this->whenLoaded('service', function () {
                return [
                    'id' => $this->service?->id,
                    'name' => $this->service?->name,
                    'code' => $this->service?->code,
                    'price' => $this->service?->price,
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
