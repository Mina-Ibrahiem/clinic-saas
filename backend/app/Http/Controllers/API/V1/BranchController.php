<?php

namespace App\Http\Controllers\API\V1;

use App\Http\Controllers\API\ApiController;
use App\Http\Requests\Branches\StoreBranchRequest;
use App\Http\Requests\Branches\UpdateBranchRequest;
use App\Http\Resources\Branches\BranchCollection;
use App\Http\Resources\Branches\BranchResource;
use App\Models\Branch;
use App\Services\Branches\BranchService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use OpenApi\Attributes as OA;

#[OA\Tag(name: 'Branches')]
class BranchController extends ApiController
{
    public function __construct(
        private readonly BranchService $branchService
    ) {
    }

    #[OA\Get(path: '/branches', summary: 'List branches', tags: ['Branches'])]
    public function index(Request $request): JsonResponse
    {
        $this->authorize('viewAny', Branch::class);

        $paginator = $this->branchService->paginate($request->user(), $request);

        return $this->success('Branches fetched successfully.', BranchCollection::make($paginator)->resolve());
    }

    #[OA\Post(path: '/branches', summary: 'Create branch', tags: ['Branches'])]
    public function store(StoreBranchRequest $request): JsonResponse
    {
        $this->authorize('create', Branch::class);
        $branch = $this->branchService->create($request->user(), $request->validated());

        return $this->success('Branch created successfully.', BranchResource::make($branch)->resolve(), 201);
    }

    #[OA\Get(path: '/branches/{id}', summary: 'Show branch', tags: ['Branches'])]
    public function show(Request $request, Branch $branch): JsonResponse
    {
        $this->authorize('view', $branch);
        $branch = $this->branchService->findOrFail($request->user(), $branch);

        return $this->success('Branch fetched successfully.', BranchResource::make($branch)->resolve());
    }

    #[OA\Put(path: '/branches/{id}', summary: 'Update branch', tags: ['Branches'])]
    public function update(UpdateBranchRequest $request, Branch $branch): JsonResponse
    {
        $this->authorize('update', $branch);
        $branch = $this->branchService->update($request->user(), $branch, $request->validated());

        return $this->success('Branch updated successfully.', BranchResource::make($branch)->resolve());
    }

    #[OA\Delete(path: '/branches/{id}', summary: 'Delete branch', tags: ['Branches'])]
    public function destroy(Request $request, Branch $branch): JsonResponse
    {
        $this->authorize('delete', $branch);
        $this->branchService->delete($request->user(), $branch);

        return $this->success('Branch deleted successfully.');
    }
}
