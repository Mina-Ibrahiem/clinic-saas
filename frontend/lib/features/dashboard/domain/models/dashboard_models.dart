class DashboardChartPoint {
  const DashboardChartPoint({
    required this.label,
    required this.value,
  });

  final String label;
  final double value;

  factory DashboardChartPoint.fromRevenueJson(Map<String, dynamic> json) {
    return DashboardChartPoint(
      label: (json['date'] as String?) ?? '-',
      value: _toDouble(json['amount']),
    );
  }

  factory DashboardChartPoint.fromAppointmentsJson(Map<String, dynamic> json) {
    return DashboardChartPoint(
      label: (json['date'] as String?) ?? '-',
      value: ((json['count'] as num?)?.toDouble()) ?? 0,
    );
  }
}

class DashboardOverview {
  const DashboardOverview({
    required this.totalPatients,
    required this.activeDoctors,
    required this.todayAppointmentsCount,
    required this.upcomingAppointmentsCount,
    required this.paidInvoicesCount,
    required this.openInvoicesCount,
    required this.totalRevenue,
    required this.outstandingBalance,
    this.tenantId,
    this.branchId,
  });

  final int totalPatients;
  final int activeDoctors;
  final int todayAppointmentsCount;
  final int upcomingAppointmentsCount;
  final int paidInvoicesCount;
  final int openInvoicesCount;
  final double totalRevenue;
  final double outstandingBalance;
  final int? tenantId;
  final int? branchId;

  factory DashboardOverview.fromJson(Map<String, dynamic> json) {
    final totals = (json['totals'] as Map<String, dynamic>?) ?? const {};
    final scope = (json['scope'] as Map<String, dynamic>?) ?? const {};

    return DashboardOverview(
      totalPatients: (totals['total_patients'] as num?)?.toInt() ?? 0,
      activeDoctors: (totals['active_doctors'] as num?)?.toInt() ?? 0,
      todayAppointmentsCount: (totals['today_appointments_count'] as num?)?.toInt() ?? 0,
      upcomingAppointmentsCount: (totals['upcoming_appointments_count'] as num?)?.toInt() ?? 0,
      paidInvoicesCount: (totals['paid_invoices_count'] as num?)?.toInt() ?? 0,
      openInvoicesCount: (totals['open_invoices_count'] as num?)?.toInt() ?? 0,
      totalRevenue: _toDouble(totals['total_revenue']),
      outstandingBalance: _toDouble(totals['outstanding_balance']),
      tenantId: (scope['tenant_id'] as num?)?.toInt(),
      branchId: (scope['branch_id'] as num?)?.toInt(),
    );
  }
}

class DashboardRevenueSummary {
  const DashboardRevenueSummary({
    required this.revenueToday,
    required this.revenueThisWeek,
    required this.revenueThisMonth,
    required this.paidAmount,
    required this.unpaidAmount,
    required this.partiallyPaidAmount,
    required this.points,
  });

  final double revenueToday;
  final double revenueThisWeek;
  final double revenueThisMonth;
  final double paidAmount;
  final double unpaidAmount;
  final double partiallyPaidAmount;
  final List<DashboardChartPoint> points;

  factory DashboardRevenueSummary.fromJson(Map<String, dynamic> json) {
    final totals = (json['totals'] as Map<String, dynamic>?) ?? const {};
    final chart = (json['chart'] as Map<String, dynamic>?) ?? const {};
    final pointsRaw = chart['points'];

    return DashboardRevenueSummary(
      revenueToday: _toDouble(totals['revenue_today']),
      revenueThisWeek: _toDouble(totals['revenue_this_week']),
      revenueThisMonth: _toDouble(totals['revenue_this_month']),
      paidAmount: _toDouble(totals['paid_amount']),
      unpaidAmount: _toDouble(totals['unpaid_amount']),
      partiallyPaidAmount: _toDouble(totals['partially_paid_amount']),
      points: pointsRaw is List
          ? pointsRaw.whereType<Map<String, dynamic>>().map(DashboardChartPoint.fromRevenueJson).toList(growable: false)
          : const <DashboardChartPoint>[],
    );
  }
}

class DashboardAppointmentsSummary {
  const DashboardAppointmentsSummary({
    required this.bookedCount,
    required this.completedCount,
    required this.cancelledCount,
    required this.noShowCount,
    required this.todayAppointments,
    required this.upcomingAppointments,
    required this.points,
  });

  final int bookedCount;
  final int completedCount;
  final int cancelledCount;
  final int noShowCount;
  final int todayAppointments;
  final int upcomingAppointments;
  final List<DashboardChartPoint> points;

  factory DashboardAppointmentsSummary.fromJson(Map<String, dynamic> json) {
    final totals = (json['totals'] as Map<String, dynamic>?) ?? const {};
    final chart = (json['chart'] as Map<String, dynamic>?) ?? const {};
    final pointsRaw = chart['points'];

    return DashboardAppointmentsSummary(
      bookedCount: (totals['booked_count'] as num?)?.toInt() ?? 0,
      completedCount: (totals['completed_count'] as num?)?.toInt() ?? 0,
      cancelledCount: (totals['cancelled_count'] as num?)?.toInt() ?? 0,
      noShowCount: (totals['no_show_count'] as num?)?.toInt() ?? 0,
      todayAppointments: (totals['today_appointments'] as num?)?.toInt() ?? 0,
      upcomingAppointments: (totals['upcoming_appointments'] as num?)?.toInt() ?? 0,
      points: pointsRaw is List
          ? pointsRaw
              .whereType<Map<String, dynamic>>()
              .map(DashboardChartPoint.fromAppointmentsJson)
              .toList(growable: false)
          : const <DashboardChartPoint>[],
    );
  }
}

double _toDouble(Object? raw) {
  if (raw == null) return 0;
  if (raw is num) return raw.toDouble();
  return double.tryParse(raw.toString()) ?? 0;
}
