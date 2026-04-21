<?php

namespace App\Http\Resources\Billing;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class InvoiceResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        $paidAmount = (float) ($this->payments_sum_amount ?? $this->payments->sum('amount'));
        $total = (float) $this->total;
        $remaining = max(0, round($total - $paidAmount, 2));

        return [
            'id' => $this->id,
            'tenant_id' => $this->tenant_id,
            'branch_id' => $this->branch_id,
            'patient_id' => $this->patient_id,
            'appointment_id' => $this->appointment_id,
            'invoice_number' => $this->invoice_number,
            'subtotal' => $this->subtotal,
            'discount' => $this->discount,
            'tax' => $this->tax,
            'total' => $this->total,
            'status' => $this->status?->value ?? $this->status,
            'issued_at' => $this->issued_at,
            'due_at' => $this->due_at,
            'created_by' => $this->created_by,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
            'summary' => [
                'paid_amount' => number_format($paidAmount, 2, '.', ''),
                'remaining_amount' => number_format($remaining, 2, '.', ''),
                'items_count' => (int) ($this->items_count ?? $this->items->count()),
                'payments_count' => (int) ($this->payments_count ?? $this->payments->count()),
            ],
            'patient' => $this->whenLoaded('patient', function () {
                return [
                    'id' => $this->patient?->id,
                    'patient_code' => $this->patient?->patient_code,
                    'full_name' => $this->patient?->full_name,
                    'phone' => $this->patient?->phone,
                ];
            }),
            'appointment' => $this->whenLoaded('appointment', function () {
                return [
                    'id' => $this->appointment?->id,
                    'appointment_date' => $this->appointment?->appointment_date?->toDateString(),
                    'status' => $this->appointment?->status?->value ?? $this->appointment?->status,
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
            'items' => InvoiceItemResource::collection($this->whenLoaded('items')),
            'payments' => PaymentResource::collection($this->whenLoaded('payments')),
        ];
    }
}
