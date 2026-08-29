import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/features/petty_cash/providers/petty_cash_providers.dart';
import 'package:nex_ledger/features/projects/providers/project_providers.dart';

class PettyCashWalletFormScreen extends ConsumerStatefulWidget {
  final int? walletId;
  const PettyCashWalletFormScreen({super.key, this.walletId});

  @override
  ConsumerState<PettyCashWalletFormScreen> createState() =>
      _PettyCashWalletFormScreenState();
}

class _PettyCashWalletFormScreenState
    extends ConsumerState<PettyCashWalletFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _limitCtrl = TextEditingController(text: '50000');
  final _notesCtrl = TextEditingController();

  int? _selectedProjectId;
  bool _isActive = true;
  bool _loading = false;

  bool get _isEditing => widget.walletId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadWallet());
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _limitCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _loadWallet() async {
    final summary =
        await ref.read(singleWalletProvider(widget.walletId!).future);
    if (summary == null || !mounted) return;

    final w = summary.wallet;
    _nameCtrl.text = w.supervisorName;
    _phoneCtrl.text = w.phone;
    _limitCtrl.text = w.maxFloatLimit.toStringAsFixed(0);
    _selectedProjectId = w.assignedProjectId;
    _isActive = w.isActive;
    _notesCtrl.text = w.notes ?? '';
    setState(() {});
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final limit =
          double.tryParse(_limitCtrl.text.trim().replaceAll(',', '')) ??
              50000.0;
      final repo = ref.read(pettyCashRepositoryProvider);

      if (_isEditing) {
        await repo.updateWallet(
          id: widget.walletId!,
          supervisorName: _nameCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          assignedProjectId: _selectedProjectId,
          maxFloatLimit: limit,
          isActive: _isActive,
          notes: _notesCtrl.text.trim().isNotEmpty
              ? _notesCtrl.text.trim()
              : null,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Supervisor Wallet updated successfully!'),
              backgroundColor: Color(0xFF059669),
            ),
          );
          context.go('/petty-cash');
        }
        return;
      }

      await repo.createWallet(
        supervisorName: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        assignedProjectId: _selectedProjectId,
        maxFloatLimit: limit,
        isActive: _isActive,
        notes: _notesCtrl.text.trim().isNotEmpty
            ? _notesCtrl.text.trim()
            : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Supervisor Petty Cash Wallet created!'),
            backgroundColor: Color(0xFF059669),
          ),
        );
        context.go('/petty-cash');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red.shade700),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final projectsAsync = ref.watch(projectListProvider);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter, control: true): _submit,
        const SingleActivator(LogicalKeyboardKey.enter, meta: true): _submit,
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            context.go('/petty-cash'),
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.surfaceContainerLowest,
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 700.w),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ─── Header ─────────────────────────────────────────
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => context.go('/petty-cash'),
                              icon: const Icon(Icons.arrow_back),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _isEditing
                                        ? 'Edit Supervisor Cash Wallet'
                                        : 'Add Supervisor / Site Imprest Wallet',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    'Register site engineer or supervisor to disburse and track cash floats',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 18.h),

                        // ─── Supervisor Name & Phone ─────────────────────────
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: _nameCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Supervisor / Engineer Name *',
                                  hintText: 'e.g. Engr. Rajesh Sharma',
                                  prefixIcon: Icon(Icons.person_pin_outlined),
                                ),
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? 'Required'
                                    : null,
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: _phoneCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Mobile Phone # *',
                                  hintText: 'e.g. 9876543210',
                                  prefixIcon: Icon(Icons.phone_outlined),
                                ),
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? 'Required'
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14.h),

                        // ─── Assigned Project Dropdown ───────────────────────
                        projectsAsync.when(
                          loading: () => const LinearProgressIndicator(),
                          error: (e, _) => Text('Error: $e'),
                          data: (projects) {
                            final validProjects = projects
                                .where((p) => p.type == ProjectType.project)
                                .toList();
                            return DropdownButtonFormField<int?>(
                              value: _selectedProjectId,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Default Assigned Project Site',
                                prefixIcon: Icon(Icons.folder_outlined),
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('— Multi-Site / Floating —',
                                      overflow: TextOverflow.ellipsis),
                                ),
                                ...validProjects.map(
                                  (p) => DropdownMenuItem(
                                    value: p.id,
                                    child: Text('${p.code} — ${p.name}',
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                ),
                              ],
                              onChanged: (v) =>
                                  setState(() => _selectedProjectId = v),
                            );
                          },
                        ),
                        SizedBox(height: 14.h),

                        // ─── Max Float Limit & Active Status ─────────────────
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: _limitCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Max Approved Float Limit (₹) *',
                                  hintText: '50000',
                                  prefixText: '₹ ',
                                  helperText: 'Maximum cash advance allowed in pocket at any time',
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? 'Required'
                                    : null,
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              flex: 2,
                              child: SwitchListTile(
                                title: Text('Wallet Active',
                                    style: TextStyle(fontSize: 13.sp)),
                                value: _isActive,
                                onChanged: (v) =>
                                    setState(() => _isActive = v),
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14.h),

                        // ─── Notes ───────────────────────────────────────────
                        TextFormField(
                          controller: _notesCtrl,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Notes / Remarks',
                            hintText: 'e.g. Handles civil works, concrete pour overtime food & water supplies',
                            prefixIcon: Icon(Icons.notes_outlined),
                          ),
                        ),
                        SizedBox(height: 24.h),

                        // ─── Submit Buttons ──────────────────────────────────
                        Wrap(
                          alignment: WrapAlignment.end,
                          spacing: 12.w,
                          runSpacing: 8.h,
                          children: [
                            OutlinedButton(
                              onPressed: () => context.go('/petty-cash'),
                              child: const Text('Cancel'),
                            ),
                            FilledButton.icon(
                              onPressed: _loading ? null : _submit,
                              icon: _loading
                                  ? SizedBox(
                                      width: 16.sp,
                                      height: 16.sp,
                                      child: const CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Icon(Icons.check, size: 18),
                              label: Text(_isEditing
                                  ? 'Update Wallet'
                                  : 'Create Supervisor Wallet'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
