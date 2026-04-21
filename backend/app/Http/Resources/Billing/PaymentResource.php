<?php

namespace App\Http\Resources\Billing;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class PaymentResource extends JsonResource
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
            'invoice_id' => $this->invoice_id,
            'payment_method' => $this->payment_method?->value ?? $this->payment_method,
            'amount' => $this->amount,
            'payment_date' => $this->payment_date?->toDateString(),
            'reference_number' => $this->reference_number,
            'notes' => $this->notes,
            'received_by' => $this->received_by,
            'created_at' => $this->created_at,
            'invoice' => $this->whenLoaded('invoice', function () {
                return [
                    'id' => $this->invoice?->id,
                    'invoice_number' => $this->invoice?->invoice_number,
                    'status' => $this->invoice?->status?->value ?? $this->invoice?->status,
                    'total' => $this->invoice?->total,
                ];
            }),
            'patient' => $this->whenLoaded('invoice.patient', function () {
                return [
                    'id' => $this->invoice?->patient?->id,
                    'patient_code' => $this->invoice?->patient?->patient_code,
                    'full_name' => $this->invoice?->patient?->full_name,
                ];
            }),
            'branch' => $this->whenLoaded('branch', function () {
                return [
                    'id' => $this->branch?->id,
                    'name' => $this->branch?->name,
                    'code' => $this->branch?->code,
                ];
            }),
        ];
    }
}
