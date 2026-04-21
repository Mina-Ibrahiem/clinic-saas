import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/domain/auth_access.dart';
import '../../auth/domain/models/auth_user.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import '../domain/models/branch.dart';
import '../domain/models/branch_upsert_payload.dart';
import 'branch_routes.dart';
import 'controllers/branch_details_provider.dart';
import 'controllers/branch_form_controller.dart';

class BranchFormPage extends ConsumerStatefulWidget {
  const BranchFormPage({super.key, this.branchId});

  final int? branchId;

  static const createPath = BranchRoutes.create;
  static String editPathFor(int id) => BranchRoutes.edit(id);

  @override
  ConsumerState<BranchFormPage> createState() => _BranchFormPageState();
}

class _BranchFormPageState extends ConsumerState<BranchFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _code = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _address = TextEditingController();
  final _tenantId = TextEditingController();
  String? _status;
  bool _seededFromRemote = false;

  bool get _isEdit => widget.branchId != null;

  @override
  void initState() {
    super.initState();
    if (!_isEdit) {
      _status = 'active';
    }
  }

  @override
  void didUpdateWidget(covariant BranchFormPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.branchId != widget.branchId) {
      _seededFromRemote = false;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _phone.dispose();
    _email.dispose();
    _address.dispose();
    _tenantId.dispose();
    super.dispose();
  }

  void _applyBranch(Branch branch) {
    _name.text = branch.name;
    _code.text = branch.code ?? '';
    _phone.text = branch.phone ?? '';
    _email.text = branch.email ?? '';
    _address.text = branch.address ?? '';
    _status = branch.status;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authControllerProvider).user;
    final payload = BranchUpsertPayload(
      tenantId: user.isSuperAdmin ? int.tryParse(_tenantId.text.trim()) : null,
      name: _name.text.trim(),
      code: _code.text.trim().isEmpty ? null : _code.text.trim(),
      phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
      email: _email.text.trim().isEmpty ? null : _email.text.trim(),
      address: _address.text.trim().isEmpty ? null : _address.text.trim(),
      status: _status,
    );

    final controller = ref.read(branchFormControllerProvider);
    final branch = _isEdit
        ? await controller.update(branchId: widget.branchId!, payload: payload)
        : await controller.create(payload);

    if (!mounted) return;
    if (branch == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(controller.errorMessage ?? 'Failed to save branch.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isEdit ? 'Branch updated.' : 'Branch created.')),
    );
    if (_isEdit) {
      ref.invalidate(branchDetailsProvider(widget.branchId!));
    }
    context.go(BranchRoutes.list);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user;
    final formController = ref.watch(branchFormControllerProvider);

    if (_isEdit) {
      final async = ref.watch(branchDetailsProvider(widget.branchId!));
      return async.when(
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Scaffold(
          body: Center(child: Text('Failed to load branch: $e')),
        ),
        data: (branch) {
          if (!_seededFromRemote) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              setState(() {
                _applyBranch(branch);
                _seededFromRemote = true;
              });
            });
          }
          return _scaffold(context, user, formController);
        },
      );
    }

    return _scaffold(context, user, formController);
  }

  Widget _scaffold(BuildContext context, AuthUser? user, BranchFormController formController) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit branch' : 'New branch'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.go(BranchRoutes.list),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (user.isSuperAdmin && !_isEdit) ...[
                    TextFormField(
                      controller: _tenantId,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Tenant ID',
                        hintText: 'Required for super admin',
                      ),
                      validator: (v) {
                        if (int.tryParse(v?.trim() ?? '') == null) {
                          return 'Enter a valid tenant id.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required.' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _code,
                    decoration: const InputDecoration(
                      labelText: 'Code',
                      hintText: 'Optional, unique per tenant',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phone,
                    decoration: const InputDecoration(labelText: 'Phone'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _email,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _address,
                    decoration: const InputDecoration(labelText: 'Address'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: const [
                      DropdownMenuItem(value: 'active', child: Text('Active')),
                      DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                    ],
                    onChanged: (v) => setState(() => _status = v),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: formController.submitting ? null : _submit,
                    child: formController.submitting
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_isEdit ? 'Save changes' : 'Create branch'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
