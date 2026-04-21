import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../references/appointment_reference_provider.dart';
import '../references/branch_reference_provider.dart';
import '../references/doctor_reference_provider.dart';
import '../references/patient_reference_provider.dart';
import '../references/reference_option.dart';
import '../references/service_reference_provider.dart';

/// Entity type for async searchable pickers backed by API lists.
enum ReferenceEntity {
  patient,
  doctor,
  service,
  branch,
  appointment,
}

/// Searchable selector replacing raw ID fields. Uses bottom sheet + debounced API search.
class SmartReferenceField extends ConsumerStatefulWidget {
  const SmartReferenceField({
    super.key,
    required this.entity,
    required this.label,
    this.value,
    this.selectedLabel,
    this.hint,
    required this.onChanged,
    this.requiredField = false,
    this.enabled = true,
    this.width = 280,
    this.dense = false,
  });

  final ReferenceEntity entity;
  final String label;
  final int? value;
  /// Shown when [value] is set (e.g. loaded entity name) before user opens the sheet.
  final String? selectedLabel;
  final String? hint;
  final ValueChanged<int?> onChanged;
  final bool requiredField;
  final bool enabled;
  final double width;
  final bool dense;

  @override
  ConsumerState<SmartReferenceField> createState() => _SmartReferenceFieldState();
}

class _SmartReferenceFieldState extends ConsumerState<SmartReferenceField> {
  String? _displayLabel;

  @override
  void initState() {
    super.initState();
    _displayLabel = widget.selectedLabel;
  }

  @override
  void didUpdateWidget(covariant SmartReferenceField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value == null) {
      _displayLabel = null;
    } else if (widget.selectedLabel != null && widget.selectedLabel!.isNotEmpty) {
      _displayLabel = widget.selectedLabel;
    }
  }

  Future<void> _openSheet(FormFieldState<int> field) async {
    if (!widget.enabled) return;
    final searchController = TextEditingController();
    Timer? debounce;
    var query = '';

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.viewInsetsOf(ctx).bottom + 16,
            top: 8,
          ),
          child: StatefulBuilder(
            builder: (ctx, setModal) {
              return Consumer(
                builder: (context, ref, _) {
                  final async = _ProviderScope(
                    ref: ref,
                    entity: widget.entity,
                    query: query,
                  ).watch();

                  return SizedBox(
                    height: MediaQuery.sizeOf(ctx).height * 0.55,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Select ${widget.label}', style: Theme.of(ctx).textTheme.titleMedium),
                        const SizedBox(height: 12),
                        TextField(
                          controller: searchController,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: widget.hint ?? 'Type to search…',
                            prefixIcon: const Icon(Icons.search_rounded),
                          ),
                          onChanged: (v) {
                            debounce?.cancel();
                            debounce = Timer(const Duration(milliseconds: 280), () {
                              setModal(() => query = v.trim());
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: async.when(
                            data: (items) {
                              if (items.isEmpty) {
                                return Center(
                                  child: Text(
                                    query.isEmpty ? 'Start typing to search.' : 'No matches.',
                                    style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                                          color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                );
                              }
                              return ListView.separated(
                                itemCount: items.length,
                                separatorBuilder: (_, __) => const Divider(height: 1),
                                itemBuilder: (context, i) {
                                  final o = items[i];
                                  return ListTile(
                                    title: Text(o.label),
                                    subtitle: o.subtitle != null && o.subtitle!.isNotEmpty
                                        ? Text(o.subtitle!)
                                        : null,
                                    onTap: () {
                                      setState(() => _displayLabel = o.label);
                                      field.didChange(o.id);
                                      widget.onChanged(o.id);
                                      Navigator.of(ctx).pop();
                                    },
                                  );
                                },
                              );
                            },
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (e, _) => Center(child: Text('Failed to load: $e')),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() => _displayLabel = null);
                            field.didChange(null);
                            widget.onChanged(null);
                            Navigator.of(ctx).pop();
                          },
                          child: const Text('Clear selection'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );

    debounce?.cancel();
    searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final display = widget.value != null
        ? (_displayLabel ?? widget.selectedLabel ?? '${widget.label} #${widget.value}')
        : (widget.hint ?? 'Tap to search & select');

    return FormField<int>(
      key: ValueKey<Object?>(
        '${widget.entity}-${widget.value}-${widget.selectedLabel}',
      ),
      initialValue: widget.value,
      validator: widget.requiredField
          ? (v) => v == null ? '${widget.label} is required.' : null
          : null,
      builder: (field) {
        return SizedBox(
          width: widget.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Material(
                color: scheme.surfaceContainerHighest.withValues(alpha: widget.enabled ? 0.35 : 0.2),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: widget.enabled ? () => _openSheet(field) : null,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    isEmpty: false,
                    decoration: InputDecoration(
                      labelText: widget.label,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: widget.dense ? 10 : 14,
                        vertical: widget.dense ? 10 : 12,
                      ),
                      suffixIcon: Icon(
                        Icons.arrow_drop_down_rounded,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    child: Row(
                      children: [
                        if (widget.dense) ...[
                          Icon(Icons.link_rounded, size: 18, color: scheme.primary),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            display,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: widget.value != null ? FontWeight.w600 : FontWeight.w400,
                                  color: widget.value != null ? scheme.onSurface : scheme.onSurfaceVariant,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (field.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 12),
                  child: Text(
                    field.errorText!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.error),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Local helper: watch provider by entity without exposing family types.
class _ProviderScope {
  _ProviderScope({required this.ref, required this.entity, required this.query});

  final WidgetRef ref;
  final ReferenceEntity entity;
  final String query;

  AsyncValue<List<ReferenceOption>> watch() {
    switch (entity) {
      case ReferenceEntity.patient:
        return ref.watch(patientReferenceOptionsProvider(query));
      case ReferenceEntity.doctor:
        return ref.watch(doctorReferenceOptionsProvider(query));
      case ReferenceEntity.service:
        return ref.watch(serviceReferenceOptionsProvider(query));
      case ReferenceEntity.branch:
        return ref.watch(branchReferenceOptionsProvider(query));
      case ReferenceEntity.appointment:
        return ref.watch(appointmentReferenceOptionsProvider(query));
    }
  }
}
