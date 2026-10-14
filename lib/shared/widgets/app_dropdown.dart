import 'package:flutter/material.dart';
import 'package:nex_ledger/shared/widgets/searchable_select.dart';

/// The standard dropdown for the whole app. It takes the same arguments as
/// Flutter's `DropdownButtonFormField`, but opens the clean popover list
/// (with a search box once the list is long). Use it everywhere instead of
/// the plain Material dropdown.
class AppDropdownField<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final InputDecoration decoration;
  final FormFieldValidator<T>? validator;
  final AutovalidateMode? autovalidateMode;
  final String hint;
  final List<Widget> Function(BuildContext)? selectedItemBuilder;

  // Accepted so existing call sites keep working; the popover ignores them.
  final bool isExpanded;
  final bool isDense;

  const AppDropdownField({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.decoration = const InputDecoration(),
    this.validator,
    this.autovalidateMode,
    this.hint = 'Select',
    this.selectedItemBuilder,
    this.isExpanded = true,
    this.isDense = true,
  });

  /// Plain text found in a menu item's widget (first = title, rest = detail).
  static List<String> _texts(Widget? w) {
    if (w == null) return const [];
    if (w is Text) {
      final t = w.data ?? w.textSpan?.toPlainText() ?? '';
      return t.trim().isEmpty ? const [] : [t.trim()];
    }
    if (w is Flex) return [for (final c in w.children) ..._texts(c)];
    if (w is Padding) return _texts(w.child);
    if (w is Expanded) return _texts(w.child);
    if (w is Flexible) return _texts(w.child);
    if (w is SizedBox) return _texts(w.child);
    if (w is ConstrainedBox) return _texts(w.child);
    if (w is Container) return _texts(w.child);
    if (w is Align) return _texts(w.child);
    if (w is FittedBox) return _texts(w.child);
    if (w is Tooltip) return _texts(w.child);
    if (w is DefaultTextStyle) return _texts(w.child);
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    String? allLabel;
    final options = <SelectOption<Object>>[];
    for (final item in items) {
      final texts = _texts(item.child);
      final title = texts.isEmpty ? '—' : texts.first;
      if (item.value == null) {
        allLabel ??= title;
        continue;
      }
      final isColumn = item.child is Column;
      options.add(SelectOption<Object>(
        value: item.value as Object,
        title: isColumn || texts.length < 2 ? title : texts.join(' '),
        subtitle:
            isColumn && texts.length > 1 ? texts.skip(1).join(' · ') : null,
        searchText: texts.join(' '),
      ));
    }
    final known = options.any((o) => o.value == value);
    return SearchableSelectField<Object>(
      options: options,
      value: known ? value as Object? : null,
      allLabel: allLabel,
      hintText: hint,
      searchHint: 'Search…',
      enabled: onChanged != null,
      autovalidateMode: autovalidateMode,
      validator: validator == null ? null : (v) => validator!(v as T?),
      decoration: decoration,
      onChanged: (v) => onChanged?.call(v as T?),
    );
  }
}
