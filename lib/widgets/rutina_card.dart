import 'package:flutter/material.dart';
import 'package:gym_app/widgets/nombre_ejercicio_widget.dart';

class CardRutina extends StatelessWidget {
  final Map<String, dynamic> rutina;
  final Function(String rutinaId) onEditar;
  final Function(String rutinaId, String nombreRutina) onEliminar;
  final Function(Map<String, dynamic> rutina) onEntrenar;

  const CardRutina({
    super.key,
    required this.rutina,
    required this.onEditar,
    required this.onEliminar,
    required this.onEntrenar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final String rutinaId = rutina['pk_rutina']?.toString() ?? '';
    final String nombreRutina = rutina['nombre'] ?? '';
    final ejercicios = rutina['ejercicios'];

    // ✅ recoger pk_ejercicios correctamente
    List<String> pkEjercicios = [];
    if (ejercicios is List) {
      for (var value in ejercicios) {
        if (value is Map && value['pk_ejercicio'] != null) {
          pkEjercicios.add(value['pk_ejercicio'].toString());
        }
      }
    }

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 3,
      color: theme.cardColor,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Cabecera
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    nombreRutina,
                    style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold, fontSize: 18),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: theme.colorScheme.primary),
                      onPressed: () => onEditar(rutinaId),
                      tooltip: 'Editar',
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: theme.colorScheme.error),
                      onPressed: () => onEliminar(rutinaId, nombreRutina),
                      tooltip: 'Eliminar',
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),

            // ✅ Mostrar ejercicios reales
            pkEjercicios.isEmpty
                ? Text(
              'No hay ejercicios en esta rutina',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontStyle: FontStyle.italic),
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: pkEjercicios
                  .take(3)
                  .map(
                    (pk) => Padding(
                  padding: EdgeInsets.only(bottom: 2),
                  child: NombreEjercicioWidget(pkEjercicio: pk),
                ),
              )
                  .toList(),
            ),
            if (pkEjercicios.length > 3)
              Text(
                '... y ${pkEjercicios.length - 3} más',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontStyle: FontStyle.italic),
              ),

            SizedBox(height: 16),

            // ✅ Botón de iniciar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.fitness_center),
                label: Text('INICIAR ENTRENAMIENTO'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => onEntrenar(rutina),
              ),
            ),
          ],
        ),
      ),
    );
  }
}