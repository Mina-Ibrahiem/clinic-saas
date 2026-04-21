<?php

namespace App\Http\Resources\Billing;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class InvoiceItemResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'service_id' => $this->service_id,
            'description' => $this->description,
            'quantity' => (int) $this->quantity,
            'unit_price' => $this->unit_price,
            'total_price' => $this->total_price,
            'service' => $this->whenLoaded('service', function () {
                return [
                    'id' => $this->service?->id,
                    'name' => $this->service?->name,
                    'code' => $this->service?->code,
                ];
            }),
        ];
    }
}
