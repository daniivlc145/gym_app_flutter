import 'package:flutter/material.dart';
class ForumTopicsSelector extends StatefulWidget {
  final List<String> allTopics;
  final List<String> selectedTopics;
  final ValueChanged<List<String>> onSelectionChanged;

  const ForumTopicsSelector({
    required this.allTopics,
    required this.selectedTopics,
    required this.onSelectionChanged,
    Key? key,
  }) : super(key: key);

  @override
  State<ForumTopicsSelector> createState() => _ForumTopicsSelectorState();
}

class _ForumTopicsSelectorState extends State<ForumTopicsSelector> {
  late List<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List<String>.from(widget.selectedTopics);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 0,
      children: widget.allTopics.map((topic) {
        final selected = _selected.contains(topic);
        return ChoiceChip(
          label: Text(topic),
          selected: selected,
          onSelected: (value) {
            setState(() {
              if (selected) {
                _selected.remove(topic);
              } else {
                _selected.add(topic);
              }
              widget.onSelectionChanged(_selected);
            });
          },
          selectedColor: Theme.of(context).colorScheme.primary,
          labelStyle: TextStyle(
              color: selected ? Colors.white : Theme.of(context).colorScheme.onSurface),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        );
      }).toList(),
    );
  }
}