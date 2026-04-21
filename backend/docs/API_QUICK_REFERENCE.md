# Clinic API Quick Reference

This document provides a lightweight integration map for Flutter Web + Mobile clients.

## Base URL

- Local: `http://localhost:8000/api`

## Standard Response Shape

```json
{
  "success": true,
  "message": "Human readable message",
  "data": {},
  "errors": null
}
```

Validation errors use:

```json
{
  "success": false,
  "message": "Validation failed.",
  "data": null,
  "errors": {
    "field_name": ["Error message"]
  }
}
```

## Authentication Flow (JWT)

1. `POST /auth/login`
2. Save `data.access_token`
3. Send `Authorization: Bearer <token>` for protected routes
4. Use `POST /auth/refresh` to refresh token
5. Use `POST /auth/logout` to invalidate

## Flutter Request Headers

```http
Accept: application/json
Content-Type: application/json
Authorization: Bearer <jwt_access_token>
```

## Module Route Summary

### System
- `GET /health`
- `GET /v1/health`
- `GET /meta/app`

### Auth
- `POST /auth/login`
- `POST /auth/logout`
- `POST /auth/refresh`
- `GET /auth/me`

### Patients
- `GET /patients`
- `POST /patients`
- `GET /patients/{id}`
- `PUT /patients/{id}`
- `DELETE /patients/{id}`

### Doctors
- `GET /doctors`
- `POST /doctors`
- `GET /doctors/{id}`
- `PUT /doctors/{id}`
- `DELETE /doctors/{id}`

### Branches
- `GET /branches`
- `POST /branches`
- `GET /branches/{id}`
- `PUT /branches/{id}`
- `DELETE /branches/{id}`

### Appointments
- `GET /appointments`
- `POST /appointments`
- `GET /appointments/{id}`
- `PUT /appointments/{id}`
- `DELETE /appointments/{id}`

### Services
- `GET /services`
- `POST /services`
- `GET /services/{id}`
- `PUT /services/{id}`
- `DELETE /services/{id}`

### Billing
- Invoices:
  - `GET /invoices`
  - `POST /invoices`
  - `GET /invoices/{id}`
  - `PUT /invoices/{id}`
  - `DELETE /invoices/{id}`
- Payments:
  - `GET /payments`
  - `POST /payments`
  - `GET /payments/{id}`
  - `DELETE /payments/{id}`

### Dashboard
- `GET /dashboard/overview`
- `GET /dashboard/revenue-summary`
- `GET /dashboard/appointments-summary`

### Reports
- `GET /reports/revenue`
- `GET /reports/payments`
- `GET /reports/appointments`
- `GET /reports/patients`
- `GET /reports/doctors`
- `GET /reports/services`

### Settings
- `GET /settings`
- `PUT /settings`
- `GET /settings/clinic-profile`
- `PUT /settings/clinic-profile`
- `GET /settings/invoice`
- `PUT /settings/invoice`

## Demo Credentials

All seeded demo users use password: `password`

- `admin@clinic.test` (super_admin)
- `owner@clinic.test` (clinic_owner)
- `doctor@clinic.test` (doctor)
- `receptionist@clinic.test` (receptionist)
- `accountant@clinic.test` (accountant)
