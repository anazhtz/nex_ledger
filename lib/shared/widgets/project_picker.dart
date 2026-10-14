import 'package:flutter/material.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/shared/widgets/searchable_select.dart';

/// The choices for a project picker: code badge, name, client, and a tag for
/// projects that are on hold or closed.
List<SelectOption<int>> projectOptions(List<Project> projects) => [
      for (final p in projects)
        SelectOption<int>(
          value: p.id,
          badge: p.code,
          title: p.name,
          subtitle:
              (p.clientName ?? '').isEmpty ? null : 'Client: ${p.clientName}',
          tag: switch (p.status) {
            ProjectStatus.active => null,
            ProjectStatus.onHold => 'On Hold',
            ProjectStatus.closed => 'Closed',
          },
          tagColor: switch (p.status) {
            ProjectStatus.active => null,
            ProjectStatus.onHold => const Color(0xFFD97706),
            ProjectStatus.closed => const Color(0xFF64748B),
          },
          searchText: '${p.code} ${p.name} ${p.clientName ?? ''}',
        ),
    ];

/// The standard project dropdown for the whole app: search by code, name or
/// client, keyboard friendly, with an optional "All projects" choice for
/// filters. Replaces the plain dropdowns.
///
/// * For a form field that must be filled, pass [required] (shows "Required"
///   when empty) and leave [allLabel] null.
/// * For a filter, pass [allLabel] (e.g. "All Projects"); choosing it gives null.
class ProjectPickerField extends StatelessWidget {
  final List<Project> projects;
  final int? value;
  final ValueChanged<int?> onChanged;
  final String? labelText;
  final String hintText;
  final String? allLabel;
  final bool required;
  final FormFieldValidator<int?>? validator;
  final IconData? prefixIcon;
  final bool dense;
  final bool enabled;
  final Key? fieldKey;

  const ProjectPickerField({
    super.key,
    required this.projects,
    required this.value,
    required this.onChanged,
    this.labelText,
    this.hintText = 'Select project',
    this.allLabel,
    this.required = false,
    this.validator,
    this.prefixIcon,
    this.dense = true,
    this.enabled = true,
    this.fieldKey,
  });

  @override
  Widget build(BuildContext context) {
    // A project that no longer exists (or is filtered out) shows as "nothing".
    final safeValue = projects.any((p) => p.id == value) ? value : null;
    return SearchableSelectField<int>(
      fieldKey: fieldKey ?? const Key('project_picker'),
      options: projectOptions(projects),
      value: safeValue,
      onChanged: onChanged,
      hintText: hintText,
      searchHint: 'Search by code, name or client…',
      emptyText: 'No project matches',
      allLabel: allLabel,
      enabled: enabled,
      alwaysSearch: true,
      validator: validator ??
          (required
              ? (v) => v == null ? 'Please select a project' : null
              : null),
      decoration: InputDecoration(
        labelText: labelText,
        isDense: dense,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, size: 20),
      ),
    );
  }
}
