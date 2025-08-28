import 'package:flutter/material.dart';
import 'package:gym_app/models/Serie.dart';

class TrainingSerieEditor extends StatelessWidget {
  final int pkEjercicio;
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

  final ThemeData theme;

  const TrainingSerieEditor({
    super.key,
    required this.pkEjercicio,
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
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = theme.brightness == Brightness.dark
        ? Colors.grey.shade700
        : Colors.grey.shade300;

    final headerColor = theme.brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.grey.shade200;

    return Column(
      children: [
        // ---- CABECERA ----
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: headerColor,
            border: Border(
              top: BorderSide(color: borderColor, width: 1),
              bottom: BorderSide(color: borderColor, width: 1),
            ),
          ),
          child: Row(
            children: const [
              SizedBox(width: 40), // checkbox
              Expanded(flex: 2, child: Text("Tipo", textAlign: TextAlign.center)),
              Expanded(flex: 1, child: Text("Reps", textAlign: TextAlign.center)),
              Expanded(flex: 1, child: Text("Peso", textAlign: TextAlign.center)),
            ],
          ),
        ),

        // ---- SERIES ----
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: series.length,
          itemBuilder: (context, index) {
            final serie = series[index];
            final key = "$pkEjercicio-$index";
            final done = seriesCompletadas.contains(key);

            String repsText = "-";
            String pesoText = "-";

            if (serie.tipo != TipoSerie.dropset) {
              if (serie.repeticiones.isNotEmpty) repsText = serie.repeticiones.join("-");
              if (serie.peso.isNotEmpty) pesoText = serie.peso.join("-");
            } else if (serie.subseries != null && serie.subseries!.isNotEmpty) {
              final primera = serie.subseries!.first;
              if (primera.repeticiones.isNotEmpty) repsText = primera.repeticiones.join("-");
              if (primera.peso.isNotEmpty) pesoText = primera.peso.join("-");
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---- FILA PRINCIPAL ----
                Dismissible(
                  key: Key('serie-${serie.numeroSerie}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => onEliminarSerie(index),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: borderColor, width: 0.5)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Row(
                      children: [
                        // Checkbox
                        SizedBox(
                          width: 40,
                          child: Checkbox(
                            value: done,
                            onChanged: (_) => onToggleSerie(index),
                          ),
                        ),

                        // Tipo
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: InkWell(
                              onTap: () => _showTipoSelector(context, index),
                              child: CircleAvatar(
                                radius: 14,
                                backgroundColor: theme.colorScheme.primary,
                                child: Text(
                                  _abreviacionTipo(serie.tipo),
                                  style: const TextStyle(color: Colors.white, fontSize: 13),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Reps (editable)
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: _NumberField(
                              initial: repsText,
                              onChanged: (val) {
                                final num = int.tryParse(val);
                                if (num != null) onActualizarReps(index, num);
                              },
                            ),
                          ),
                        ),

                        // Peso (editable)
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: _NumberField(
                              initial: pesoText,
                              onChanged: (val) {
                                final num = double.tryParse(val);
                                if (num != null) onActualizarPeso(index, num);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ---- SUBSERIES DE DROPSET Y BOTÓN AÑADIR ----
                if (serie.tipo == TipoSerie.dropset)
                  Padding(
                    padding: const EdgeInsets.only(left: 40),
                    child: Column(
                      children: [
                        // Mostrar subseries adicionales (si existen más de una)
                        if (serie.subseries != null && serie.subseries!.length > 1)
                          ...serie.subseries!
                              .asMap()
                              .entries
                              .skip(1)
                              .map((entry) {
                            final sub = entry.value;
                            final subIndex = entry.key;

                            final subReps = sub.repeticiones.isNotEmpty ? sub.repeticiones.join("-") : "-";
                            final subPeso = sub.peso.isNotEmpty ? sub.peso.join("-") : "-";

                            return Dismissible(
                              key: Key("subserie-${serie.numeroSerie}-$subIndex"),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              onDismissed: (_) => onEliminarSubserie(index, subIndex),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(color: borderColor, width: 0.5)),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                child: Row(
                                  children: [
                                    const SizedBox(width: 40), // sin checkbox
                                    const Spacer(flex: 2), // sin tipo
                                    Expanded(
                                      flex: 1,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                        child: _NumberField(
                                          initial: subReps,
                                          onChanged: (v) {
                                            final rep = int.tryParse(v);
                                            if (rep != null) {
                                              onActualizarSubReps(index, subIndex, rep);
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                        child: _NumberField(
                                          initial: subPeso,
                                          onChanged: (v) {
                                            final peso = double.tryParse(v);
                                            if (peso != null) {
                                              onActualizarSubPeso(index, subIndex, peso);
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),

                        // ---- BOTÓN AÑADIR SUBSERIE (SIEMPRE VISIBLE PARA DROPSETS) ----
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            icon: Icon(Icons.add, size: 14, color: theme.colorScheme.primary),
                            label: Text("Añadir subserie", style: TextStyle(color: theme.colorScheme.primary)),
                            onPressed: () => onAddSubserie(index),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),

        // ---- BOTÓN AÑADIR SERIE ----
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: borderColor, width: 0.5)),
          ),
          child: TextButton.icon(
            icon: Icon(Icons.add, size: 16, color: theme.colorScheme.primary),
            label: Text('Añadir serie', style: TextStyle(color: theme.colorScheme.primary)),
            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 10)),
            onPressed: onAddSerie,
          ),
        ),
      ],
    );
  }

  void _showTipoSelector(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: TipoSerie.values.map((tipo) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    _abreviacionTipo(tipo),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(tipo.nombre),
                onTap: () {
                  onActualizarTipoSerie(index, tipo);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  String _abreviacionTipo(TipoSerie tipo) {
    switch (tipo) {
      case TipoSerie.normal:
        return "N";
      case TipoSerie.calentamiento:
        return "C";
      case TipoSerie.dropset:
        return "DS";
      case TipoSerie.restpause:
        return "RP";
      case TipoSerie.negativas:
        return "NE";
    }
  }
}

class _NumberField extends StatelessWidget {
  final String initial;
  final void Function(String) onChanged;

  const _NumberField({
    required this.initial,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initial != "-" ? initial : "",
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 13),
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        hintText: "-",
      ),
      onChanged: onChanged, // <<-- en vez de onFieldSubmitted
    );
  }
}