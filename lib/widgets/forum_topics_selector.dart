import 'package:flutter/material.dart';

class ForumTopicsSelector extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: allTopics.map((topic) {
        final selected = selectedTopics.contains(topic);
        return ChoiceChip(
          label: Text(topic, overflow: TextOverflow.ellipsis),
          selected: selected,
          onSelected: (value) {
            final newSelection = List<String>.from(selectedTopics);
            if (selected) {
              newSelection.remove(topic);
            } else {
              newSelection.add(topic);
            }
            onSelectionChanged(newSelection);
          },
          selectedColor: Theme.of(context).colorScheme.primary,
          labelStyle: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: selected
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          showCheckmark: false,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        );
      }).toList(),
    );
  }
}