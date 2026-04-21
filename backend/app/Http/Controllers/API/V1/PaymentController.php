<?php

namespace App\Http\Controllers\API\V1;

use App\Http\Controllers\API\ApiController;
use App\Http\Requests\Billing\StorePaymentRequest;
use App\Http\Resources\Billing\PaymentCollection;
use App\Http\Resources\Billing\PaymentResource;
use App\Models\Payment;
use App\Services\Billing\PaymentService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use OpenApi\Attributes as OA;

#[OA\Tag(name: 'Payments')]
class PaymentController extends ApiController
{
    public function __construct(
        private readonly PaymentService $paymentService
    ) {
    }

    #[OA\Get(path: '/payments', summary: 'List payments', tags: ['Payments'])]
    public function index(Request $request): JsonResponse
    {
        $this->authorize('viewAny', Payment::class);
        $paginator = $this->paymentService->paginate($request->user(), $request);

        return $this->success('Payments fetched successfully.', PaymentCollection::make($paginator)->resolve());
    }

    #[OA\Post(path: '/payments', summary: 'Create payment', tags: ['Payments'])]
    public function store(StorePaymentRequest $request): JsonResponse
    {
        $this->authorize('create', Payment::class);
        $payment = $this->paymentService->create($request->user(), $request->validated());

        return $this->success('Payment created successfully.', PaymentResource::make($payment)->resolve(), 201);
    }

    #[OA\Get(path: '/payments/{id}', summary: 'Show payment details', tags: ['Payments'])]
    public function show(Request $request, Payment $payment): JsonResponse
    {
        $this->authorize('view', $payment);
        $payment = $this->paymentService->findOrFail($request->user(), $payment);

        return $this->success('Payment fetched successfully.', PaymentResource::make($payment)->resolve());
    }

    #[OA\Delete(path: '/payments/{id}', summary: 'Delete payment', tags: ['Payments'])]
    public function destroy(Request $request, Payment $payment): JsonResponse
    {
        $this->authorize('delete', $payment);
        $this->paymentService->delete($request->user(), $payment);

        return $this->success('Payment deleted successfully.');
    }
}
