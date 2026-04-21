<?php

namespace App\Http\Controllers\API\V1;

use App\Http\Controllers\API\ApiController;
use App\Http\Requests\Doctors\StoreDoctorRequest;
use App\Http\Requests\Doctors\UpdateDoctorRequest;
use App\Http\Resources\Doctors\DoctorCollection;
use App\Http\Resources\Doctors\DoctorResource;
use App\Models\Doctor;
use App\Services\Doctors\DoctorService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use OpenApi\Attributes as OA;

#[OA\Tag(name: 'Doctors')]
class DoctorController extends ApiController
{
    public function __construct(
        private readonly DoctorService $doctorService
    ) {
    }

    #[OA\Get(path: '/doctors', summary: 'List doctors', tags: ['Doctors'])]
    public function index(Request $request): JsonResponse
    {
        $this->authorize('viewAny', Doctor::class);

        $paginator = $this->doctorService->paginate($request->user(), $request);

        return $this->success('Doctors fetched successfully.', DoctorCollection::make($paginator)->resolve());
    }

    #[OA\Post(path: '/doctors', summary: 'Create doctor', tags: ['Doctors'])]
    public function store(StoreDoctorRequest $request): JsonResponse
    {
        $this->authorize('create', Doctor::class);

        $doctor = $this->doctorService->create($request->user(), $request->validated());

        return $this->success('Doctor created successfully.', DoctorResource::make($doctor)->resolve(), 201);
    }

    #[OA\Get(path: '/doctors/{id}', summary: 'Show doctor', tags: ['Doctors'])]
    public function show(Request $request, Doctor $doctor): JsonResponse
    {
        $this->authorize('view', $doctor);

        $doctor = $this->doctorService->findOrFail($request->user(), $doctor);

        return $this->success('Doctor fetched successfully.', DoctorResource::make($doctor)->resolve());
    }

    #[OA\Put(path: '/doctors/{id}', summary: 'Update doctor', tags: ['Doctors'])]
    public function update(UpdateDoctorRequest $request, Doctor $doctor): JsonResponse
    {
        $this->authorize('update', $doctor);

        $doctor = $this->doctorService->update($request->user(), $doctor, $request->validated());

        return $this->success('Doctor updated successfully.', DoctorResource::make($doctor)->resolve());
    }

    #[OA\Delete(path: '/doctors/{id}', summary: 'Delete doctor', tags: ['Doctors'])]
    public function destroy(Request $request, Doctor $doctor): JsonResponse
    {
        $this->authorize('delete', $doctor);

        $this->doctorService->delete($doctor);

        return $this->success('Doctor deleted successfully.');
    }
}
