<?php

namespace App\Http\Controllers\API\V1;

use App\Http\Controllers\API\ApiController;
use App\Http\Requests\Appointments\StoreAppointmentRequest;
use App\Http\Requests\Appointments\UpdateAppointmentRequest;
use App\Http\Resources\Appointments\AppointmentCollection;
use App\Http\Resources\Appointments\AppointmentResource;
use App\Models\Appointment;
use App\Services\Appointments\AppointmentService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use OpenApi\Attributes as OA;

#[OA\Tag(name: 'Appointments')]
class AppointmentController extends ApiController
{
    public function __construct(
        private readonly AppointmentService $appointmentService
    ) {
    }

    #[OA\Get(path: '/appointments', summary: 'List appointments', tags: ['Appointments'])]
    public function index(Request $request): JsonResponse
    {
        $this->authorize('viewAny', Appointment::class);

        $paginator = $this->appointmentService->paginate($request->user(), $request);

        return $this->success(
            'Appointments fetched successfully.',
            AppointmentCollection::make($paginator)->resolve()
        );
    }

    #[OA\Post(path: '/appointments', summary: 'Create appointment', tags: ['Appointments'])]
    public function store(StoreAppointmentRequest $request): JsonResponse
    {
        $this->authorize('create', Appointment::class);

        $appointment = $this->appointmentService->create($request->user(), $request->validated());

        return $this->success(
            'Appointment created successfully.',
            AppointmentResource::make($appointment)->resolve(),
            201
        );
    }

    #[OA\Get(path: '/appointments/{id}', summary: 'Show appointment details', tags: ['Appointments'])]
    public function show(Request $request, Appointment $appointment): JsonResponse
    {
        $this->authorize('view', $appointment);

        $appointment = $this->appointmentService->findOrFail($request->user(), $appointment);

        return $this->success(
            'Appointment fetched successfully.',
            AppointmentResource::make($appointment)->resolve()
        );
    }

    #[OA\Put(path: '/appointments/{id}', summary: 'Update appointment', tags: ['Appointments'])]
    public function update(UpdateAppointmentRequest $request, Appointment $appointment): JsonResponse
    {
        $this->authorize('update', $appointment);

        $appointment = $this->appointmentService->update($request->user(), $appointment, $request->validated());

        return $this->success(
            'Appointment updated successfully.',
            AppointmentResource::make($appointment)->resolve()
        );
    }

    #[OA\Delete(path: '/appointments/{id}', summary: 'Delete appointment', tags: ['Appointments'])]
    public function destroy(Request $request, Appointment $appointment): JsonResponse
    {
        $this->authorize('delete', $appointment);
        $this->appointmentService->delete($request->user(), $appointment);

        return $this->success('Appointment deleted successfully.');
    }
}
