import 'package:clinic_app/l10n/app_localizations.dart';

abstract final class ReportRoutes {
  static const revenue = '/reports/revenue';
  static const payments = '/reports/payments';
  static const appointments = '/reports/appointments';
  static const patients = '/reports/patients';
  static const doctors = '/reports/doctors';
  static const services = '/reports/services';
}

enum ReportType {
  revenue,
  payments,
  appointments,
  patients,
  doctors,
  services,
}

String reportPath(ReportType type) {
  return switch (type) {
    ReportType.revenue => ReportRoutes.revenue,
    ReportType.payments => ReportRoutes.payments,
    ReportType.appointments => ReportRoutes.appointments,
    ReportType.patients => ReportRoutes.patients,
    ReportType.doctors => ReportRoutes.doctors,
    ReportType.services => ReportRoutes.services,
  };
}

String reportLabel(AppLocalizations l10n, ReportType type) {
  return switch (type) {
    ReportType.revenue => l10n.reportTabRevenue,
    ReportType.payments => l10n.reportTabPayments,
    ReportType.appointments => l10n.reportTabAppointments,
    ReportType.patients => l10n.reportTabPatients,
    ReportType.doctors => l10n.reportTabDoctors,
    ReportType.services => l10n.reportTabServices,
  };
}
