class SettingsScopeInfo {
  const SettingsScopeInfo({
    required this.tenantId,
    this.branchId,
  });

  final int tenantId;
  final int? branchId;

  factory SettingsScopeInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const SettingsScopeInfo(tenantId: 0);
    }
    return SettingsScopeInfo(
      tenantId: (json['tenant_id'] as num?)?.toInt() ?? 0,
      branchId: (json['branch_id'] as num?)?.toInt(),
    );
  }
}

class GeneralSettingsValues {
  const GeneralSettingsValues({
    this.clinicName,
    this.clinicPhone,
    this.clinicEmail,
    this.clinicAddress,
    this.timezone,
    this.currency,
  });

  final String? clinicName;
  final String? clinicPhone;
  final String? clinicEmail;
  final String? clinicAddress;
  final String? timezone;
  final String? currency;

  factory GeneralSettingsValues.fromJson(Map<String, dynamic> json) {
    return GeneralSettingsValues(
      clinicName: json['clinic_name'] as String?,
      clinicPhone: json['clinic_phone'] as String?,
      clinicEmail: json['clinic_email'] as String?,
      clinicAddress: json['clinic_address'] as String?,
      timezone: json['timezone'] as String?,
      currency: json['currency'] as String?,
    );
  }

  Map<String, dynamic> toSettingsMap() {
    return {
      'clinic_name': clinicName,
      'clinic_phone': clinicPhone,
      'clinic_email': clinicEmail,
      'clinic_address': clinicAddress,
      'timezone': timezone,
      'currency': currency,
    };
  }
}

class ClinicProfileSettingsValues {
  const ClinicProfileSettingsValues({
    this.clinicName,
    this.clinicPhone,
    this.clinicEmail,
    this.clinicAddress,
    this.timezone,
    this.currency,
    this.brandingLogoUrl,
    this.brandingPrimaryColor,
  });

  final String? clinicName;
  final String? clinicPhone;
  final String? clinicEmail;
  final String? clinicAddress;
  final String? timezone;
  final String? currency;
  final String? brandingLogoUrl;
  final String? brandingPrimaryColor;

  factory ClinicProfileSettingsValues.fromJson(Map<String, dynamic> json) {
    return ClinicProfileSettingsValues(
      clinicName: json['clinic_name'] as String?,
      clinicPhone: json['clinic_phone'] as String?,
      clinicEmail: json['clinic_email'] as String?,
      clinicAddress: json['clinic_address'] as String?,
      timezone: json['timezone'] as String?,
      currency: json['currency'] as String?,
      brandingLogoUrl: json['branding_logo_url'] as String?,
      brandingPrimaryColor: json['branding_primary_color'] as String?,
    );
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'clinic_name': clinicName,
      'clinic_phone': clinicPhone,
      'clinic_email': clinicEmail,
      'clinic_address': clinicAddress,
      'timezone': timezone,
      'currency': currency,
      'branding_logo_url': brandingLogoUrl,
      'branding_primary_color': brandingPrimaryColor,
    };
  }
}

class InvoiceSettingsValues {
  const InvoiceSettingsValues({
    this.invoicePrefix,
    this.invoiceDueDays,
    this.taxDefault,
    this.invoiceFooter,
  });

  final String? invoicePrefix;
  final int? invoiceDueDays;
  final double? taxDefault;
  final String? invoiceFooter;

  factory InvoiceSettingsValues.fromJson(Map<String, dynamic> json) {
    return InvoiceSettingsValues(
      invoicePrefix: json['invoice_prefix'] as String?,
      invoiceDueDays: (json['invoice_due_days'] as num?)?.toInt(),
      taxDefault: _toDouble(json['tax_default']),
      invoiceFooter: json['invoice_footer'] as String?,
    );
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'invoice_prefix': invoicePrefix,
      'invoice_due_days': invoiceDueDays,
      'tax_default': taxDefault,
      'invoice_footer': invoiceFooter,
    };
  }
}

double? _toDouble(Object? raw) {
  if (raw == null) return null;
  if (raw is num) return raw.toDouble();
  return double.tryParse(raw.toString());
}

/// Full payload from `GET /settings`.
class SettingsBundle {
  const SettingsBundle({
    required this.scope,
    required this.general,
    required this.clinicProfile,
    required this.invoice,
  });

  final SettingsScopeInfo scope;
  final GeneralSettingsValues general;
  final ClinicProfileSettingsValues clinicProfile;
  final InvoiceSettingsValues invoice;

  factory SettingsBundle.fromJson(Map<String, dynamic> json) {
    final scopeRaw = json['scope'];
    final generalRaw = json['general'];
    final clinicRaw = json['clinic_profile'];
    final invoiceRaw = json['invoice'];

    return SettingsBundle(
      scope: SettingsScopeInfo.fromJson(scopeRaw is Map<String, dynamic> ? scopeRaw : null),
      general: generalRaw is Map<String, dynamic>
          ? GeneralSettingsValues.fromJson(generalRaw)
          : const GeneralSettingsValues(),
      clinicProfile: clinicRaw is Map<String, dynamic>
          ? ClinicProfileSettingsValues.fromJson(clinicRaw)
          : const ClinicProfileSettingsValues(),
      invoice: invoiceRaw is Map<String, dynamic>
          ? InvoiceSettingsValues.fromJson(invoiceRaw)
          : const InvoiceSettingsValues(),
    );
  }
}

class ClinicProfileSettingsResponse {
  const ClinicProfileSettingsResponse({
    required this.scope,
    required this.clinicProfile,
  });

  final SettingsScopeInfo scope;
  final ClinicProfileSettingsValues clinicProfile;

  factory ClinicProfileSettingsResponse.fromJson(Map<String, dynamic> json) {
    final scopeRaw = json['scope'];
    final clinicRaw = json['clinic_profile'];
    return ClinicProfileSettingsResponse(
      scope: SettingsScopeInfo.fromJson(scopeRaw is Map<String, dynamic> ? scopeRaw : null),
      clinicProfile: clinicRaw is Map<String, dynamic>
          ? ClinicProfileSettingsValues.fromJson(clinicRaw)
          : const ClinicProfileSettingsValues(),
    );
  }
}

class InvoiceSettingsResponse {
  const InvoiceSettingsResponse({
    required this.scope,
    required this.invoice,
  });

  final SettingsScopeInfo scope;
  final InvoiceSettingsValues invoice;

  factory InvoiceSettingsResponse.fromJson(Map<String, dynamic> json) {
    final scopeRaw = json['scope'];
    final invoiceRaw = json['invoice'];
    return InvoiceSettingsResponse(
      scope: SettingsScopeInfo.fromJson(scopeRaw is Map<String, dynamic> ? scopeRaw : null),
      invoice: invoiceRaw is Map<String, dynamic>
          ? InvoiceSettingsValues.fromJson(invoiceRaw)
          : const InvoiceSettingsValues(),
    );
  }
}
