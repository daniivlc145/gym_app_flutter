import 'dart:async';
import 'dart:io'; // 👈 para Platform.isAndroid
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gym_app/models/Ejercicio.dart';
import 'package:gym_app/models/Serie.dart';
import 'package:gym_app/screens/add_ejercicio_screen.dart';

import '../services/ejercicio_service.dart';
import '../widgets/training_ejercicio_card.dart';
import 'confirm_training_screen.dart';

class CurrentTrainingScreen extends StatefulWidget {
  final String? rutinaId;
  final Map<String, dynamic>? rutina;

  const CurrentTrainingScreen({Key? key, this.rutinaId, this.rutina})
      : super(key: key);

  @override
  State<CurrentTrainingScreen> createState() => _CurrentTrainingScreenState();
}

class _CurrentTrainingScreenState extends State<CurrentTrainingScreen> {
  List<Ejercicio> _ejercicios = [];
  Map<Ejercicio, List<Serie>> _seriesPorEjercicio = {};
  Set<String> seriesCompletadas = {};

  late Stopwatch _stopwatch;
  late Timer _timer;
  String tiempo = "00:00:00";
  bool _isLoading = false; // 👈 flag de carga

  String get nombreEntrenamiento =>
      widget.rutina != null
          ? widget.rutina!['nombre'] ?? "Rutina sin nombre"
          : "Nuevo entrenamiento";

  bool get _tieneEjercicios => _ejercicios.isNotEmpty;
  bool get _tieneSeries => _seriesPorEjercicio.values.any((list) => list.isNotEmpty);
  bool get _tieneSeriesCompletadas => seriesCompletadas.isNotEmpty;
  bool get _puedeFinalizarEntrenamiento => _tieneEjercicios && _tieneSeries && _tieneSeriesCompletadas;

