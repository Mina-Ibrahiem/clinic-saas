<?php

namespace App\Http\Controllers\API\V1;

use App\Http\Controllers\API\ApiController;
use App\Http\Requests\Billing\StoreInvoiceRequest;
use App\Http\Requests\Billing\UpdateInvoiceRequest;
use App\Http\Resources\Billing\InvoiceCollection;
use App\Http\Resources\Billing\InvoiceResource;
use App\Models\Invoice;
use App\Services\Billing\InvoiceService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use OpenApi\Attributes as OA;

#[OA\Tag(name: 'Invoices')]
class InvoiceController extends ApiController
{
    public function __construct(
        private readonly InvoiceService $invoiceService
    ) {
    }

    #[OA\Get(path: '/invoices', summary: 'List invoices', tags: ['Invoices'])]
    public function index(Request $request): JsonResponse
    {
        $this->authorize('viewAny', Invoice::class);
        $paginator = $this->invoiceService->paginate($request->user(), $request);

        return $this->success('Invoices fetched successfully.', InvoiceCollection::make($paginator)->resolve());
    }

    #[OA\Post(path: '/invoices', summary: 'Create invoice', tags: ['Invoices'])]
    public function store(StoreInvoiceRequest $request): JsonResponse
    {
        $this->authorize('create', Invoice::class);
        $invoice = $this->invoiceService->create($request->user(), $request->validated());

        return $this->success('Invoice created successfully.', InvoiceResource::make($invoice)->resolve(), 201);
    }

    #[OA\Get(path: '/invoices/{id}', summary: 'Show invoice details', tags: ['Invoices'])]
    public function show(Request $request, Invoice $invoice): JsonResponse
    {
        $this->authorize('view', $invoice);
        $invoice = $this->invoiceService->findOrFail($request->user(), $invoice);

        return $this->success('Invoice fetched successfully.', InvoiceResource::make($invoice)->resolve());
    }

    #[OA\Put(path: '/invoices/{id}', summary: 'Update invoice', tags: ['Invoices'])]
    public function update(UpdateInvoiceRequest $request, Invoice $invoice): JsonResponse
    {
        $this->authorize('update', $invoice);
        $invoice = $this->invoiceService->update($request->user(), $invoice, $request->validated());

        return $this->success('Invoice updated successfully.', InvoiceResource::make($invoice)->resolve());
    }

    #[OA\Delete(path: '/invoices/{id}', summary: 'Delete invoice', tags: ['Invoices'])]
    public function destroy(Request $request, Invoice $invoice): JsonResponse
    {
        $this->authorize('delete', $invoice);
        $this->invoiceService->delete($invoice);

        return $this->success('Invoice deleted successfully.');
    }
}
