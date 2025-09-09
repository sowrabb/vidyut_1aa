import 'package:flutter/material.dart';
import '../../sell/models.dart';
import '../../../app/tokens.dart';

class MaterialsSelector extends StatefulWidget {
  final List<String> value;
  final ValueChanged<List<String>> onChanged;
  final String label;
  const MaterialsSelector(
      {super.key,
      required this.value,
      required this.onChanged,
      this.label = 'Materials Used'});

  @override
  State<MaterialsSelector> createState() => _MaterialsSelectorState();
}

class _MaterialsSelectorState extends State<MaterialsSelector> {
  late List<String> _selected;
  final TextEditingController _textCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selected = List.of(widget.value);
  }

  @override
  void didUpdateWidget(covariant MaterialsSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _selected = List.of(widget.value);
    }
  }

  void _add(String m) {
    if (m.isEmpty) return;
    if (!_selected.contains(m)) {
      setState(() => _selected.add(m));
      widget.onChanged(List.of(_selected));
    }
  }

  void _remove(String m) {
    setState(() => _selected.remove(m));
    widget.onChanged(List.of(_selected));
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(widget.label, style: Theme.of(context).textTheme.titleSmall),
      const SizedBox(height: 8),
      Autocomplete<String>(
        optionsBuilder: (TextEditingValue value) {
          final q = value.text.toLowerCase();
          if (q.isEmpty) {
            return const Iterable<String>.empty();
          }
          return kMaterials
              .where((m) => m.toLowerCase().contains(q))
              .where((m) => !_selected.contains(m));
        },
        onSelected: (s) {
          _add(s);
          _textCtrl.clear();
        },
        fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
          // Keep ref so we can clear on add
          if (_textCtrl != controller) {
            _textCtrl.text = controller.text;
          }
          return TextField(
            controller: controller,
            focusNode: focusNode,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.tag),
              hintText: 'Type or select a material, press Enter to add',
            ),
            onSubmitted: (v) {
              final vv = v.trim();
              if (vv.isNotEmpty) {
                _add(vv);
                controller.clear();
              }
            },
          );
        },
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _selected
            .map((m) => InputChip(
                  label: Text(m),
                  onDeleted: () => _remove(m),
                  backgroundColor: AppColors.surfaceAlt,
                ))
            .toList(),
      ),
    ]);
  }
}
