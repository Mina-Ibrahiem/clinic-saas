import 'package:flutter/material.dart';

/// Unified status chip for lists and detail screens.
class AppStatusChip extends StatelessWidget {
  const AppStatusChip({
    super.key,
    required this.status,
    this.compact = true,
  });

  final String status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final normalized = status.toLowerCase();
    final isPositive = _isPositive(normalized);
    final isWarning = _isWarning(normalized);

    Color bg;
    if (isPositive) {
      bg = scheme.primaryContainer;
    } else if (isWarning) {
      bg = scheme.tertiaryContainer;
    } else {
      bg = scheme.surfaceContainerHighest;
    }

    return Chip(
      label: Text(_pretty(normalized)),
      visualDensity: compact ? VisualDensity.compact : VisualDensity.standard,
      backgroundColor: bg,
      side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.35)),
    );
  }

  bool _isPositive(String s) {
    return s == 'active' || s == 'paid' || s == 'completed' || s == 'booked';
  }

  bool _isWarning(String s) {
    return s == 'partially_paid' || s == 'unpaid' || s == 'draft' || s == 'no_show';
  }

  String _pretty(String raw) {
    if (raw.isEmpty) return raw;
    return raw.split('_').map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}').join(' ');
  }
}
