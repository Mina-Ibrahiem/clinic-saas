<?php

namespace App\Http\Controllers\API\V1;

use App\Http\Controllers\API\ApiController;
use App\Http\Requests\Services\StoreServiceRequest;
use App\Http\Requests\Services\UpdateServiceRequest;
use App\Http\Resources\Services\ServiceCollection;
use App\Http\Resources\Services\ServiceResource;
use App\Models\Service;
use App\Services\Services\ServiceService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use OpenApi\Attributes as OA;

#[OA\Tag(name: 'Services')]
class ServiceController extends ApiController
{
    public function __construct(
        private readonly ServiceService $serviceService
    ) {
    }

    #[OA\Get(path: '/services', summary: 'List services', tags: ['Services'])]
    public function index(Request $request): JsonResponse
    {
        $this->authorize('viewAny', Service::class);

        $paginator = $this->serviceService->paginate($request->user(), $request);

        return $this->success(
            'Services fetched successfully.',
            ServiceCollection::make($paginator)->resolve()
        );
    }

    #[OA\Post(path: '/services', summary: 'Create service', tags: ['Services'])]
    public function store(StoreServiceRequest $request): JsonResponse
    {
        $this->authorize('create', Service::class);

        $service = $this->serviceService->create($request->user(), $request->validated());

        return $this->success(
            'Service created successfully.',
            ServiceResource::make($service)->resolve(),
            201
        );
    }

    #[OA\Get(path: '/services/{id}', summary: 'Show service', tags: ['Services'])]
    public function show(Request $request, Service $service): JsonResponse
    {
        $this->authorize('view', $service);

        $service = $this->serviceService->findOrFail($request->user(), $service);

        return $this->success(
            'Service fetched successfully.',
            ServiceResource::make($service)->resolve()
        );
    }

    #[OA\Put(path: '/services/{id}', summary: 'Update service', tags: ['Services'])]
    public function update(UpdateServiceRequest $request, Service $service): JsonResponse
    {
        $this->authorize('update', $service);

        $service = $this->serviceService->update($request->user(), $service, $request->validated());

        return $this->success(
            'Service updated successfully.',
            ServiceResource::make($service)->resolve()
        );
    }

    #[OA\Delete(path: '/services/{id}', summary: 'Delete service', tags: ['Services'])]
    public function destroy(Request $request, Service $service): JsonResponse
    {
        $this->authorize('delete', $service);
        $this->serviceService->delete($service);

        return $this->success('Service deleted successfully.');
    }
}
