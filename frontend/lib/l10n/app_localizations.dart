import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Clinic OS'**
  String get appTitle;

  /// No description provided for @appBrandSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Operations, elevated.'**
  String get appBrandSubtitle;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get navReports;

  /// No description provided for @navPatients.
  ///
  /// In en, this message translates to:
  /// **'Patients'**
  String get navPatients;

  /// No description provided for @navAppointments.
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get navAppointments;

  /// No description provided for @navBilling.
  ///
  /// In en, this message translates to:
  /// **'Billing'**
  String get navBilling;

  /// No description provided for @navDoctors.
  ///
  /// In en, this message translates to:
  /// **'Doctors'**
  String get navDoctors;

  /// No description provided for @navServices.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get navServices;

  /// No description provided for @navBranches.
  ///
  /// In en, this message translates to:
  /// **'Branches'**
  String get navBranches;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get commonSearch;

  /// No description provided for @commonFilters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get commonFilters;

  /// No description provided for @commonRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get commonRefresh;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get commonLoading;

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get commonError;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get commonSubmit;

  /// No description provided for @commonApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get commonApply;

  /// No description provided for @commonReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get commonReset;

  /// No description provided for @commonView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get commonView;

  /// No description provided for @commonTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get commonTotal;

  /// No description provided for @commonPage.
  ///
  /// In en, this message translates to:
  /// **'Page'**
  String get commonPage;

  /// No description provided for @commonActions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get commonActions;

  /// No description provided for @commonAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get commonAll;

  /// No description provided for @commonStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get commonStatus;

  /// No description provided for @commonDateRange.
  ///
  /// In en, this message translates to:
  /// **'Date range'**
  String get commonDateRange;

  /// No description provided for @commonBranch.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get commonBranch;

  /// No description provided for @commonNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get commonNotes;

  /// No description provided for @commonSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get commonSaving;

  /// No description provided for @commonTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get commonTheme;

  /// No description provided for @commonToggleTheme.
  ///
  /// In en, this message translates to:
  /// **'Toggle theme'**
  String get commonToggleTheme;

  /// No description provided for @commonAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get commonAccount;

  /// No description provided for @commonSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Signed in'**
  String get commonSignedIn;

  /// No description provided for @commonUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get commonUser;

  /// No description provided for @commonLogout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get commonLogout;

  /// No description provided for @commonLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get commonLanguage;

  /// No description provided for @commonLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get commonLanguageEnglish;

  /// No description provided for @commonLanguageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get commonLanguageArabic;

  /// No description provided for @commonEmpty.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get commonEmpty;

  /// No description provided for @commonDash.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get commonDash;

  /// No description provided for @commonExportCsvSoon.
  ///
  /// In en, this message translates to:
  /// **'Export CSV (coming soon)'**
  String get commonExportCsvSoon;

  /// No description provided for @loginWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to {appName}'**
  String loginWelcomeTitle(Object appName);

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to manage clinic operations, appointments, and billing.'**
  String get loginSubtitle;

  /// No description provided for @loginWorkEmail.
  ///
  /// In en, this message translates to:
  /// **'Work email'**
  String get loginWorkEmail;

  /// No description provided for @loginPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPassword;

  /// No description provided for @loginKeepSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Keep me signed in'**
  String get loginKeepSignedIn;

  /// No description provided for @loginSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginSignIn;

  /// No description provided for @loginEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required.'**
  String get loginEmailRequired;

  /// No description provided for @loginEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email.'**
  String get loginEmailInvalid;

  /// No description provided for @loginPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required.'**
  String get loginPasswordRequired;

  /// No description provided for @loginWelcomeBackSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Welcome back. Redirecting to dashboard…'**
  String get loginWelcomeBackSnackbar;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @dashboardHeadline.
  ///
  /// In en, this message translates to:
  /// **'Clinic performance'**
  String get dashboardHeadline;

  /// No description provided for @dashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'KPIs, revenue trends, and appointment mix for the selected branch and period.'**
  String get dashboardSubtitle;

  /// No description provided for @dashboardBranchFilter.
  ///
  /// In en, this message translates to:
  /// **'Branch filter'**
  String get dashboardBranchFilter;

  /// No description provided for @dashboardAllBranches.
  ///
  /// In en, this message translates to:
  /// **'All branches'**
  String get dashboardAllBranches;

  /// No description provided for @dashboardFailedOverview.
  ///
  /// In en, this message translates to:
  /// **'Failed to load overview: {error}'**
  String dashboardFailedOverview(Object error);

  /// No description provided for @dashboardFailedRevenue.
  ///
  /// In en, this message translates to:
  /// **'Failed to load revenue summary: {error}'**
  String dashboardFailedRevenue(Object error);

  /// No description provided for @dashboardFailedAppointments.
  ///
  /// In en, this message translates to:
  /// **'Failed to load appointments summary: {error}'**
  String dashboardFailedAppointments(Object error);

  /// No description provided for @kpiTotalPatients.
  ///
  /// In en, this message translates to:
  /// **'Total Patients'**
  String get kpiTotalPatients;

  /// No description provided for @kpiActiveDoctors.
  ///
  /// In en, this message translates to:
  /// **'Active Doctors'**
  String get kpiActiveDoctors;

  /// No description provided for @kpiTodayAppointments.
  ///
  /// In en, this message translates to:
  /// **'Today Appointments'**
  String get kpiTodayAppointments;

  /// No description provided for @kpiUpcomingAppointments.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Appointments'**
  String get kpiUpcomingAppointments;

  /// No description provided for @kpiPaidInvoices.
  ///
  /// In en, this message translates to:
  /// **'Paid Invoices'**
  String get kpiPaidInvoices;

  /// No description provided for @kpiOpenInvoices.
  ///
  /// In en, this message translates to:
  /// **'Open Invoices'**
  String get kpiOpenInvoices;

  /// No description provided for @kpiTotalRevenue.
  ///
  /// In en, this message translates to:
  /// **'Total Revenue'**
  String get kpiTotalRevenue;

  /// No description provided for @kpiOutstandingBalance.
  ///
  /// In en, this message translates to:
  /// **'Outstanding Balance'**
  String get kpiOutstandingBalance;

  /// No description provided for @panelRevenueSummary.
  ///
  /// In en, this message translates to:
  /// **'Revenue Summary'**
  String get panelRevenueSummary;

  /// No description provided for @panelAppointmentsSummary.
  ///
  /// In en, this message translates to:
  /// **'Appointments Summary'**
  String get panelAppointmentsSummary;

  /// No description provided for @statToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get statToday;

  /// No description provided for @statThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get statThisWeek;

  /// No description provided for @statThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get statThisMonth;

  /// No description provided for @statPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get statPaid;

  /// No description provided for @statUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get statUnpaid;

  /// No description provided for @statPartial.
  ///
  /// In en, this message translates to:
  /// **'Partial'**
  String get statPartial;

  /// No description provided for @statBooked.
  ///
  /// In en, this message translates to:
  /// **'Booked'**
  String get statBooked;

  /// No description provided for @statCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statCompleted;

  /// No description provided for @statCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statCancelled;

  /// No description provided for @statNoShow.
  ///
  /// In en, this message translates to:
  /// **'No Show'**
  String get statNoShow;

  /// No description provided for @statUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get statUpcoming;

  /// No description provided for @chartNoData.
  ///
  /// In en, this message translates to:
  /// **'No chart data'**
  String get chartNoData;

  /// No description provided for @reportsShellTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reportsShellTitle;

  /// No description provided for @reportTabRevenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get reportTabRevenue;

  /// No description provided for @reportTabPayments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get reportTabPayments;

  /// No description provided for @reportTabAppointments.
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get reportTabAppointments;

  /// No description provided for @reportTabPatients.
  ///
  /// In en, this message translates to:
  /// **'Patients'**
  String get reportTabPatients;

  /// No description provided for @reportTabDoctors.
  ///
  /// In en, this message translates to:
  /// **'Doctors'**
  String get reportTabDoctors;

  /// No description provided for @reportTabServices.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get reportTabServices;

  /// No description provided for @reportTitleRevenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue Report'**
  String get reportTitleRevenue;

  /// No description provided for @reportTitlePayments.
  ///
  /// In en, this message translates to:
  /// **'Payments Report'**
  String get reportTitlePayments;

  /// No description provided for @reportTitleAppointments.
  ///
  /// In en, this message translates to:
  /// **'Appointments Report'**
  String get reportTitleAppointments;

  /// No description provided for @reportTitlePatients.
  ///
  /// In en, this message translates to:
  /// **'Patients Report'**
  String get reportTitlePatients;

  /// No description provided for @reportTitleDoctors.
  ///
  /// In en, this message translates to:
  /// **'Doctors Report'**
  String get reportTitleDoctors;

  /// No description provided for @reportTitleServices.
  ///
  /// In en, this message translates to:
  /// **'Services Report'**
  String get reportTitleServices;

  /// No description provided for @reportExportComing.
  ///
  /// In en, this message translates to:
  /// **'CSV export will connect to the API in a future release.'**
  String get reportExportComing;

  /// No description provided for @reportFailedLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load report: {error}'**
  String reportFailedLoad(Object error);

  /// No description provided for @reportEmpty.
  ///
  /// In en, this message translates to:
  /// **'No report data.'**
  String get reportEmpty;

  /// No description provided for @reportTotalInvoiced.
  ///
  /// In en, this message translates to:
  /// **'Total Invoiced'**
  String get reportTotalInvoiced;

  /// No description provided for @reportRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get reportRemaining;

  /// No description provided for @reportInvoicesCount.
  ///
  /// In en, this message translates to:
  /// **'Invoices'**
  String get reportInvoicesCount;

  /// No description provided for @invoiceNumber.
  ///
  /// In en, this message translates to:
  /// **'Invoice #'**
  String get invoiceNumber;

  /// No description provided for @invoiceIssued.
  ///
  /// In en, this message translates to:
  /// **'Issued'**
  String get invoiceIssued;

  /// No description provided for @invoiceTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get invoiceTotal;

  /// No description provided for @invoicePaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get invoicePaid;

  /// No description provided for @settingsShellTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsShellTitle;

  /// No description provided for @settingsNavOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get settingsNavOverview;

  /// No description provided for @settingsNavGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsNavGeneral;

  /// No description provided for @settingsNavClinicProfile.
  ///
  /// In en, this message translates to:
  /// **'Clinic profile'**
  String get settingsNavClinicProfile;

  /// No description provided for @settingsNavInvoice.
  ///
  /// In en, this message translates to:
  /// **'Invoice'**
  String get settingsNavInvoice;

  /// No description provided for @patientsTitle.
  ///
  /// In en, this message translates to:
  /// **'Patients'**
  String get patientsTitle;

  /// No description provided for @patientsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete patient?'**
  String get patientsDeleteTitle;

  /// No description provided for @patientsDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This will soft-delete \"{name}\". You can keep historical records.'**
  String patientsDeleteBody(Object name);

  /// No description provided for @patientsDeleted.
  ///
  /// In en, this message translates to:
  /// **'Patient deleted successfully.'**
  String get patientsDeleted;

  /// No description provided for @patientsDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Delete failed.'**
  String get patientsDeleteFailed;

  /// No description provided for @patientsNew.
  ///
  /// In en, this message translates to:
  /// **'New patient'**
  String get patientsNew;

  /// No description provided for @patientsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Name, phone, code'**
  String get patientsSearchHint;

  /// No description provided for @patientsGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get patientsGender;

  /// No description provided for @patientsDob.
  ///
  /// In en, this message translates to:
  /// **'DOB'**
  String get patientsDob;

  /// No description provided for @patientsBranchId.
  ///
  /// In en, this message translates to:
  /// **'Branch ID'**
  String get patientsBranchId;

  /// No description provided for @patientsCode.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get patientsCode;

  /// No description provided for @patientsFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get patientsFullName;

  /// No description provided for @patientsPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get patientsPhone;

  /// No description provided for @patientsNoResults.
  ///
  /// In en, this message translates to:
  /// **'No patients found.'**
  String get patientsNoResults;

  /// No description provided for @patientsNoResultsHint.
  ///
  /// In en, this message translates to:
  /// **'Try changing filters or add a new patient.'**
  String get patientsNoResultsHint;

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// No description provided for @genderOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get genderOther;

  /// No description provided for @genderUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get genderUnknown;

  /// No description provided for @statusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statusActive;

  /// No description provided for @statusInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get statusInactive;

  /// No description provided for @appointmentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get appointmentsTitle;

  /// No description provided for @appointmentsNew.
  ///
  /// In en, this message translates to:
  /// **'New appointment'**
  String get appointmentsNew;

  /// No description provided for @billingTitle.
  ///
  /// In en, this message translates to:
  /// **'Billing'**
  String get billingTitle;

  /// No description provided for @billingInvoices.
  ///
  /// In en, this message translates to:
  /// **'Invoices'**
  String get billingInvoices;

  /// No description provided for @billingNewInvoice.
  ///
  /// In en, this message translates to:
  /// **'New invoice'**
  String get billingNewInvoice;

  /// No description provided for @doctorsTitle.
  ///
  /// In en, this message translates to:
  /// **'Doctors'**
  String get doctorsTitle;

  /// No description provided for @doctorsNew.
  ///
  /// In en, this message translates to:
  /// **'New doctor'**
  String get doctorsNew;

  /// No description provided for @servicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get servicesTitle;

  /// No description provided for @servicesNew.
  ///
  /// In en, this message translates to:
  /// **'New service'**
  String get servicesNew;

  /// No description provided for @branchesTitle.
  ///
  /// In en, this message translates to:
  /// **'Branches'**
  String get branchesTitle;

  /// No description provided for @branchesNew.
  ///
  /// In en, this message translates to:
  /// **'New branch'**
  String get branchesNew;

  /// No description provided for @invoiceStatusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get invoiceStatusPaid;

  /// No description provided for @invoiceStatusUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get invoiceStatusUnpaid;

  /// No description provided for @invoiceStatusPartiallyPaid.
  ///
  /// In en, this message translates to:
  /// **'Partially paid'**
  String get invoiceStatusPartiallyPaid;

  /// No description provided for @invoiceStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get invoiceStatusCancelled;

  /// No description provided for @invoiceStatusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get invoiceStatusDraft;

  /// No description provided for @patientLabel.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get patientLabel;

  /// No description provided for @doctorLabel.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get doctorLabel;

  /// No description provided for @serviceLabel.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get serviceLabel;

  /// No description provided for @appointmentLabel.
  ///
  /// In en, this message translates to:
  /// **'Appointment'**
  String get appointmentLabel;

  /// No description provided for @branchLabel.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get branchLabel;

  /// No description provided for @formRequiredFieldsAppointment.
  ///
  /// In en, this message translates to:
  /// **'Patient, doctor, date and time are required.'**
  String get formRequiredFieldsAppointment;

  /// No description provided for @formEndAfterStart.
  ///
  /// In en, this message translates to:
  /// **'End time must be after start time.'**
  String get formEndAfterStart;

  /// No description provided for @formPatientRequired.
  ///
  /// In en, this message translates to:
  /// **'Patient is required.'**
  String get formPatientRequired;

  /// No description provided for @formInvoiceItemsRequired.
  ///
  /// In en, this message translates to:
  /// **'At least one invoice item is required.'**
  String get formInvoiceItemsRequired;

  /// No description provided for @formInvalidLineItem.
  ///
  /// In en, this message translates to:
  /// **'Invalid quantity/unit price at item {index}.'**
  String formInvalidLineItem(int index);

  /// No description provided for @appointmentConflict.
  ///
  /// In en, this message translates to:
  /// **'Time conflict detected. Please choose a different schedule slot.'**
  String get appointmentConflict;

  /// No description provided for @appointmentUpdated.
  ///
  /// In en, this message translates to:
  /// **'Appointment updated.'**
  String get appointmentUpdated;

  /// No description provided for @appointmentCreated.
  ///
  /// In en, this message translates to:
  /// **'Appointment created.'**
  String get appointmentCreated;

  /// No description provided for @appointmentEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit appointment'**
  String get appointmentEditTitle;

  /// No description provided for @appointmentCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Schedule appointment'**
  String get appointmentCreateTitle;

  /// No description provided for @appointmentLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load appointment.\n{error}'**
  String appointmentLoadFailed(Object error);

  /// No description provided for @sectionPeopleService.
  ///
  /// In en, this message translates to:
  /// **'People & service'**
  String get sectionPeopleService;

  /// No description provided for @sectionPeopleServiceHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or code — no manual IDs.'**
  String get sectionPeopleServiceHint;

  /// No description provided for @sectionSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get sectionSchedule;

  /// No description provided for @fieldAppointmentDate.
  ///
  /// In en, this message translates to:
  /// **'Appointment date'**
  String get fieldAppointmentDate;

  /// No description provided for @fieldStartTime.
  ///
  /// In en, this message translates to:
  /// **'Start time'**
  String get fieldStartTime;

  /// No description provided for @fieldEndTime.
  ///
  /// In en, this message translates to:
  /// **'End time'**
  String get fieldEndTime;

  /// No description provided for @fieldStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get fieldStatus;

  /// No description provided for @statusNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get statusNotSet;

  /// No description provided for @statusBooked.
  ///
  /// In en, this message translates to:
  /// **'Booked'**
  String get statusBooked;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusNoShow.
  ///
  /// In en, this message translates to:
  /// **'No show'**
  String get statusNoShow;

  /// No description provided for @appointmentUpdateButton.
  ///
  /// In en, this message translates to:
  /// **'Update appointment'**
  String get appointmentUpdateButton;

  /// No description provided for @appointmentCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Create appointment'**
  String get appointmentCreateButton;

  /// No description provided for @invoiceUpdated.
  ///
  /// In en, this message translates to:
  /// **'Invoice updated.'**
  String get invoiceUpdated;

  /// No description provided for @invoiceCreated.
  ///
  /// In en, this message translates to:
  /// **'Invoice created.'**
  String get invoiceCreated;

  /// No description provided for @invoiceEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit invoice'**
  String get invoiceEditTitle;

  /// No description provided for @invoiceCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create invoice'**
  String get invoiceCreateTitle;

  /// No description provided for @invoiceLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load invoice.\n{error}'**
  String invoiceLoadFailed(Object error);

  /// No description provided for @invoiceSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save invoice.'**
  String get invoiceSaveFailed;

  /// No description provided for @sectionParties.
  ///
  /// In en, this message translates to:
  /// **'Parties'**
  String get sectionParties;

  /// No description provided for @sectionPartiesHint.
  ///
  /// In en, this message translates to:
  /// **'Link patient, optional appointment, and branch using search.'**
  String get sectionPartiesHint;

  /// No description provided for @invoiceAppointmentRef.
  ///
  /// In en, this message translates to:
  /// **'Appointment #{id}'**
  String invoiceAppointmentRef(Object id);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
