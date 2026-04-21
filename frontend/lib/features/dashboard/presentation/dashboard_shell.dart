import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/l10n.dart';
import '../../../shared/widgets/app_kpi_card.dart';
import '../../../shared/widgets/app_skeleton.dart';
import '../../../shared/widgets/glass_panel.dart';
import '../../../shared/widgets/smart_reference_field.dart';
import '../../app_shell/presentation/app_shell_navigation.dart';
import '../../app_shell/presentation/app_shell_scaffold.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import '../domain/models/dashboard_models.dart';
import 'controllers/dashboard_providers.dart';

class DashboardShell extends ConsumerWidget {
  const DashboardShell({super.key});

  static const routePath = '/dashboard';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final overviewState = ref.watch(dashboardOverviewProvider);
    final revenueState = ref.watch(dashboardRevenueSummaryProvider);
    final appointmentsState = ref.watch(dashboardAppointmentsSummaryProvider);
    final filters = ref.watch(dashboardFiltersProvider);

    return AppShellScaffold(
      title: l10n.dashboardTitle,
      activeSection: AppShellSection.dashboard,
      onSectionSelected: (section) => goAppShellSection(context, section),
      onLogout: () => ref.read(authControllerProvider).logout(),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.dashboardHeadline,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.dashboardSubtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                SmartReferenceField(
                  entity: ReferenceEntity.branch,
                  label: l10n.dashboardBranchFilter,
                  value: filters.branchId,
                  hint: l10n.dashboardAllBranches,
                  dense: true,
                  width: 220,
                  onChanged: (id) {
                    ref.read(dashboardFiltersProvider.notifier).state = filters.copyWith(branchId: id);
                  },
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () async {
                    final range = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                      initialDateRange: filters.dateFrom != null && filters.dateTo != null
                          ? DateTimeRange(start: filters.dateFrom!, end: filters.dateTo!)
                          : null,
                    );
                    if (range == null) return;
                    ref.read(dashboardFiltersProvider.notifier).state = filters.copyWith(
                          dateFrom: range.start,
                          dateTo: range.end,
                        );
                  },
                  icon: const Icon(Icons.date_range_outlined),
                  label: Text(l10n.commonDateRange),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: l10n.commonRefresh,
                  onPressed: () {
                    ref.invalidate(dashboardOverviewProvider);
                    ref.invalidate(dashboardRevenueSummaryProvider);
                    ref.invalidate(dashboardAppointmentsSummaryProvider);
                  },
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ).animate().fadeIn().slideY(begin: 0.02),
            const SizedBox(height: 16),
            overviewState.when(
              data: (overview) => _OverviewGrid(overview: overview),
              loading: () => const AppKpiGridSkeleton(),
              error: (error, _) => _ErrorCard(
                message: l10n.dashboardFailedOverview(error.toString()),
                onRetry: () => ref.invalidate(dashboardOverviewProvider),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: revenueState.when(
                    data: (summary) => _RevenuePanel(summary: summary),
                    loading: () => const AppPanelSkeleton(height: 330),
                    error: (error, _) => _ErrorCard(
                      message: l10n.dashboardFailedRevenue(error.toString()),
                      onRetry: () => ref.invalidate(dashboardRevenueSummaryProvider),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: appointmentsState.when(
                    data: (summary) => _AppointmentsPanel(summary: summary),
                    loading: () => const AppPanelSkeleton(height: 330),
                    error: (error, _) => _ErrorCard(
                      message: l10n.dashboardFailedAppointments(error.toString()),
                      onRetry: () => ref.invalidate(dashboardAppointmentsSummaryProvider),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewGrid extends StatelessWidget {
  const _OverviewGrid({required this.overview});
  final DashboardOverview overview;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currency = NumberFormat.currency(symbol: 'AED ');
    final cards = <({String title, String value, IconData icon})>[
      (title: l10n.kpiTotalPatients, value: overview.totalPatients.toString(), icon: Icons.people_rounded),
      (title: l10n.kpiActiveDoctors, value: overview.activeDoctors.toString(), icon: Icons.local_hospital_rounded),
      (title: l10n.kpiTodayAppointments, value: overview.todayAppointmentsCount.toString(), icon: Icons.today_rounded),
      (title: l10n.kpiUpcomingAppointments, value: overview.upcomingAppointmentsCount.toString(), icon: Icons.update_rounded),
      (title: l10n.kpiPaidInvoices, value: overview.paidInvoicesCount.toString(), icon: Icons.receipt_long_rounded),
      (title: l10n.kpiOpenInvoices, value: overview.openInvoicesCount.toString(), icon: Icons.pending_actions_rounded),
      (title: l10n.kpiTotalRevenue, value: currency.format(overview.totalRevenue), icon: Icons.attach_money_rounded),
      (title: l10n.kpiOutstandingBalance, value: currency.format(overview.outstandingBalance), icon: Icons.account_balance_wallet_rounded),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final card in cards)
          AppKpiCard(
            title: card.title,
            value: card.value,
            icon: card.icon,
          ),
      ],
    );
  }
}

class _RevenuePanel extends StatelessWidget {
  const _RevenuePanel({required this.summary});
  final DashboardRevenueSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currency = NumberFormat.currency(symbol: 'AED ');
    return GlassPanel(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.panelRevenueSummary, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _tinyStat(l10n.statToday, currency.format(summary.revenueToday)),
                _tinyStat(l10n.statThisWeek, currency.format(summary.revenueThisWeek)),
                _tinyStat(l10n.statThisMonth, currency.format(summary.revenueThisMonth)),
                _tinyStat(l10n.statPaid, currency.format(summary.paidAmount)),
                _tinyStat(l10n.statUnpaid, currency.format(summary.unpaidAmount)),
                _tinyStat(l10n.statPartial, currency.format(summary.partiallyPaidAmount)),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 170,
              child: _LineChart(points: summary.points, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppointmentsPanel extends StatelessWidget {
  const _AppointmentsPanel({required this.summary});
  final DashboardAppointmentsSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return GlassPanel(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.panelAppointmentsSummary, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _tinyStat(l10n.statBooked, summary.bookedCount.toString()),
                _tinyStat(l10n.statCompleted, summary.completedCount.toString()),
                _tinyStat(l10n.statCancelled, summary.cancelledCount.toString()),
                _tinyStat(l10n.statNoShow, summary.noShowCount.toString()),
                _tinyStat(l10n.statToday, summary.todayAppointments.toString()),
                _tinyStat(l10n.statUpcoming, summary.upcomingAppointments.toString()),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 170,
              child: _BarPointsChart(points: summary.points),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _tinyStat(String title, String value) {
  return Builder(
    builder: (context) => Container(
      width: 140,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 2),
          Text(value, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    ),
  );
}

class _LineChart extends StatelessWidget {
  const _LineChart({
    required this.points,
    required this.color,
  });

  final List<DashboardChartPoint> points;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return Center(child: Text(context.l10n.chartNoData));
    }
    final spots = <FlSpot>[
      for (var i = 0; i < points.length; i++) FlSpot(i.toDouble(), points[i].value),
    ];
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 34)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: color.withValues(alpha: 0.15)),
          ),
        ],
      ),
    );
  }
}

class _BarPointsChart extends StatelessWidget {
  const _BarPointsChart({required this.points});
  final List<DashboardChartPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return Center(child: Text(context.l10n.chartNoData));
    }

    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barGroups: [
          for (var i = 0; i < points.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: points[i].value,
                  width: 8,
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.blueAccent,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.l10n.commonRetry),
            ),
          ],
        ),
      ),
    );
  }
}
