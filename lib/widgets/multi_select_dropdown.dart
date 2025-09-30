import 'package:flutter/material.dart';

/// Lightweight, reusable searchable multi-select dropdown.
/// Generic over item type [T]. Caller provides [itemLabel] and [options].
class MultiSelectDropdown<T> extends StatefulWidget {
  final List<T> options;
  final List<T> value;
  final ValueChanged<List<T>> onChanged;
  final String Function(T) itemLabel;
  final String? hintText;
  final bool showSearch;
  final bool showChipsInField;
  final int maxSelected;

  const MultiSelectDropdown({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    required this.itemLabel,
    this.hintText,
    this.showSearch = true,
    this.showChipsInField = false,
    this.maxSelected = 10,
  });

  @override
  State<MultiSelectDropdown<T>> createState() => _MultiSelectDropdownState<T>();
}

class _MultiSelectDropdownState<T> extends State<MultiSelectDropdown<T>> {
  final LayerLink _link = LayerLink();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;
  late List<T> _filtered;
  late List<T> _selected;

  @override
  void initState() {
    super.initState();
    _filtered = List<T>.from(widget.options);
    _selected = List<T>.from(widget.value);
    _searchController.addListener(_filter);
  }

  @override
  void didUpdateWidget(covariant MultiSelectDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.options != widget.options) {
      _filtered = _applyFilter(_searchController.text);
    }
    _selected = List<T>.from(widget.value);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _filter() {
    setState(() {
      _filtered = _applyFilter(_searchController.text);
    });
  }

  List<T> _applyFilter(String q) {
    final query = q.trim().toLowerCase();
    if (query.isEmpty) return List<T>.from(widget.options);
    return widget.options
        .where((e) => widget.itemLabel(e).toLowerCase().contains(query))
        .toList();
  }

  void _toggleDropdown() {
    if (_overlayEntry != null) {
      _removeOverlay();
      return;
    }
    _overlayEntry = _buildOverlay();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _onItemToggled(T item, bool checked) {
    final next = List<T>.from(_selected);
    if (checked) {
      if (!next.contains(item) && next.length < widget.maxSelected) {
        next.add(item);
      }
    } else {
      next.remove(item);
    }
    setState(() => _selected = next);
    widget.onChanged(next);
  }

  OverlayEntry _buildOverlay() {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Size size = box.size;
    final Offset offset = box.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height + 4,
        width: size.width,
        child: CompositedTransformFollower(
          link: _link,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 4),
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.showSearch)
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search',
                          isDense: true,
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      itemCount: _filtered.length,
                      itemBuilder: (context, index) {
                        final item = _filtered[index];
                        final label = widget.itemLabel(item);
                        final checked = _selected.contains(item);
                        return CheckboxListTile(
                          dense: true,
                          value: checked,
                          title: Text(label),
                          onChanged: (v) => _onItemToggled(item, v ?? false),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasSelection = _selected.isNotEmpty;
    final fieldLabel = hasSelection
        ? (_selected.length == 1
            ? widget.itemLabel(_selected.first)
            : '${_selected.length} selected')
        : (widget.hintText ?? 'Select');

    return CompositedTransformTarget(
      link: _link,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: InputDecorator(
          decoration: InputDecoration(
            hintText: widget.hintText,
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.arrow_drop_down),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          isFocused: _overlayEntry != null,
          child: widget.showChipsInField && hasSelection
              ? Wrap(
                  spacing: 6,
                  runSpacing: -8,
                  children: _selected
                      .map((e) => Chip(
                            label: Text(widget.itemLabel(e)),
                          ))
                      .toList(),
                )
              : Text(fieldLabel),
        ),
      ),
    );
  }
}