  String get _mensajeValidacion {
    if (!_tieneEjercicios) {
      return "⚠️ Añade al menos un ejercicio antes de finalizar";
    }
    if (!_tieneSeries) {
      return "⚠️ Añade al menos una serie antes de finalizar";
    }
    if (!_tieneSeriesCompletadas) {
      return "⚠️ Marca al menos una serie como completada antes de finalizar";
    }
    return "";
  }

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch()..start();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final elapsed = _stopwatch.elapsed;
      setState(() {
        tiempo =
        "${elapsed.inHours.toString().padLeft(2, '0')}:"
            "${(elapsed.inMinutes % 60).toString().padLeft(2, '0')}:"
            "${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}";
      });
    });

    if (widget.rutina != null) _cargarRutina(widget.rutina!);
  }

  @override
  void dispose() {
    _timer.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  Future<void> _cargarRutina(Map<String, dynamic> rutina) async {
    setState(() => _isLoading = true);
    try {
      final ejerciciosRaw = (rutina['ejercicios'] is Map &&
          rutina['ejercicios']['ejercicios'] is List)
          ? rutina['ejercicios']['ejercicios']
          : [];

      final list = <Ejercicio>[];
      final map = <Ejercicio, List<Serie>>{};

      for (var ej in ejerciciosRaw) {
        var ejercicio = Ejercicio(
          pk_ejercicio: ej['pk_ejercicio'],
          nombre: ej['nombre'] ?? '',
          grupo_muscular: '',
          equipamiento: '',
        );

        if (ejercicio.nombre.isEmpty) {
          final nombreReal = await EjercicioService()
              .getNombreEjercicioPorId(ejercicio.pk_ejercicio.toString());
          ejercicio = ejercicio.copyWith(nombre: nombreReal);
        }

        final seriesRaw = ej['series'] as List<dynamic>? ?? [];
        final seriesList =
        List<Serie>.from(seriesRaw.map((s) => Serie.fromJson(s)));

        list.add(ejercicio);
        map[ejercicio] = seriesList;
      }

      setState(() {
        _ejercicios = list;
        _seriesPorEjercicio = map;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Map<String, dynamic> _crearJsonEntrenamiento(List<Ejercicio> ejerciciosCompletados) {
    final json = {
      "ejercicios": ejerciciosCompletados.asMap().entries.map((entry) {
        final orden = entry.key + 1;
        final ejercicio = entry.value;

        final series = _seriesPorEjercicio[ejercicio]!
            .asMap()
            .entries
            .where((serieEntry) =>
            seriesCompletadas.contains("${ejercicio.pk_ejercicio}-${serieEntry.key}"))
            .map((serieEntry) {
          final serie = serieEntry.value;
          return {
            "n_serie": serie.numeroSerie,
            "tipo": serie.tipo.toString(),
            "reps": serie.repeticiones,
            "peso": serie.peso,
            if (serie.subseries != null && serie.subseries!.isNotEmpty)
              "series": serie.subseries!.map((s) => {
                "reps": s.repeticiones,
                "peso": s.peso,
              }).toList()
          };
        }).toList();

        return {
          "orden": orden,
          "pk_ejercicio": ejercicio.pk_ejercicio,
          "series": series,
        };
      }).toList(),
    };

    return json;
  }

  void _toggleSerie(Ejercicio e, int i) {
    final key = "${e.pk_ejercicio}-$i";
    setState(() {
      seriesCompletadas.contains(key)
          ? seriesCompletadas.remove(key)
          : seriesCompletadas.add(key);
    });
  }

  void _agregarSerie(Ejercicio e) {
    final nuevaSerie = Serie(
      tipo: TipoSerie.normal,
      peso: [],
      repeticiones: [],
      numeroSerie: (_seriesPorEjercicio[e]?.length ?? 0) + 1,
    );
    setState(() {
      _seriesPorEjercicio.putIfAbsent(e, () => []);
      _seriesPorEjercicio[e]!.add(nuevaSerie);
    });
  }

  void _agregarSubserie(Ejercicio e, int serieIndex) {
    setState(() {
      final serie = _seriesPorEjercicio[e]![serieIndex];
      final nuevasSubs = List<Serie>.from(serie.subseries ?? []);
      nuevasSubs.add(Serie(
        tipo: TipoSerie.normal,
        repeticiones: [],
        peso: [],
        numeroSerie: nuevasSubs.length + 1,
      ));
      _seriesPorEjercicio[e]![serieIndex] =
          serie.copyWith(subseries: nuevasSubs);
    });
  }

  void _eliminarSubserie(Ejercicio e, int serieIndex, int subIndex) {
    setState(() {
      final serie = _seriesPorEjercicio[e]![serieIndex];
      final nuevasSubs = List<Serie>.from(serie.subseries ?? []);
      if (subIndex < nuevasSubs.length) nuevasSubs.removeAt(subIndex);
      _seriesPorEjercicio[e]![serieIndex] =
          serie.copyWith(subseries: nuevasSubs);
    });
  }

  void _actualizarSubReps(Ejercicio e, int serieIndex, int subIndex, int rep) {
    setState(() {
      final serie = _seriesPorEjercicio[e]![serieIndex];
      final nuevasSubs = List<Serie>.from(serie.subseries ?? []);
      if (subIndex < nuevasSubs.length) {
        final sub = nuevasSubs[subIndex];
        nuevasSubs[subIndex] =
            sub.copyWith(repeticiones: [...sub.repeticiones, rep]);
      }
      _seriesPorEjercicio[e]![serieIndex] =
          serie.copyWith(subseries: nuevasSubs);
    });
  }

  void _actualizarSubPeso(
      Ejercicio e, int serieIndex, int subIndex, double peso) {
    setState(() {
      final serie = _seriesPorEjercicio[e]![serieIndex];
      final nuevasSubs = List<Serie>.from(serie.subseries ?? []);
      if (subIndex < nuevasSubs.length) {
        final sub = nuevasSubs[subIndex];
        nuevasSubs[subIndex] = sub.copyWith(peso: [...sub.peso, peso]);
      }
      _seriesPorEjercicio[e]![serieIndex] =
          serie.copyWith(subseries: nuevasSubs);
    });
  }

  Future<void> _onAddEjercicioPressed() async {
    final seleccionados = await Navigator.push<List<Ejercicio>>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AddEjercicioScreen(ejerciciosYaAnadidos: _ejercicios),
      ),
    );

    if (seleccionados != null && seleccionados.isNotEmpty) {
      setState(() {
        for (var e in seleccionados) {
          // evitar duplicados
          if (!_ejercicios.contains(e)) {
            _ejercicios.add(e);
            _seriesPorEjercicio[e] = [];
          }
        }
      });
    }
  }

  void _cancelarEntrenamiento() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Cancelar entrenamiento"),
        content: const Text(
            "Si cancelas, el progreso no se guardará. ¿Seguro que quieres salir?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Volver")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Cancelar"),
          ),
        ],
      ),
    );
  }

  void _mostrarMensajeValidacion() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_mensajeValidacion)),
    );
  }

  void _finalizarEntrenamiento() {
    // Esta función solo se ejecutará si pasa las validaciones
    final totalSeries = _seriesPorEjercicio.values.fold<int>(0, (acc, list) => acc + list.length);
    final hechas = seriesCompletadas.length;

    if (hechas < totalSeries) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Series pendientes"),
          content: const Text("Todavía hay series sin completar. ¿Quieres finalizar igualmente?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Seguir")),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _irAResumen();
              },
              child: const Text("Finalizar"),
            ),
          ],
        ),
      );
    } else {
      _irAResumen();
    }
  }

  void _irAResumen() {
    final ejerciciosCompletados = _ejercicios.where((e) {
      final claves = seriesCompletadas.where((s) => s.startsWith("${e.pk_ejercicio}-"));
      return claves.isNotEmpty;
    }).toList();

    final numEjerciciosCompletados = ejerciciosCompletados.length;
    final numSeriesCompletadas = seriesCompletadas.length;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmTrainingScreen(
          datos: {
            "nombre": nombreEntrenamiento,
            "duracion": _stopwatch.elapsed.inMinutes,
            "ejercicios": numEjerciciosCompletados,
            "series": numSeriesCompletadas,
            "detalles": _crearJsonEntrenamiento(ejerciciosCompletados),
          },
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            tooltip: "Cancelar entrenamiento",
            onPressed: _cancelarEntrenamiento,
          ),
          actions: [
            // Usamos un GestureDetector para capturar toques cuando está deshabilitado
            GestureDetector(
              onTap: !_puedeFinalizarEntrenamiento ? _mostrarMensajeValidacion : null,
              child: IconButton(
                icon: Icon(
                  Icons.check,
                  color: _puedeFinalizarEntrenamiento
                      ? theme.colorScheme.primary
                      : theme.disabledColor,
                ),
                tooltip: "Finalizar entrenamiento",
                // Solo asignamos onPressed si puede finalizar
                onPressed: _puedeFinalizarEntrenamiento ? _finalizarEntrenamiento : null,
              ),
            ),
          ],
        ),
        body: _isLoading
            ? Center(
          child: Platform.isAndroid
              ? const CircularProgressIndicator()
              : const CupertinoActivityIndicator(),
        )
            : Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("${nombreEntrenamiento} (en curso)",
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text("Duración: $tiempo",
                  style: theme.textTheme.bodyLarge),
              const SizedBox(height: 20),
              Expanded(
                child: _ejercicios.isEmpty
                    ? const Center(
                    child: Text(
                        "Entrenamiento vacío. Añade ejercicios."))
                    : ListView.builder(
                  itemCount: _ejercicios.length,
                  itemBuilder: (_, i) {
                    final e = _ejercicios[i];
                    final series = _seriesPorEjercicio[e] ?? [];

                    return TrainingEjercicioCard(
                      ejercicio: e,
                      series: series,
                      seriesCompletadas: seriesCompletadas,
                      theme: theme,
                      onRemoveConfirmed: () {
                        setState(() {
                          _ejercicios.removeAt(i);
                          _seriesPorEjercicio.remove(e);
                          // También limpiamos las series completadas de este ejercicio
                          seriesCompletadas.removeWhere((key) =>
                              key.startsWith("${e.pk_ejercicio}-"));
                        });
                      },
                      onToggleSerie: (j) => _toggleSerie(e, j),
                      onEliminarSerie: (j) {
                        setState(() {
                          // Limpiamos la serie completada si existe
                          final key = "${e.pk_ejercicio}-$j";
                          seriesCompletadas.remove(key);
                          _seriesPorEjercicio[e]?.removeAt(j);
                        });
                      },
                      onActualizarTipoSerie: (j, tipo) {
                        setState(() {
                          final serie = _seriesPorEjercicio[e]![j];
                          _seriesPorEjercicio[e]![j] =
                              serie.copyWith(tipo: tipo);
                        });
                      },
                      onActualizarReps: (j, rep) {
                        setState(() {
                          final serie = _seriesPorEjercicio[e]![j];
                          _seriesPorEjercicio[e]![j] = serie.copyWith(
                            repeticiones: [...serie.repeticiones, rep],
                          );
                        });
                      },
                      onActualizarPeso: (j, peso) {
                        setState(() {
                          final serie = _seriesPorEjercicio[e]![j];
                          _seriesPorEjercicio[e]![j] = serie.copyWith(
                            peso: [...serie.peso, peso],
                          );
                        });
                      },
                      onAddSerie: () => _agregarSerie(e),
                      onAddSubserie: (j) => _agregarSubserie(e, j),
                      onEliminarSubserie: (j, sub) =>
                          _eliminarSubserie(e, j, sub),
                      onActualizarSubReps: (j, sub, rep) =>
                          _actualizarSubReps(e, j, sub, rep),
                      onActualizarSubPeso: (j, sub, peso) =>
                          _actualizarSubPeso(e, j, sub, peso),
                    );
                  },
                ),
              ),
              ElevatedButton.icon(
                onPressed: _onAddEjercicioPressed,
                icon: const Icon(Icons.add),
                label: const Text("Añadir ejercicio"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}