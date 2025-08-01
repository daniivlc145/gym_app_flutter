import 'package:flutter/material.dart';

class CadenaCard extends StatelessWidget {
  final String id;
  final String nombre;
  final String logo;
  final bool isSelected;
  final VoidCallback onTap;

  const CadenaCard({
    required this.id,
    required this.nombre,
    required this.logo,
    required this.isSelected,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: isSelected
            ? colorScheme.primary.withOpacity(0.2)
            : colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(logo, height: 50, width: 50),
            const SizedBox(height: 10),
            Text(
              nombre,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}