import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/appointments/presentation/appointment_details_page.dart';
import '../../features/appointments/presentation/appointment_form_page.dart';
import '../../features/appointments/presentation/appointments_list_page.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/branches/presentation/branch_details_page.dart';
import '../../features/branches/presentation/branch_form_page.dart';
import '../../features/branches/presentation/branches_list_page.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/billing/presentation/invoice_details_page.dart';
import '../../features/billing/presentation/invoice_form_page.dart';
import '../../features/billing/presentation/invoices_list_page.dart';
import '../../features/doctors/presentation/doctor_details_page.dart';
import '../../features/doctors/presentation/doctor_form_page.dart';
import '../../features/doctors/presentation/doctors_list_page.dart';
import '../../features/dashboard/presentation/dashboard_shell.dart';
import '../../features/patients/presentation/patient_details_page.dart';
import '../../features/patients/presentation/patient_form_page.dart';
import '../../features/patients/presentation/patients_list_page.dart';
import '../../features/reports/presentation/appointments_report_page.dart';
import '../../features/reports/presentation/doctors_report_page.dart';
import '../../features/reports/presentation/patients_report_page.dart';
import '../../features/reports/presentation/payments_report_page.dart';
import '../../features/reports/presentation/revenue_report_page.dart';
import '../../features/reports/presentation/services_report_page.dart';
import '../../features/services/presentation/service_details_page.dart';
import '../../features/services/presentation/service_form_page.dart';
import '../../features/services/presentation/services_list_page.dart';
import '../../features/settings/presentation/clinic_profile_settings_page.dart';
import '../../features/settings/presentation/general_settings_page.dart';
import '../../features/settings/presentation/invoice_settings_page.dart';
import '../../features/settings/presentation/settings_overview_page.dart';
import '../../features/splash/presentation/splash_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: SplashScreen.routePath,
    refreshListenable: auth,
    routes: [
      GoRoute(
        path: SplashScreen.routePath,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: LoginScreen.routePath,
        name: 'login',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: DashboardShell.routePath,
        name: 'dashboard',
        builder: (context, state) => const DashboardShell(),
      ),
      GoRoute(
        path: PatientsListPage.routePath,
        name: 'patients',
        builder: (context, state) => const PatientsListPage(),
      ),
      GoRoute(
        path: '/patients/new',
        name: 'patients-create',
        builder: (context, state) => const PatientFormPage(),
      ),
      GoRoute(
        path: '/patients/:id',
        name: 'patients-details',
        builder: (context, state) => PatientDetailsPage(
          patientId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/patients/:id/edit',
        name: 'patients-edit',
        builder: (context, state) => PatientFormPage(
          patientId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: AppointmentsListPage.routePath,
        name: 'appointments',
        builder: (context, state) => const AppointmentsListPage(),
      ),
      GoRoute(
        path: '/appointments/new',
        name: 'appointments-create',
        builder: (context, state) => const AppointmentFormPage(),
      ),
      GoRoute(
        path: '/appointments/:id',
        name: 'appointments-details',
        builder: (context, state) => AppointmentDetailsPage(
          appointmentId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/appointments/:id/edit',
        name: 'appointments-edit',
        builder: (context, state) => AppointmentFormPage(
          appointmentId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: InvoicesListPage.routePath,
        name: 'invoices',
        builder: (context, state) => const InvoicesListPage(),
      ),
      GoRoute(
        path: '/invoices/new',
        name: 'invoices-create',
        builder: (context, state) => const InvoiceFormPage(),
      ),
      GoRoute(
        path: '/invoices/:id',
        name: 'invoices-details',
        builder: (context, state) => InvoiceDetailsPage(
          invoiceId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/invoices/:id/edit',
        name: 'invoices-edit',
        builder: (context, state) => InvoiceFormPage(
          invoiceId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: DoctorsListPage.routePath,
        name: 'doctors',
        builder: (context, state) => const DoctorsListPage(),
      ),
      GoRoute(
        path: '/doctors/new',
        name: 'doctors-create',
        builder: (context, state) => const DoctorFormPage(),
      ),
      GoRoute(
        path: '/doctors/:id',
        name: 'doctors-details',
        builder: (context, state) => DoctorDetailsPage(
          doctorId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/doctors/:id/edit',
        name: 'doctors-edit',
        builder: (context, state) => DoctorFormPage(
          doctorId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: ServicesListPage.routePath,
        name: 'services',
        builder: (context, state) => const ServicesListPage(),
      ),
      GoRoute(
        path: '/services/new',
        name: 'services-create',
        builder: (context, state) => const ServiceFormPage(),
      ),
      GoRoute(
        path: '/services/:id',
        name: 'services-details',
        builder: (context, state) => ServiceDetailsPage(
          serviceId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/services/:id/edit',
        name: 'services-edit',
        builder: (context, state) => ServiceFormPage(
          serviceId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: RevenueReportPage.routePath,
        name: 'reports-revenue',
        builder: (context, state) => const RevenueReportPage(),
      ),
      GoRoute(
        path: PaymentsReportPage.routePath,
        name: 'reports-payments',
        builder: (context, state) => const PaymentsReportPage(),
      ),
      GoRoute(
        path: AppointmentsReportPage.routePath,
        name: 'reports-appointments',
        builder: (context, state) => const AppointmentsReportPage(),
      ),
      GoRoute(
        path: PatientsReportPage.routePath,
        name: 'reports-patients',
        builder: (context, state) => const PatientsReportPage(),
      ),
      GoRoute(
        path: DoctorsReportPage.routePath,
        name: 'reports-doctors',
        builder: (context, state) => const DoctorsReportPage(),
      ),
      GoRoute(
        path: ServicesReportPage.routePath,
        name: 'reports-services',
        builder: (context, state) => const ServicesReportPage(),
      ),
      GoRoute(
        path: BranchesListPage.routePath,
        name: 'branches',
        builder: (context, state) => const BranchesListPage(),
      ),
      GoRoute(
        path: BranchFormPage.createPath,
        name: 'branches-create',
        builder: (context, state) => const BranchFormPage(),
      ),
      GoRoute(
        path: '/branches/:id',
        name: 'branches-details',
        builder: (context, state) => BranchDetailsPage(
          branchId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/branches/:id/edit',
        name: 'branches-edit',
        builder: (context, state) => BranchFormPage(
          branchId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: SettingsOverviewPage.routePath,
        name: 'settings',
        builder: (context, state) => const SettingsOverviewPage(),
      ),
      GoRoute(
        path: GeneralSettingsPage.routePath,
        name: 'settings-general',
        builder: (context, state) => const GeneralSettingsPage(),
      ),
      GoRoute(
        path: ClinicProfileSettingsPage.routePath,
        name: 'settings-clinic-profile',
        builder: (context, state) => const ClinicProfileSettingsPage(),
      ),
      GoRoute(
        path: InvoiceSettingsPage.routePath,
        name: 'settings-invoice',
        builder: (context, state) => const InvoiceSettingsPage(),
      ),
    ],
    redirect: (context, state) {
      final isSplash = state.matchedLocation == SplashScreen.routePath;
      final isLogin = state.matchedLocation == LoginScreen.routePath;
      final isAuthenticated = auth.isAuthenticated;

      if (!auth.initialized) {
        return isSplash ? null : SplashScreen.routePath;
      }

      if (!isAuthenticated) {
        return isLogin ? null : LoginScreen.routePath;
      }

      if (isLogin || isSplash) {
        return DashboardShell.routePath;
      }

      return null;
    },
  );
});
