import 'package:flutter/material.dart';
import 'package:gym_app/models/Ejercicio.dart';
import 'package:gym_app/models/Serie.dart';
import 'training_serie_editor.dart';

class TrainingEjercicioCard extends StatelessWidget {
  final Ejercicio ejercicio;

  final List<Serie> series;
  final Set<String> seriesCompletadas;

  final Function(int) onToggleSerie;
  final Function(int) onEliminarSerie;
  final Function(int, TipoSerie) onActualizarTipoSerie;
  final Function(int, int) onActualizarReps;
  final Function(int, double) onActualizarPeso;

  final VoidCallback onAddSerie;
  final Function(int serieIndex) onAddSubserie;
  final Function(int serieIndex, int subIndex) onEliminarSubserie;
  final Function(int serieIndex, int subIndex, int reps) onActualizarSubReps;
  final Function(int serieIndex, int subIndex, double peso) onActualizarSubPeso;

  final VoidCallback onRemoveConfirmed;
  final ThemeData theme;

  const TrainingEjercicioCard({
    super.key,
    required this.ejercicio,
    required this.series,
    required this.seriesCompletadas,
    required this.onToggleSerie,
    required this.onEliminarSerie,
    required this.onActualizarTipoSerie,
    required this.onActualizarReps,
    required this.onActualizarPeso,
    required this.onAddSerie,
    required this.onAddSubserie,
    required this.onEliminarSubserie,
    required this.onActualizarSubReps,
    required this.onActualizarSubPeso,
    required this.onRemoveConfirmed,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = theme.cardColor;
    final borderColor = theme.brightness == Brightness.dark
        ? Colors.grey.shade700
        : Colors.grey.shade300;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: borderColor, width: 1),
      ),
      child: Column(
        children: [
          // ---- CABECERA DEL EJERCICIO ----
          ListTile(
            title: Text(
              "• ${ejercicio.nombre}",
              style: theme.textTheme.bodyMedium,
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: theme.colorScheme.error),
              onPressed: () async {
                final confirmar = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Eliminar ejercicio"),
                    content: const Text(
                        "¿Seguro que quieres eliminar este ejercicio completo?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancelar"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("Eliminar"),
                      ),
                    ],
                  ),
                );
                if (confirmar == true) onRemoveConfirmed();
              },
            ),
          ),

          // ---- SERIES ----
          TrainingSerieEditor(
            pkEjercicio: ejercicio.pk_ejercicio,
            series: series,
            seriesCompletadas: seriesCompletadas,
            onToggleSerie: onToggleSerie,
            onEliminarSerie: onEliminarSerie,
            onActualizarTipoSerie: onActualizarTipoSerie,
            onActualizarReps: onActualizarReps,
            onActualizarPeso: onActualizarPeso,
            onAddSerie: onAddSerie,
            onAddSubserie: onAddSubserie,
            onEliminarSubserie: onEliminarSubserie,
            onActualizarSubReps: onActualizarSubReps,
            onActualizarSubPeso: onActualizarSubPeso,
            theme: theme,
          ),
        ],
      ),
    );
  }
}