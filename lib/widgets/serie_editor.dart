import 'package:flutter/material.dart';
import 'package:gym_app/models/Serie.dart';

class SerieEditor extends StatelessWidget {
  final List<Serie> series;
  final Color borderColor;
  final VoidCallback onAddSerie;
  final Function(int) onEliminarSerie;
  final Function(int, TipoSerie) onActualizarTipoSerie;
  final ThemeData theme;

  SerieEditor({
    required this.series,
    required this.borderColor,
    required this.onAddSerie,
    required this.onEliminarSerie,
    required this.onActualizarTipoSerie,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final headerColor = theme.brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade200;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          if (series.isEmpty)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: borderColor, width: 1),
                ),
              ),
              child: TextButton.icon(
                icon: Icon(Icons.add, size: 16, color: theme.colorScheme.primary),
                label: Text('Añadir serie', style: TextStyle(color: theme.colorScheme.primary)),
                style: TextButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 12)),
                onPressed: onAddSerie,
              ),
            ),
          if (series.isNotEmpty)
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: headerColor,
                    border: Border(
                      top: BorderSide(color: borderColor, width: 1),
                      bottom: BorderSide(color: borderColor, width: 1),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(flex: 2, child: Text('Tipo', style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(flex: 3, child: Text('Último', style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(flex: 3, child: Text('Reps', style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(flex: 3, child: Text('Peso', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: series.length,
                  itemBuilder: (context, index) {
                    final serie = series[index];

                    return Dismissible(
                      key: Key('serie-${serie.numeroSerie}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) {
                        onEliminarSerie(index);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: borderColor, width: 0.5)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Center(
                                  child: InkWell(
                                    onTap: () {
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (context) {
                                          return Container(
                                            padding: EdgeInsets.all(16),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: TipoSerie.values.map((tipo) {
                                                return ListTile(
                                                  leading: CircleAvatar(
                                                    backgroundColor: theme.colorScheme.primary,
                                                    radius: 15,
                                                    child: Text(
                                                      _getAbreviacionTipo(tipo),
                                                      style: TextStyle(color: Colors.white, fontSize: 15),
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
                                    },
                                    child: CircleAvatar(
                                      backgroundColor: theme.colorScheme.primary,
                                      radius: 15,
                                      child: Text(
                                        _getAbreviacionTipo(serie.tipo),
                                        style: TextStyle(color: Colors.white, fontSize: 15),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Center(child: Text('-')),
                              ),
                              Expanded(
                                flex: 3,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('-'),
                                      const SizedBox(width: 6),
                                      Text('reps')
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('-'),
                                      const SizedBox(width: 6),
                                      Text('kg')
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: borderColor, width: 0.5),
                    ),
                  ),
                  child: TextButton.icon(
                    icon: Icon(Icons.add, size: 16, color: theme.colorScheme.primary),
                    label: Text('Añadir serie', style: TextStyle(color: theme.colorScheme.primary)),
                    style: TextButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 12)),
                    onPressed: onAddSerie,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _getAbreviacionTipo(TipoSerie tipo) {
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