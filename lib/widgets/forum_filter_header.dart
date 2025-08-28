import 'package:flutter/material.dart';
import '../screens/forum_settings_screen.dart';

class ForumFilterHeader extends StatelessWidget {
  final String selected;            // 👈 valor controlado desde arriba
  final Function(String) onChanged;

  const ForumFilterHeader({
    Key? key,
    required this.selected,
    required this.onChanged,
  }) : super(key: key);

  final List<String> options = const ['POPULAR', 'LO ÚLTIMO'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          height: 45,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final optionWidth = constraints.maxWidth / options.length;

                    return Stack(
                      children: [
                        // 🔹 Highlight que se mueve
                        AnimatedAlign(
                          alignment: selected == 'POPULAR'
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: Container(
                            width: optionWidth - 8, // deja espacio
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                        ),

                        // 🔹 Opciones de texto
                        Row(
                          children: options.map((option) {
                            final isSelected = selected == option;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => onChanged(option),
                                child: Center(
                                  child: Text(
                                    option,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? theme.colorScheme.primary
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),

              // Botón de ajustes
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ForumSettingsScreen()),
                  );
                },
                icon: Icon(Icons.settings, color: theme.colorScheme.primary),
              ),
            ],
          ),
        ),
        Divider(
          thickness: 1,
          height: 0,
          color: theme.dividerColor.withOpacity(0.6),
        ),
      ],
    );
  }
}