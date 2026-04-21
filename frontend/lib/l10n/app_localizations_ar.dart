// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Clinic OS';

  @override
  String get appBrandSubtitle => 'تشغيل العيادة بكفاءة أعلى.';

  @override
  String get navDashboard => 'لوحة التحكم';

  @override
  String get navReports => 'التقارير';

  @override
  String get navPatients => 'المرضى';

  @override
  String get navAppointments => 'المواعيد';

  @override
  String get navBilling => 'الفوترة';

  @override
  String get navDoctors => 'الأطباء';

  @override
  String get navServices => 'الخدمات';

  @override
  String get navBranches => 'الفروع';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get commonSave => 'حفظ';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonDelete => 'حذف';

  @override
  String get commonEdit => 'تعديل';

  @override
  String get commonSearch => 'بحث';

  @override
  String get commonFilters => 'عوامل التصفية';

  @override
  String get commonRefresh => 'تحديث';

  @override
  String get commonLoading => 'جارٍ التحميل…';

  @override
  String get commonError => 'خطأ';

  @override
  String get commonRetry => 'إعادة المحاولة';

  @override
  String get commonClose => 'إغلاق';

  @override
  String get commonBack => 'رجوع';

  @override
  String get commonSubmit => 'إرسال';

  @override
  String get commonApply => 'تطبيق';

  @override
  String get commonReset => 'إعادة ضبط';

  @override
  String get commonView => 'عرض';

  @override
  String get commonTotal => 'الإجمالي';

  @override
  String get commonPage => 'صفحة';

  @override
  String get commonActions => 'إجراءات';

  @override
  String get commonAll => 'الكل';

  @override
  String get commonStatus => 'الحالة';

  @override
  String get commonDateRange => 'نطاق التاريخ';

  @override
  String get commonBranch => 'الفرع';

  @override
  String get commonNotes => 'ملاحظات';

  @override
  String get commonSaving => 'جارٍ الحفظ…';

  @override
  String get commonTheme => 'المظهر';

  @override
  String get commonToggleTheme => 'تبديل المظهر';

  @override
  String get commonAccount => 'الحساب';

  @override
  String get commonSignedIn => 'مسجّل الدخول';

  @override
  String get commonUser => 'مستخدم';

  @override
  String get commonLogout => 'تسجيل الخروج';

  @override
  String get commonLanguage => 'اللغة';

  @override
  String get commonLanguageEnglish => 'English';

  @override
  String get commonLanguageArabic => 'العربية';

  @override
  String get commonEmpty => 'لا توجد بيانات';

  @override
  String get commonDash => '—';

  @override
  String get commonExportCsvSoon => 'تصدير CSV (قريباً)';

  @override
  String loginWelcomeTitle(Object appName) {
    return 'مرحباً بك في $appName';
  }

  @override
  String get loginSubtitle => 'سجّل الدخول لإدارة العيادة والمواعيد والفوترة.';

  @override
  String get loginWorkEmail => 'البريد المهني';

  @override
  String get loginPassword => 'كلمة المرور';

  @override
  String get loginKeepSignedIn => 'إبقائي مسجّلاً';

  @override
  String get loginSignIn => 'تسجيل الدخول';

  @override
  String get loginEmailRequired => 'البريد مطلوب.';

  @override
  String get loginEmailInvalid => 'أدخل بريداً صالحاً.';

  @override
  String get loginPasswordRequired => 'كلمة المرور مطلوبة.';

  @override
  String get loginWelcomeBackSnackbar =>
      'مرحباً بعودتك. جارٍ التوجيه إلى لوحة التحكم…';

  @override
  String get dashboardTitle => 'لوحة التحكم';

  @override
  String get dashboardHeadline => 'أداء العيادة';

  @override
  String get dashboardSubtitle =>
      'مؤشرات الأداء واتجاهات الإيرادات وتوزيع المواعيد للفرع والفترة المحددة.';

  @override
  String get dashboardBranchFilter => 'تصفية الفرع';

  @override
  String get dashboardAllBranches => 'كل الفروع';

  @override
  String dashboardFailedOverview(Object error) {
    return 'تعذّر تحميل النظرة العامة: $error';
  }

  @override
  String dashboardFailedRevenue(Object error) {
    return 'تعذّر تحميل ملخص الإيرادات: $error';
  }

  @override
  String dashboardFailedAppointments(Object error) {
    return 'تعذّر تحميل ملخص المواعيد: $error';
  }

  @override
  String get kpiTotalPatients => 'إجمالي المرضى';

  @override
  String get kpiActiveDoctors => 'الأطباء النشطون';

  @override
  String get kpiTodayAppointments => 'مواعيد اليوم';

  @override
  String get kpiUpcomingAppointments => 'المواعيد القادمة';

  @override
  String get kpiPaidInvoices => 'الفواتير المدفوعة';

  @override
  String get kpiOpenInvoices => 'الفواتير المفتوحة';

  @override
  String get kpiTotalRevenue => 'إجمالي الإيرادات';

  @override
  String get kpiOutstandingBalance => 'الرصيد المستحق';

  @override
  String get panelRevenueSummary => 'ملخص الإيرادات';

  @override
  String get panelAppointmentsSummary => 'ملخص المواعيد';

  @override
  String get statToday => 'اليوم';

  @override
  String get statThisWeek => 'هذا الأسبوع';

  @override
  String get statThisMonth => 'هذا الشهر';

  @override
  String get statPaid => 'مدفوع';

  @override
  String get statUnpaid => 'غير مدفوع';

  @override
  String get statPartial => 'جزئي';

  @override
  String get statBooked => 'محجوز';

  @override
  String get statCompleted => 'مكتمل';

  @override
  String get statCancelled => 'ملغى';

  @override
  String get statNoShow => 'لم يحضر';

  @override
  String get statUpcoming => 'قادم';

  @override
  String get chartNoData => 'لا توجد بيانات للرسم';

  @override
  String get reportsShellTitle => 'التقارير';

  @override
  String get reportTabRevenue => 'الإيرادات';

  @override
  String get reportTabPayments => 'المدفوعات';

  @override
  String get reportTabAppointments => 'المواعيد';

  @override
  String get reportTabPatients => 'المرضى';

  @override
  String get reportTabDoctors => 'الأطباء';

  @override
  String get reportTabServices => 'الخدمات';

  @override
  String get reportTitleRevenue => 'تقرير الإيرادات';

  @override
  String get reportTitlePayments => 'تقرير المدفوعات';

  @override
  String get reportTitleAppointments => 'تقرير المواعيد';

  @override
  String get reportTitlePatients => 'تقرير المرضى';

  @override
  String get reportTitleDoctors => 'تقرير الأطباء';

  @override
  String get reportTitleServices => 'تقرير الخدمات';

  @override
  String get reportExportComing =>
      'سيتم ربط التصدير بالواجهة البرمجية في إصدار لاحق.';

  @override
  String reportFailedLoad(Object error) {
    return 'تعذّر تحميل التقرير: $error';
  }

  @override
  String get reportEmpty => 'لا توجد بيانات للتقرير.';

  @override
  String get reportTotalInvoiced => 'إجمالي الفوترة';

  @override
  String get reportRemaining => 'المتبقي';

  @override
  String get reportInvoicesCount => 'الفواتير';

  @override
  String get invoiceNumber => 'رقم الفاتورة';

  @override
  String get invoiceIssued => 'تاريخ الإصدار';

  @override
  String get invoiceTotal => 'الإجمالي';

  @override
  String get invoicePaid => 'المدفوع';

  @override
  String get settingsShellTitle => 'الإعدادات';

  @override
  String get settingsNavOverview => 'نظرة عامة';

  @override
  String get settingsNavGeneral => 'عام';

  @override
  String get settingsNavClinicProfile => 'ملف العيادة';

  @override
  String get settingsNavInvoice => 'الفاتورة';

  @override
  String get patientsTitle => 'المرضى';

  @override
  String get patientsDeleteTitle => 'حذف المريض؟';

  @override
  String patientsDeleteBody(Object name) {
    return 'سيتم حذف \"$name\" بشكل ناعم. يمكن الإبقاء على السجلات التاريخية.';
  }

  @override
  String get patientsDeleted => 'تم حذف المريض بنجاح.';

  @override
  String get patientsDeleteFailed => 'فشل الحذف.';

  @override
  String get patientsNew => 'مريض جديد';

  @override
  String get patientsSearchHint => 'الاسم، الهاتف، الرمز';

  @override
  String get patientsGender => 'الجنس';

  @override
  String get patientsDob => 'تاريخ الميلاد';

  @override
  String get patientsBranchId => 'معرّف الفرع';

  @override
  String get patientsCode => 'الرمز';

  @override
  String get patientsFullName => 'الاسم الكامل';

  @override
  String get patientsPhone => 'الهاتف';

  @override
  String get patientsNoResults => 'لا يوجد مرضى.';

  @override
  String get patientsNoResultsHint =>
      'جرّب تغيير عوامل التصفية أو أضف مريضاً جديداً.';

  @override
  String get genderMale => 'ذكر';

  @override
  String get genderFemale => 'أنثى';

  @override
  String get genderOther => 'آخر';

  @override
  String get genderUnknown => 'غير معروف';

  @override
  String get statusActive => 'نشط';

  @override
  String get statusInactive => 'غير نشط';

  @override
  String get appointmentsTitle => 'المواعيد';

  @override
  String get appointmentsNew => 'موعد جديد';

  @override
  String get billingTitle => 'الفوترة';

  @override
  String get billingInvoices => 'الفواتير';

  @override
  String get billingNewInvoice => 'فاتورة جديدة';

  @override
  String get doctorsTitle => 'الأطباء';

  @override
  String get doctorsNew => 'طبيب جديد';

  @override
  String get servicesTitle => 'الخدمات';

  @override
  String get servicesNew => 'خدمة جديدة';

  @override
  String get branchesTitle => 'الفروع';

  @override
  String get branchesNew => 'فرع جديد';

  @override
  String get invoiceStatusPaid => 'مدفوع';

  @override
  String get invoiceStatusUnpaid => 'غير مدفوع';

  @override
  String get invoiceStatusPartiallyPaid => 'مدفوع جزئياً';

  @override
  String get invoiceStatusCancelled => 'ملغاة';

  @override
  String get invoiceStatusDraft => 'مسودة';

  @override
  String get patientLabel => 'المريض';

  @override
  String get doctorLabel => 'الطبيب';

  @override
  String get serviceLabel => 'الخدمة';

  @override
  String get appointmentLabel => 'الموعد';

  @override
  String get branchLabel => 'الفرع';

  @override
  String get formRequiredFieldsAppointment =>
      'المريض والطبيب والتاريخ والوقت مطلوبة.';

  @override
  String get formEndAfterStart => 'يجب أن يكون وقت الانتهاء بعد وقت البدء.';

  @override
  String get formPatientRequired => 'المريض مطلوب.';

  @override
  String get formInvoiceItemsRequired => 'مطلوب بند فاتورة واحد على الأقل.';

  @override
  String formInvalidLineItem(int index) {
    return 'كمية أو سعر غير صالح في البند $index.';
  }

  @override
  String get appointmentConflict => 'تعارض في الموعد. اختر وقتاً آخر.';

  @override
  String get appointmentUpdated => 'تم تحديث الموعد.';

  @override
  String get appointmentCreated => 'تم إنشاء الموعد.';

  @override
  String get appointmentEditTitle => 'تعديل الموعد';

  @override
  String get appointmentCreateTitle => 'جدولة موعد';

  @override
  String appointmentLoadFailed(Object error) {
    return 'تعذّر تحميل الموعد.\n$error';
  }

  @override
  String get sectionPeopleService => 'الأشخاص والخدمة';

  @override
  String get sectionPeopleServiceHint =>
      'ابحث بالاسم أو الرمز — دون معرّفات يدوية.';

  @override
  String get sectionSchedule => 'الجدول';

  @override
  String get fieldAppointmentDate => 'تاريخ الموعد';

  @override
  String get fieldStartTime => 'وقت البدء';

  @override
  String get fieldEndTime => 'وقت الانتهاء';

  @override
  String get fieldStatus => 'الحالة';

  @override
  String get statusNotSet => 'غير محدد';

  @override
  String get statusBooked => 'محجوز';

  @override
  String get statusCompleted => 'مكتمل';

  @override
  String get statusCancelled => 'ملغى';

  @override
  String get statusNoShow => 'لم يحضر';

  @override
  String get appointmentUpdateButton => 'تحديث الموعد';

  @override
  String get appointmentCreateButton => 'إنشاء الموعد';

  @override
  String get invoiceUpdated => 'تم تحديث الفاتورة.';

  @override
  String get invoiceCreated => 'تم إنشاء الفاتورة.';

  @override
  String get invoiceEditTitle => 'تعديل الفاتورة';

  @override
  String get invoiceCreateTitle => 'إنشاء فاتورة';

  @override
  String invoiceLoadFailed(Object error) {
    return 'تعذّر تحميل الفاتورة.\n$error';
  }

  @override
  String get invoiceSaveFailed => 'تعذّر حفظ الفاتورة.';

  @override
  String get sectionParties => 'الأطراف';

  @override
  String get sectionPartiesHint =>
      'اربط المريض والموعد الاختياري والفرع عبر البحث.';

  @override
  String invoiceAppointmentRef(Object id) {
    return 'موعد #$id';
  }
}
