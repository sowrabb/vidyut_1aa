import 'package:flutter/material.dart';
import '../../../app/tokens.dart';

class SimpleCustomFields extends StatefulWidget {
  final List<MapEntry<String, String>> entries;
  final ValueChanged<List<MapEntry<String, String>>> onChanged;
  final String title;
  const SimpleCustomFields(
      {super.key,
      required this.entries,
      required this.onChanged,
      this.title = 'Custom Fields'});

  @override
  State<SimpleCustomFields> createState() => _SimpleCustomFieldsState();
}

class _SimpleCustomFieldsState extends State<SimpleCustomFields> {
  late List<MapEntry<String, String>> _items;

  @override
  void initState() {
    super.initState();
    _items = List.of(widget.entries);
  }

  void _add() {
    setState(() => _items.add(const MapEntry('', '')));
    widget.onChanged(List.of(_items));
  }

  void _remove(int i) {
    setState(() => _items.removeAt(i));
    widget.onChanged(List.of(_items));
  }

  void _update(int i, {String? key, String? value}) {
    final k = key ?? _items[i].key;
    final v = value ?? _items[i].value;
    setState(() => _items[i] = MapEntry(k, v));
    widget.onChanged(List.of(_items));
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(widget.title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        const Spacer(),
        FilledButton.icon(
            onPressed: _add,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Field')),
      ]),
      const SizedBox(height: 12),
      if (_items.isEmpty)
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
              border: Border.all(color: AppColors.outlineSoft),
              borderRadius: BorderRadius.circular(12)),
          child: const Center(child: Text('No custom fields yet')),
        )
      else
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final e = _items[i];
            return Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.outlineSoft)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(
                            child: TextField(
                          decoration: const InputDecoration(
                              labelText: 'Title', border: OutlineInputBorder()),
                          controller: TextEditingController(text: e.key),
                          onChanged: (v) => _update(i, key: v),
                        )),
                        const SizedBox(width: 8),
                        IconButton(
                            onPressed: () => _remove(i),
                            icon: const Icon(Icons.delete_outline),
                            color: AppColors.error),
                      ]),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: const InputDecoration(
                            labelText: 'Content',
                            hintText:
                                'Add details (license number, notes, etc.)',
                            border: OutlineInputBorder()),
                        controller: TextEditingController(text: e.value),
                        onChanged: (v) => _update(i, value: v),
                        maxLines: 3,
                      ),
                    ]),
              ),
            );
          },
        ),
    ]);
  }
}
