import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nex_ledger/core/theme/app_theme.dart';

/// One choice in a [SearchableSelectField].
class SelectOption<T> {
  final T value;
  final String title;
  final String? subtitle;

  /// Small tinted label before the title (e.g. a project code).
  final String? badge;

  /// Small label after the title (e.g. "On Hold").
  final String? tag;
  final Color? tagColor;

  /// Everything the search looks at (lower-cased on use).
  final String searchText;

  const SelectOption({
    required this.value,
    required this.title,
    this.subtitle,
    this.badge,
    this.tag,
    this.tagColor,
    String? searchText,
  }) : searchText = searchText ?? '';

  String get _haystack => (searchText.isNotEmpty
          ? searchText
          : '${badge ?? ''} $title ${subtitle ?? ''}')
      .toLowerCase();
}

/// Options matching [query]: every word typed must appear somewhere in the
/// option's text. Matches at the start of the badge or title come first.
List<SelectOption<T>> filterSelectOptions<T>(
    List<SelectOption<T>> options, String query) {
  final words = query
      .toLowerCase()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .toList();
  if (words.isEmpty) return options;
  int rank(SelectOption<T> o) {
    final first = words.first;
    if ((o.badge ?? '').toLowerCase().startsWith(first)) return 0;
    if (o.title.toLowerCase().startsWith(first)) return 1;
    return 2;
  }

  final hits = [
    for (final o in options)
      if (words.every(o._haystack.contains)) o
  ];
  // stable sort by rank
  final indexed = [for (var i = 0; i < hits.length; i++) (i, hits[i])];
  indexed.sort((a, b) {
    final r = rank(a.$2).compareTo(rank(b.$2));
    return r != 0 ? r : a.$1.compareTo(b.$1);
  });
  return [for (final e in indexed) e.$2];
}

/// A dropdown you can search. Click it (or press Enter / Space / ↓) to open a
/// list under the field with a search box ready to type in. Works inside a
/// [Form] with a validator, like a normal form field.
///
/// A null [value] means "nothing chosen" or, when [allLabel] is given, "all".
class SearchableSelectField<T> extends FormField<T?> {
  final List<SelectOption<T>> options;
  final T? value;
  final ValueChanged<T?> onChanged;

  SearchableSelectField({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    InputDecoration decoration = const InputDecoration(),
    String hintText = 'Select',
    String searchHint = 'Search...',
    String emptyText = 'Nothing matches',

    /// When set, a first choice with this text selects "null" (all / none).
    String? allLabel,
    super.validator,
    super.autovalidateMode,
    bool enabled = true,
    this.fieldKey,

    /// Show the search box even for a short list.
    bool alwaysSearch = false,
  }) : super(
          initialValue: value,
          enabled: enabled,
          builder: (state) {
            final s = state as _SearchableSelectFieldState<T>;
            return _SelectBody<T>(
              fieldKey: fieldKey,
              options: options,
              value: state.value,
              decoration: decoration.copyWith(errorText: state.errorText),
              hintText: hintText,
              searchHint: searchHint,
              emptyText: emptyText,
              allLabel: allLabel,
              enabled: enabled,
              alwaysSearch: alwaysSearch,
              onSelected: (v) {
                s.didChange(v);
                onChanged(v);
              },
            );
          },
        );

  /// A stable key for the clickable field (handy in tests).
  final Key? fieldKey;

  @override
  FormFieldState<T?> createState() => _SearchableSelectFieldState<T>();
}

class _SearchableSelectFieldState<T> extends FormFieldState<T?> {
  @override
  void didUpdateWidget(covariant FormField<T?> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final w = widget as SearchableSelectField<T>;
    final o = oldWidget as SearchableSelectField<T>;
    if (w.value != o.value && w.value != value) {
      setValue(w.value);
    }
  }
}

class _SelectBody<T> extends StatefulWidget {
  final Key? fieldKey;
  final List<SelectOption<T>> options;
  final T? value;
  final InputDecoration decoration;
  final String hintText;
  final String searchHint;
  final String emptyText;
  final String? allLabel;
  final bool enabled;
  final bool alwaysSearch;
  final ValueChanged<T?> onSelected;

