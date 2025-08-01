import 'package:flutter/material.dart';
import '../../models/Ejercicio.dart';
import '../../models/Serie.dart';
import 'serie_editor.dart';

class EjercicioCard extends StatelessWidget {
  final Ejercicio ejercicio;
  final VoidCallback onRemove;
  final List<Serie> series;
  final VoidCallback onAddSerie;
  final Function(int) onEliminarSerie;
  final Function(int, TipoSerie) onActualizarTipoSerie;
  final Function(int, int) onActualizarRepeticiones;
  final Function(int, double) onActualizarPeso;
  final ThemeData theme;

  EjercicioCard({
    required this.ejercicio,
    required this.onRemove,
    required this.series,
    required this.onAddSerie,
    required this.onEliminarSerie,
    required this.onActualizarTipoSerie,
    required this.onActualizarRepeticiones,
    required this.onActualizarPeso,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = theme.cardColor;
    final borderColor =
    theme.brightness == Brightness.dark ? Colors.grey.shade700 : Colors.grey.shade300;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: borderColor, width: 1),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(ejercicio.nombre),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: theme.colorScheme.error),
              onPressed: onRemove,
            ),
          ),
          SerieEditor(
            series: series,
            borderColor: borderColor,
            onAddSerie: onAddSerie,
            onEliminarSerie: onEliminarSerie,
            onActualizarTipoSerie: onActualizarTipoSerie,
            theme: theme,
          ),
        ],
      ),
    );
  }
}