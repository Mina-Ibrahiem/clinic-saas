<?php

namespace App\Services\Billing;

use App\Enums\InvoiceStatus;
use App\Models\Invoice;

class BillingStatusService
{
    public function syncInvoiceStatus(Invoice $invoice): Invoice
    {
        $invoice->loadMissing('payments');

        $paidAmount = (float) $invoice->payments->sum('amount');
        $total = (float) $invoice->total;
        $current = (string) ($invoice->status?->value ?? $invoice->status);

        if ($current === InvoiceStatus::Cancelled->value) {
            return $invoice;
        }

        if ($paidAmount <= 0.0) {
            if ($current === InvoiceStatus::Draft->value) {
                return $invoice;
            }

            $next = InvoiceStatus::Unpaid->value;
        } elseif ($paidAmount + 0.0001 < $total) {
            $next = InvoiceStatus::PartiallyPaid->value;
        } else {
            $next = InvoiceStatus::Paid->value;
        }

        if ($current !== $next) {
            $invoice->status = $next;
            $invoice->save();
            $invoice->refresh();
        }

        return $invoice;
    }
}