  const _SelectBody({
    required this.fieldKey,
    required this.options,
    required this.value,
    required this.decoration,
    required this.hintText,
    required this.searchHint,
    required this.emptyText,
    required this.allLabel,
    required this.enabled,
    required this.alwaysSearch,
    required this.onSelected,
  });

  @override
  State<_SelectBody<T>> createState() => _SelectBodyState<T>();
}

class _SelectBodyState<T> extends State<_SelectBody<T>> {
  final _portal = OverlayPortalController();
  final _link = LayerLink();
  final _fieldFocus = FocusNode();
  bool _open = false;
  bool _openUp = false;
  double _width = 360;

  @override
  void dispose() {
    _fieldFocus.dispose();
    super.dispose();
  }

  SelectOption<T>? get _selected {
    for (final o in widget.options) {
      if (o.value == widget.value) return o;
    }
    return null;
  }

  void _openPopup() {
    if (!widget.enabled || _open) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box != null) {
      final below = MediaQuery.sizeOf(context).height -
          (box.localToGlobal(Offset.zero).dy + box.size.height);
      final above = box.localToGlobal(Offset.zero).dy;
      _openUp = below < 340 && above > below;
      _width = box.size.width < 340 ? 340 : box.size.width;
    }
    setState(() => _open = true);
    _portal.show();
  }

  void _closePopup({bool refocus = true}) {
    if (!_open) return;
    _portal.hide();
    setState(() => _open = false);
    if (refocus) _fieldFocus.requestFocus();
  }

  void _choose(T? v) {
    widget.onSelected(v);
    _closePopup();
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    final showAll = widget.value == null && widget.allLabel != null;

    final Widget display;
    if (selected != null) {
      display = Row(children: [
        if (selected.badge != null) ...[
          _Badge(selected.badge!),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(selected.title,
              overflow: TextOverflow.ellipsis,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ),
      ]);
    } else if (showAll) {
      display = Text(widget.allLabel!,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600));
    } else {
      display = Text(widget.hintText,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8)));
    }

    final deco = widget.decoration.copyWith(
      isDense: widget.decoration.isDense ?? true,
      suffixIcon: Icon(
        _open
            ? Icons.keyboard_arrow_up_rounded
            : Icons.keyboard_arrow_down_rounded,
        color: const Color(0xFF64748B),
      ),
      enabled: widget.enabled,
    );

    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _portal,
        overlayChildBuilder: (context) => _Popover<T>(
          link: _link,
          width: _width,
          openUp: _openUp,
          options: widget.options,
          value: widget.value,
          searchHint: widget.searchHint,
          emptyText: widget.emptyText,
          allLabel: widget.allLabel,
          alwaysSearch: widget.alwaysSearch,
          onChoose: _choose,
          onDismiss: _closePopup,
        ),
        child: Focus(
          focusNode: _fieldFocus,
          canRequestFocus: widget.enabled,
          onKeyEvent: (node, event) {
            if (event is! KeyDownEvent) return KeyEventResult.ignored;
            final k = event.logicalKey;
            if (k == LogicalKeyboardKey.enter ||
                k == LogicalKeyboardKey.numpadEnter ||
                k == LogicalKeyboardKey.space ||
                k == LogicalKeyboardKey.arrowDown) {
              _openPopup();
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          child: InkWell(
            key: widget.fieldKey,
            borderRadius: BorderRadius.circular(10),
            onTap: widget.enabled ? _openPopup : null,
            child: InputDecorator(
              decoration: deco,
              isFocused: _open,
              isEmpty: false,
              child: display,
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  const _Badge(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppTheme.primaryBlue,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _Popover<T> extends StatefulWidget {
  final LayerLink link;
  final double width;
  final bool openUp;
  final List<SelectOption<T>> options;
  final T? value;
  final String searchHint;
  final String emptyText;
  final String? allLabel;
  final bool alwaysSearch;
  final ValueChanged<T?> onChoose;
  final VoidCallback onDismiss;

  const _Popover({
    required this.link,
    required this.width,
    required this.openUp,
    required this.options,
    required this.value,
    required this.searchHint,
    required this.emptyText,
    required this.allLabel,
    required this.alwaysSearch,
    required this.onChoose,
    required this.onDismiss,
  });

  @override
  State<_Popover<T>> createState() => _PopoverState<T>();
}

class _PopoverState<T> extends State<_Popover<T>> {
  double get _rowHeight =>
      widget.options.any((o) => (o.subtitle ?? '').isNotEmpty) ? 54 : 44;

  /// Short lists are plain menus; the search box appears only for longer ones.
  bool get _showSearch => widget.options.length > 6 || widget.alwaysSearch;
  final _keyFocus = FocusNode();
  static const double _maxListHeight = 290;

  final _search = TextEditingController();
  final _searchFocus = FocusNode();
  final _scroll = ScrollController();
  String _query = '';
  int _highlight = 0;

  /// Rows shown: an optional "all" row, then the matching options.
  List<SelectOption<T>?> get _rows {
    final hits = filterSelectOptions(widget.options, _query);
    final showAll = widget.allLabel != null &&
        (_query.trim().isEmpty ||
            widget.allLabel!
                .toLowerCase()
                .contains(_query.trim().toLowerCase()));
    return [if (showAll) null, ...hits];
  }

  @override
  void initState() {
    super.initState();
    // Start on the currently chosen row.
    final rows = _rows;
    final i = rows.indexWhere(
        (o) => o == null ? widget.value == null : o.value == widget.value);
    _highlight = i < 0 ? 0 : i;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      (_showSearch ? _searchFocus : _keyFocus).requestFocus();
      _scrollToHighlight();
    });
  }

  @override
  void dispose() {
    _search.dispose();
    _searchFocus.dispose();
    _keyFocus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToHighlight() {
    if (!_scroll.hasClients) return;
    final top = _highlight * _rowHeight;
    final bottom = top + _rowHeight;
    final viewTop = _scroll.offset;
    final viewBottom = viewTop + _scroll.position.viewportDimension;
    if (top < viewTop) {
      _scroll.jumpTo(top);
    } else if (bottom > viewBottom) {
      _scroll.jumpTo(bottom - _scroll.position.viewportDimension);
    }
  }

  void _move(int delta) {
    final n = _rows.length;
    if (n == 0) return;
    setState(() => _highlight = (_highlight + delta).clamp(0, n - 1));
    _scrollToHighlight();
  }

  void _chooseHighlighted() {
    final rows = _rows;
    if (rows.isEmpty) return;
    final o = rows[_highlight.clamp(0, rows.length - 1)];
    widget.onChoose(o?.value);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final k = event.logicalKey;
    if (k == LogicalKeyboardKey.arrowDown) {
      _move(1);
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.arrowUp) {
      _move(-1);
      return KeyEventResult.handled;
    }
    if (event is KeyDownEvent &&
        (k == LogicalKeyboardKey.enter ||
            k == LogicalKeyboardKey.numpadEnter)) {
      _chooseHighlighted();
      return KeyEventResult.handled;
    }
    if (event is KeyDownEvent && k == LogicalKeyboardKey.escape) {
      widget.onDismiss();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final rows = _rows;
    final listHeight =
        (rows.length * _rowHeight).clamp(_rowHeight, _maxListHeight).toDouble();

    return Stack(children: [
      // Click anywhere else to close.
      Positioned.fill(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: widget.onDismiss,
        ),
      ),
      Align(
        alignment: Alignment.topLeft,
        child: CompositedTransformFollower(
          link: widget.link,
          showWhenUnlinked: false,
          targetAnchor:
              widget.openUp ? Alignment.topLeft : Alignment.bottomLeft,
          followerAnchor:
              widget.openUp ? Alignment.bottomLeft : Alignment.topLeft,
          offset: Offset(0, widget.openUp ? -6 : 6),
          child: SizedBox(
            width: widget.width,
            child: Material(
              elevation: 10,
              shadowColor: Colors.black26,
              borderRadius: BorderRadius.circular(14),
              clipBehavior: Clip.antiAlias,
              color: Colors.white,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  if (_showSearch)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
                      child: Focus(
                        onKeyEvent: _onKey,
                        child: TextField(
                          key: const Key('select_search'),
                          controller: _search,
                          focusNode: _searchFocus,
                          autofocus: true,
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            hintText: widget.searchHint,
                            isDense: true,
                            filled: true,
                            fillColor: const Color(0xFFF1F5F9),
                            prefixIcon:
                                const Icon(Icons.search_rounded, size: 20),
                            suffixIcon: _query.isEmpty
                                ? null
                                : IconButton(
                                    tooltip: 'Clear',
                                    icon: const Icon(Icons.close_rounded,
                                        size: 18),
                                    onPressed: () => setState(() {
                                      _search.clear();
                                      _query = '';
                                      _highlight = 0;
                                    }),
                                  ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (v) => setState(() {
                            _query = v;
                            _highlight = 0;
                            if (_scroll.hasClients) _scroll.jumpTo(0);
                          }),
                        ),
                      ),
                    ),
                  if (!_showSearch) const SizedBox(height: 6),
                  if (rows.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 22, horizontal: 16),
                      child: Text(
                        '${widget.emptyText}${_query.trim().isEmpty ? '' : ' "${_query.trim()}"'}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Color(0xFF64748B), fontSize: 13),
                      ),
                    )
                  else
                    SizedBox(
                      height: listHeight,
                      child: Focus(
                        focusNode: _showSearch ? null : _keyFocus,
                        canRequestFocus: !_showSearch,
                        onKeyEvent: _showSearch ? null : _onKey,
                        child: ListView.builder(
                          controller: _scroll,
                          itemExtent: _rowHeight,
                          padding: const EdgeInsets.only(bottom: 6),
                          itemCount: rows.length,
                          itemBuilder: (context, i) => _Row<T>(
                            option: rows[i],
                            allLabel: widget.allLabel,
                            selected: rows[i] == null
                                ? widget.value == null
                                : rows[i]!.value == widget.value,
                            highlighted: i == _highlight,
                            onTap: () => widget.onChoose(rows[i]?.value),
                            onHover: () => setState(() => _highlight = i),
                          ),
                        ),
                      ),
                    ),
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                    ),
                    child: Text(
                      rows.isEmpty
                          ? 'Try a shorter word'
                          : '↑ ↓ to move   ·   Enter to select   ·   Esc to close',
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF94A3B8)),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    ]);
  }
}

class _Row<T> extends StatelessWidget {
  final SelectOption<T>? option; // null = the "all" row
  final String? allLabel;
  final bool selected;
  final bool highlighted;
  final VoidCallback onTap;
  final VoidCallback onHover;

  const _Row({
    required this.option,
    required this.allLabel,
    required this.selected,
    required this.highlighted,
    required this.onTap,
    required this.onHover,
  });

  @override
  Widget build(BuildContext context) {
    final o = option;
    return MouseRegion(
      onEnter: (_) => onHover(),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: highlighted
                ? AppTheme.primaryBlue.withValues(alpha: 0.08)
                : (selected ? const Color(0xFFF1F5F9) : null),
            border: Border(
              left: BorderSide(
                color: selected ? AppTheme.primaryBlue : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(children: [
            if (o == null)
              const Icon(Icons.apps_rounded, size: 20, color: Color(0xFF64748B))
            else if (o.badge != null)
              _Badge(o.badge!),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    o == null ? allLabel! : o.title,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  if (o?.subtitle != null && o!.subtitle!.isNotEmpty)
                    Text(
                      o.subtitle!,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 11.5, color: Color(0xFF64748B)),
                    ),
                ],
              ),
            ),
            if (o?.tag != null)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: (o!.tagColor ?? const Color(0xFF64748B))
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  o.tag!,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: o.tagColor ?? const Color(0xFF64748B),
                  ),
                ),
              ),
            if (selected)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.check_rounded,
                    size: 18, color: AppTheme.primaryBlue),
              ),
          ]),
        ),
      ),
    );
  }
}
