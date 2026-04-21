// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Clinic OS';

  @override
  String get appBrandSubtitle => 'Operations, elevated.';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navReports => 'Reports';

  @override
  String get navPatients => 'Patients';

  @override
  String get navAppointments => 'Appointments';

  @override
  String get navBilling => 'Billing';

  @override
  String get navDoctors => 'Doctors';

  @override
  String get navServices => 'Services';

  @override
  String get navBranches => 'Branches';

  @override
  String get navSettings => 'Settings';

  @override
  String get commonSave => 'Save';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonSearch => 'Search';

  @override
  String get commonFilters => 'Filters';

  @override
  String get commonRefresh => 'Refresh';

  @override
  String get commonLoading => 'Loading…';

  @override
  String get commonError => 'Error';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonClose => 'Close';

  @override
  String get commonBack => 'Back';

  @override
  String get commonSubmit => 'Submit';

  @override
  String get commonApply => 'Apply';

  @override
  String get commonReset => 'Reset';

  @override
  String get commonView => 'View';

  @override
  String get commonTotal => 'Total';

  @override
  String get commonPage => 'Page';

  @override
  String get commonActions => 'Actions';

  @override
  String get commonAll => 'All';

  @override
  String get commonStatus => 'Status';

  @override
  String get commonDateRange => 'Date range';

  @override
  String get commonBranch => 'Branch';

  @override
  String get commonNotes => 'Notes';

  @override
  String get commonSaving => 'Saving…';

  @override
  String get commonTheme => 'Theme';

  @override
  String get commonToggleTheme => 'Toggle theme';

  @override
  String get commonAccount => 'Account';

  @override
  String get commonSignedIn => 'Signed in';

  @override
  String get commonUser => 'User';

  @override
  String get commonLogout => 'Log out';

  @override
  String get commonLanguage => 'Language';

  @override
  String get commonLanguageEnglish => 'English';

  @override
  String get commonLanguageArabic => 'العربية';

  @override
  String get commonEmpty => 'No data';

  @override
  String get commonDash => '—';

  @override
  String get commonExportCsvSoon => 'Export CSV (coming soon)';

  @override
  String loginWelcomeTitle(Object appName) {
    return 'Welcome to $appName';
  }

  @override
  String get loginSubtitle =>
      'Sign in to manage clinic operations, appointments, and billing.';

  @override
  String get loginWorkEmail => 'Work email';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginKeepSignedIn => 'Keep me signed in';

  @override
  String get loginSignIn => 'Sign in';

  @override
  String get loginEmailRequired => 'Email is required.';

  @override
  String get loginEmailInvalid => 'Enter a valid email.';

  @override
  String get loginPasswordRequired => 'Password is required.';

  @override
  String get loginWelcomeBackSnackbar =>
      'Welcome back. Redirecting to dashboard…';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get dashboardHeadline => 'Clinic performance';

  @override
  String get dashboardSubtitle =>
      'KPIs, revenue trends, and appointment mix for the selected branch and period.';

  @override
  String get dashboardBranchFilter => 'Branch filter';

  @override
  String get dashboardAllBranches => 'All branches';

  @override
  String dashboardFailedOverview(Object error) {
    return 'Failed to load overview: $error';
  }

  @override
  String dashboardFailedRevenue(Object error) {
    return 'Failed to load revenue summary: $error';
  }

  @override
  String dashboardFailedAppointments(Object error) {
    return 'Failed to load appointments summary: $error';
  }

  @override
  String get kpiTotalPatients => 'Total Patients';

  @override
  String get kpiActiveDoctors => 'Active Doctors';

  @override
  String get kpiTodayAppointments => 'Today Appointments';

  @override
  String get kpiUpcomingAppointments => 'Upcoming Appointments';

  @override
  String get kpiPaidInvoices => 'Paid Invoices';

  @override
  String get kpiOpenInvoices => 'Open Invoices';

  @override
  String get kpiTotalRevenue => 'Total Revenue';

  @override
  String get kpiOutstandingBalance => 'Outstanding Balance';

  @override
  String get panelRevenueSummary => 'Revenue Summary';

  @override
  String get panelAppointmentsSummary => 'Appointments Summary';

  @override
  String get statToday => 'Today';

  @override
  String get statThisWeek => 'This Week';

  @override
  String get statThisMonth => 'This Month';

  @override
  String get statPaid => 'Paid';

  @override
  String get statUnpaid => 'Unpaid';

  @override
  String get statPartial => 'Partial';

  @override
  String get statBooked => 'Booked';

  @override
  String get statCompleted => 'Completed';

  @override
  String get statCancelled => 'Cancelled';

  @override
  String get statNoShow => 'No Show';

  @override
  String get statUpcoming => 'Upcoming';

  @override
  String get chartNoData => 'No chart data';

  @override
  String get reportsShellTitle => 'Reports';

  @override
  String get reportTabRevenue => 'Revenue';

  @override
  String get reportTabPayments => 'Payments';

  @override
  String get reportTabAppointments => 'Appointments';

  @override
  String get reportTabPatients => 'Patients';

  @override
  String get reportTabDoctors => 'Doctors';

  @override
  String get reportTabServices => 'Services';

  @override
  String get reportTitleRevenue => 'Revenue Report';

  @override
  String get reportTitlePayments => 'Payments Report';

  @override
  String get reportTitleAppointments => 'Appointments Report';

  @override
  String get reportTitlePatients => 'Patients Report';

  @override
  String get reportTitleDoctors => 'Doctors Report';

  @override
  String get reportTitleServices => 'Services Report';

  @override
  String get reportExportComing =>
      'CSV export will connect to the API in a future release.';

  @override
  String reportFailedLoad(Object error) {
    return 'Failed to load report: $error';
  }

  @override
  String get reportEmpty => 'No report data.';

  @override
  String get reportTotalInvoiced => 'Total Invoiced';

  @override
  String get reportRemaining => 'Remaining';

  @override
  String get reportInvoicesCount => 'Invoices';

  @override
  String get invoiceNumber => 'Invoice #';

  @override
  String get invoiceIssued => 'Issued';

  @override
  String get invoiceTotal => 'Total';

  @override
  String get invoicePaid => 'Paid';

  @override
  String get settingsShellTitle => 'Settings';

  @override
  String get settingsNavOverview => 'Overview';

  @override
  String get settingsNavGeneral => 'General';

  @override
  String get settingsNavClinicProfile => 'Clinic profile';

  @override
  String get settingsNavInvoice => 'Invoice';

  @override
  String get patientsTitle => 'Patients';

  @override
  String get patientsDeleteTitle => 'Delete patient?';

  @override
  String patientsDeleteBody(Object name) {
    return 'This will soft-delete \"$name\". You can keep historical records.';
  }

  @override
  String get patientsDeleted => 'Patient deleted successfully.';

  @override
  String get patientsDeleteFailed => 'Delete failed.';

  @override
  String get patientsNew => 'New patient';

  @override
  String get patientsSearchHint => 'Name, phone, code';

  @override
  String get patientsGender => 'Gender';

  @override
  String get patientsDob => 'DOB';

  @override
  String get patientsBranchId => 'Branch ID';

  @override
  String get patientsCode => 'Code';

  @override
  String get patientsFullName => 'Full Name';

  @override
  String get patientsPhone => 'Phone';

  @override
  String get patientsNoResults => 'No patients found.';

  @override
  String get patientsNoResultsHint =>
      'Try changing filters or add a new patient.';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get genderOther => 'Other';

  @override
  String get genderUnknown => 'Unknown';

  @override
  String get statusActive => 'Active';

  @override
  String get statusInactive => 'Inactive';

  @override
  String get appointmentsTitle => 'Appointments';

  @override
  String get appointmentsNew => 'New appointment';

  @override
  String get billingTitle => 'Billing';

  @override
  String get billingInvoices => 'Invoices';

  @override
  String get billingNewInvoice => 'New invoice';

  @override
  String get doctorsTitle => 'Doctors';

  @override
  String get doctorsNew => 'New doctor';

  @override
  String get servicesTitle => 'Services';

  @override
  String get servicesNew => 'New service';

  @override
  String get branchesTitle => 'Branches';

  @override
  String get branchesNew => 'New branch';

  @override
  String get invoiceStatusPaid => 'Paid';

  @override
  String get invoiceStatusUnpaid => 'Unpaid';

  @override
  String get invoiceStatusPartiallyPaid => 'Partially paid';

  @override
  String get invoiceStatusCancelled => 'Cancelled';

  @override
  String get invoiceStatusDraft => 'Draft';

  @override
  String get patientLabel => 'Patient';

  @override
  String get doctorLabel => 'Doctor';

  @override
  String get serviceLabel => 'Service';

  @override
  String get appointmentLabel => 'Appointment';

  @override
  String get branchLabel => 'Branch';

  @override
  String get formRequiredFieldsAppointment =>
      'Patient, doctor, date and time are required.';

  @override
  String get formEndAfterStart => 'End time must be after start time.';

  @override
  String get formPatientRequired => 'Patient is required.';

  @override
  String get formInvoiceItemsRequired =>
      'At least one invoice item is required.';

  @override
  String formInvalidLineItem(int index) {
    return 'Invalid quantity/unit price at item $index.';
  }

  @override
  String get appointmentConflict =>
      'Time conflict detected. Please choose a different schedule slot.';

  @override
  String get appointmentUpdated => 'Appointment updated.';

  @override
  String get appointmentCreated => 'Appointment created.';

  @override
  String get appointmentEditTitle => 'Edit appointment';

  @override
  String get appointmentCreateTitle => 'Schedule appointment';

  @override
  String appointmentLoadFailed(Object error) {
    return 'Failed to load appointment.\n$error';
  }

  @override
  String get sectionPeopleService => 'People & service';

  @override
  String get sectionPeopleServiceHint =>
      'Search by name or code — no manual IDs.';

  @override
  String get sectionSchedule => 'Schedule';

  @override
  String get fieldAppointmentDate => 'Appointment date';

  @override
  String get fieldStartTime => 'Start time';

  @override
  String get fieldEndTime => 'End time';

  @override
  String get fieldStatus => 'Status';

  @override
  String get statusNotSet => 'Not set';

  @override
  String get statusBooked => 'Booked';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusNoShow => 'No show';

  @override
  String get appointmentUpdateButton => 'Update appointment';

  @override
  String get appointmentCreateButton => 'Create appointment';

  @override
  String get invoiceUpdated => 'Invoice updated.';

  @override
  String get invoiceCreated => 'Invoice created.';

  @override
  String get invoiceEditTitle => 'Edit invoice';

  @override
  String get invoiceCreateTitle => 'Create invoice';

  @override
  String invoiceLoadFailed(Object error) {
    return 'Failed to load invoice.\n$error';
  }

  @override
  String get invoiceSaveFailed => 'Failed to save invoice.';

  @override
  String get sectionParties => 'Parties';

  @override
  String get sectionPartiesHint =>
      'Link patient, optional appointment, and branch using search.';

  @override
  String invoiceAppointmentRef(Object id) {
    return 'Appointment #$id';
  }
}
