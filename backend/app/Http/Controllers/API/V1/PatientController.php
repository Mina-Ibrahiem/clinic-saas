<?php

namespace App\Http\Controllers\API\V1;

use App\Http\Controllers\API\ApiController;
use App\Http\Requests\Patients\StorePatientRequest;
use App\Http\Requests\Patients\UpdatePatientRequest;
use App\Http\Resources\Patients\PatientCollection;
use App\Http\Resources\Patients\PatientResource;
use App\Models\Patient;
use App\Services\Patients\PatientService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use OpenApi\Attributes as OA;

#[OA\Tag(name: 'Patients')]
class PatientController extends ApiController
{
    public function __construct(
        private readonly PatientService $patientService
    ) {
    }

    #[OA\Get(path: '/patients', summary: 'List patients with filters', tags: ['Patients'])]
    public function index(Request $request): JsonResponse
    {
        $this->authorize('viewAny', Patient::class);

        $paginator = $this->patientService->paginate($request->user(), $request);

        return $this->success(
            'Patients fetched successfully.',
            PatientCollection::make($paginator)->resolve()
        );
    }

    #[OA\Post(path: '/patients', summary: 'Create patient', tags: ['Patients'])]
    public function store(StorePatientRequest $request): JsonResponse
    {
        $this->authorize('create', Patient::class);

        $patient = $this->patientService->create($request->user(), $request->validated());

        return $this->success(
            'Patient created successfully.',
            PatientResource::make($patient)->resolve(),
            201
        );
    }

    #[OA\Get(path: '/patients/{id}', summary: 'Show patient profile', tags: ['Patients'])]
    public function show(Request $request, Patient $patient): JsonResponse
    {
        $this->authorize('view', $patient);

        $patient = $this->patientService->findOrFail($request->user(), $patient);

        return $this->success(
            'Patient profile fetched successfully.',
            PatientResource::make($patient)->resolve()
        );
    }

    #[OA\Put(path: '/patients/{id}', summary: 'Update patient', tags: ['Patients'])]
    public function update(UpdatePatientRequest $request, Patient $patient): JsonResponse
    {
        $this->authorize('update', $patient);

        $patient = $this->patientService->update($request->user(), $patient, $request->validated());

        return $this->success(
            'Patient updated successfully.',
            PatientResource::make($patient)->resolve()
        );
    }

    #[OA\Delete(path: '/patients/{id}', summary: 'Soft delete patient', tags: ['Patients'])]
    public function destroy(Request $request, Patient $patient): JsonResponse
    {
        $this->authorize('delete', $patient);
        $this->patientService->delete($patient);

        return $this->success('Patient deleted successfully.');
    }
}
