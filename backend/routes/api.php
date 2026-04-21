<?php

use App\Http\Controllers\API\V1\AuthController;
use App\Http\Controllers\API\V1\AppointmentController;
use App\Http\Controllers\API\V1\BranchController;
use App\Http\Controllers\API\V1\DashboardController;
use App\Http\Controllers\API\V1\DoctorController;
use App\Http\Controllers\API\V1\HealthController;
use App\Http\Controllers\API\V1\InvoiceController;
use App\Http\Controllers\API\V1\MetaController;
use App\Http\Controllers\API\V1\PatientController;
use App\Http\Controllers\API\V1\PaymentController;
use App\Http\Controllers\API\V1\ReportController;
use App\Http\Controllers\API\V1\ServiceController;
use App\Http\Controllers\API\V1\SettingsController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Clinic SaaS REST API
|--------------------------------------------------------------------------
| Versioned routes; JWT + RBAC applied in later steps.
*/

Route::prefix('v1')->group(function (): void {
    Route::get('/health', [HealthController::class, 'index']);
});

Route::get('/health', [HealthController::class, 'index']);
Route::get('/meta/app', [MetaController::class, 'app']);

Route::prefix('auth')->group(function (): void {
    Route::post('/login', [AuthController::class, 'login'])->middleware('throttle:login');

    Route::middleware('auth:api')->group(function (): void {
        Route::post('/logout', [AuthController::class, 'logout']);
        Route::post('/refresh', [AuthController::class, 'refresh']);
        Route::get('/me', [AuthController::class, 'me']);
    });
});

Route::middleware(['auth:api'])->group(function (): void {
    Route::get('/patients', [PatientController::class, 'index'])->middleware('permission:patients.view');
    Route::post('/patients', [PatientController::class, 'store'])->middleware('permission:patients.manage');
    Route::get('/patients/{patient}', [PatientController::class, 'show'])->middleware('permission:patients.view');
    Route::put('/patients/{patient}', [PatientController::class, 'update'])->middleware('permission:patients.manage');
    Route::delete('/patients/{patient}', [PatientController::class, 'destroy'])->middleware('permission:patients.manage');

    Route::get('/doctors', [DoctorController::class, 'index'])->middleware('permission:doctors.view|appointments.view');
    Route::post('/doctors', [DoctorController::class, 'store'])->middleware('permission:doctors.manage');
    Route::get('/doctors/{doctor}', [DoctorController::class, 'show'])->middleware('permission:doctors.view|appointments.view');
    Route::put('/doctors/{doctor}', [DoctorController::class, 'update'])->middleware('permission:doctors.manage');
    Route::delete('/doctors/{doctor}', [DoctorController::class, 'destroy'])->middleware('permission:doctors.manage');

    Route::get('/branches', [BranchController::class, 'index'])->middleware('permission:branches.view');
    Route::post('/branches', [BranchController::class, 'store'])->middleware('permission:branches.manage');
    Route::get('/branches/{branch}', [BranchController::class, 'show'])->middleware('permission:branches.view');
    Route::put('/branches/{branch}', [BranchController::class, 'update'])->middleware('permission:branches.manage');
    Route::delete('/branches/{branch}', [BranchController::class, 'destroy'])->middleware('permission:branches.manage');

    Route::get('/appointments', [AppointmentController::class, 'index'])->middleware('permission:appointments.view');
    Route::post('/appointments', [AppointmentController::class, 'store'])->middleware('permission:appointments.manage');
    Route::get('/appointments/{appointment}', [AppointmentController::class, 'show'])->middleware('permission:appointments.view');
    Route::put('/appointments/{appointment}', [AppointmentController::class, 'update'])->middleware('permission:appointments.manage');
    Route::delete('/appointments/{appointment}', [AppointmentController::class, 'destroy'])->middleware('permission:appointments.manage');

    Route::get('/services', [ServiceController::class, 'index'])->middleware('permission:services.manage|appointments.view|billing.view');
    Route::post('/services', [ServiceController::class, 'store'])->middleware('permission:services.manage');
    Route::get('/services/{service}', [ServiceController::class, 'show'])->middleware('permission:services.manage|appointments.view|billing.view');
    Route::put('/services/{service}', [ServiceController::class, 'update'])->middleware('permission:services.manage');
    Route::delete('/services/{service}', [ServiceController::class, 'destroy'])->middleware('permission:services.manage');

    Route::get('/invoices', [InvoiceController::class, 'index'])->middleware('permission:invoices.view|billing.view');
    Route::post('/invoices', [InvoiceController::class, 'store'])->middleware('permission:invoices.manage|billing.manage');
    Route::get('/invoices/{invoice}', [InvoiceController::class, 'show'])->middleware('permission:invoices.view|billing.view');
    Route::put('/invoices/{invoice}', [InvoiceController::class, 'update'])->middleware('permission:invoices.manage|billing.manage');
    Route::delete('/invoices/{invoice}', [InvoiceController::class, 'destroy'])->middleware('permission:invoices.manage|billing.manage');

    Route::get('/payments', [PaymentController::class, 'index'])->middleware('permission:payments.view|billing.view');
    Route::post('/payments', [PaymentController::class, 'store'])->middleware('permission:payments.manage|billing.manage');
    Route::get('/payments/{payment}', [PaymentController::class, 'show'])->middleware('permission:payments.view|billing.view');
    Route::delete('/payments/{payment}', [PaymentController::class, 'destroy'])->middleware('permission:payments.manage|billing.manage');

    Route::get('/dashboard/overview', [DashboardController::class, 'overview'])->middleware('permission:dashboard.view|reports.view');
    Route::get('/dashboard/revenue-summary', [DashboardController::class, 'revenueSummary'])->middleware('permission:dashboard.view|reports.view');
    Route::get('/dashboard/appointments-summary', [DashboardController::class, 'appointmentsSummary'])->middleware('permission:dashboard.view|reports.view');

    Route::get('/reports/revenue', [ReportController::class, 'revenue'])->middleware('permission:reports.view');
    Route::get('/reports/payments', [ReportController::class, 'payments'])->middleware('permission:reports.view');
    Route::get('/reports/appointments', [ReportController::class, 'appointments'])->middleware('permission:reports.view');
    Route::get('/reports/patients', [ReportController::class, 'patients'])->middleware('permission:reports.view');
    Route::get('/reports/doctors', [ReportController::class, 'doctors'])->middleware('permission:reports.view');
    Route::get('/reports/services', [ReportController::class, 'services'])->middleware('permission:reports.view');

    Route::get('/settings', [SettingsController::class, 'index'])->middleware('permission:settings.view|settings.manage');
    Route::put('/settings', [SettingsController::class, 'update'])->middleware('permission:settings.manage');
    Route::get('/settings/clinic-profile', [SettingsController::class, 'clinicProfile'])->middleware('permission:settings.view|settings.manage');
    Route::put('/settings/clinic-profile', [SettingsController::class, 'updateClinicProfile'])->middleware('permission:settings.manage');
    Route::get('/settings/invoice', [SettingsController::class, 'invoice'])->middleware('permission:settings.view|settings.manage');
    Route::put('/settings/invoice', [SettingsController::class, 'updateInvoice'])->middleware('permission:settings.manage');
});
