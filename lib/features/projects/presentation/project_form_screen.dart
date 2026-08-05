import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/features/projects/providers/project_providers.dart';

class ProjectFormScreen extends ConsumerStatefulWidget {
  final int? projectId;
  const ProjectFormScreen({super.key, this.projectId});

  @override
  ConsumerState<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends ConsumerState<ProjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _clientCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();

  ProjectType _type = ProjectType.project;
  ProjectStatus _status = ProjectStatus.active;
  DateTime _startDate = DateTime.now();
  bool _loading = false;
  bool _dataLoaded = false;

  bool get _isEditing => widget.projectId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadProject());
    }
  }

  Future<void> _loadProject() async {
    final project = await ref
        .read(projectRepositoryProvider)
        .getProjectById(widget.projectId!);
    if (project != null && mounted) {
      setState(() {
        _codeCtrl.text = project.code;
        _nameCtrl.text = project.name;
        _clientCtrl.text = project.clientName ?? '';
        _budgetCtrl.text =
            project.budget != null ? project.budget!.toStringAsFixed(2) : '';
        _type = project.type;
        _status = project.status;
        _startDate = project.startDate;
        _dataLoaded = true;
      });
    }
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _clientCtrl.dispose();
    _budgetCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final repo = ref.read(projectRepositoryProvider);
      final budget = _budgetCtrl.text.isNotEmpty
          ? double.tryParse(_budgetCtrl.text)
          : null;

      if (_isEditing) {
        await repo.updateProject(
          id: widget.projectId!,
          code: _codeCtrl.text,
          name: _nameCtrl.text,
          clientName:
              _clientCtrl.text.isNotEmpty ? _clientCtrl.text : null,
          type: _type,
          status: _status,
          startDate: _startDate,
          budget: budget,
        );
      } else {
        await repo.createProject(
          code: _codeCtrl.text,
          name: _nameCtrl.text,
          clientName:
              _clientCtrl.text.isNotEmpty ? _clientCtrl.text : null,
          type: _type,
          status: _status,
          startDate: _startDate,
          budget: budget,
        );
      }
      if (mounted) context.go('/projects');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = _isEditing && !_dataLoaded;

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.go('/projects'),
                ),
                const SizedBox(width: 8),
                Text(
                  _isEditing ? 'Edit Project' : 'New Project',
                  style: theme.textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else
              SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: _codeCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Project Code *',
                                    hintText: 'PRJ-2026-001',
                                  ),
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  validator: (v) => v == null || v.isEmpty
                                      ? 'Required'
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 3,
                                child: TextFormField(
                                  controller: _nameCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Project Name *',
                                  ),
                                  validator: (v) => v == null || v.isEmpty
                                      ? 'Required'
                                      : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _clientCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Client Name',
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<ProjectType>(
                                  value: _type,
                                  decoration: const InputDecoration(
                                      labelText: 'Type'),
                                  items: ProjectType.values
                                      .map((t) => DropdownMenuItem(
                                            value: t,
                                            child: Text(t.displayName),
                                          ))
                                      .toList(),
                                  onChanged: (v) =>
                                      setState(() => _type = v!),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: DropdownButtonFormField<ProjectStatus>(
                                  value: _status,
                                  decoration: const InputDecoration(
                                      labelText: 'Status'),
                                  items: ProjectStatus.values
                                      .map((s) => DropdownMenuItem(
                                            value: s,
                                            child: Text(s.displayName),
                                          ))
                                      .toList(),
                                  onChanged: (v) =>
                                      setState(() => _status = v!),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: _pickDate,
                                  child: InputDecorator(
                                    decoration: const InputDecoration(
                                      labelText: 'Start Date',
                                      suffixIcon: Icon(
                                          Icons.calendar_today_outlined,
                                          size: 18),
                                    ),
                                    child: Text(
                                      '${_startDate.day.toString().padLeft(2, '0')}/'
                                      '${_startDate.month.toString().padLeft(2, '0')}/'
                                      '${_startDate.year}',
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _budgetCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Budget (₹)',
                                    prefixText: '₹ ',
                                  ),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => context.go('/projects'),
                                child: const Text('Cancel'),
                              ),
                              const SizedBox(width: 12),
                              FilledButton(
                                onPressed: _loading ? null : _submit,
                                child: _loading
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )
                                    : Text(
                                        _isEditing ? 'Save Changes' : 'Create',
                                      ),
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
          ],
        ),
      ),
    );
  }
}
