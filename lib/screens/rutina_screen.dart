import 'package:flutter/material.dart';
import 'package:gym_app/models/Ejercicio.dart';
import 'package:gym_app/services/template_service.dart';
import 'package:gym_app/screens/add_ejercicio_screen.dart';
import 'package:gym_app/models/Serie.dart';
import 'package:gym_app/widgets/ejercicio_card.dart';

class RutinaScreen extends StatefulWidget {
  final String? rutinaId;

  const RutinaScreen({Key? key, this.rutinaId}) : super(key: key);

  @override
  State<RutinaScreen> createState() => _RutinaScreenState();
}

class _RutinaScreenState extends State<RutinaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  bool _isLoading = false;

  final TemplateService _templateService = TemplateService();

  bool get isEdit => widget.rutinaId != null;

  List<Ejercicio> _ejercicios = [];
  Map<Ejercicio, List<Serie>> _seriesPorEjercicio = {};

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _loadRutina();
    }
  }

  Future<void> _loadRutina() async {
    setState(() => _isLoading = true);
    try {
      final data = await _templateService.getRutinaPorId(widget.rutinaId!);
      _nombreController.text = data['nombre'] ?? '';

      /// ✅ Definir aquí las listas temporales
      final List<Ejercicio> ejerciciosList = [];
      final Map<Ejercicio, List<Serie>> seriesPorEjercicio = {};

      final ejerciciosRaw = (data['ejercicios'] is List) ? data['ejercicios'] : [];

      for (var ej in ejerciciosRaw) {
        final int pk = ej['pk_ejercicio'];
        final ejercicio = Ejercicio(
          pk_ejercicio: pk,
          nombre: '',
          grupo_muscular: '',
          equipamiento: '',
        );
        ejerciciosList.add(ejercicio);

        final seriesRaw = ej['series'] as List<dynamic>? ?? [];
        final seriesList = List<Serie>.from(
          seriesRaw.map((s) => Serie.fromJson(s)),
        );
        seriesPorEjercicio[ejercicio] = seriesList;
      }

      setState(() {
        _ejercicios = ejerciciosList;
        _seriesPorEjercicio = seriesPorEjercicio;
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error cargando rutina: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onAddEjercicioPressed() async {
    final List<Ejercicio>? selectedEjercicios = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEjercicioScreen(
          ejerciciosYaAnadidos: _ejercicios,
        ),
      ),
    );

    if (selectedEjercicios != null) {
      setState(() {
        for (var ejercicio in selectedEjercicios) {
          _ejercicios.add(ejercicio);
          _seriesPorEjercicio[ejercicio] = [];
        }
      });
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_ejercicios.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Agrega al menos un ejercicio')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 🔥 Construcción del JSON completo de ejercicios
      final ejerciciosJson = _ejercicios.asMap().entries.map((entry) {
        final index = entry.key;
        final ejercicio = entry.value;

        return {
          "orden": index + 1,
          "pk_ejercicio": ejercicio.pk_ejercicio,
          "series": (_seriesPorEjercicio[ejercicio] ?? [])
              .map((serie) => serie.toJson()) // 🔥 directo
              .toList(),
        };
      }).toList();

      // ======== Guardado en Supabase ========
      if (isEdit) {
        await _templateService.actualizarRutina(
          widget.rutinaId!,
          _nombreController.text,
          ejerciciosJson,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rutina actualizada')),
        );
      } else {
        await _templateService.crearRutina(
          _nombreController.text,
          ejerciciosJson,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rutina creada')),
        );
      }

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _agregarSerie(Ejercicio ejercicio) {
    setState(() {
      final nuevaSerie = Serie(
        tipo: TipoSerie.normal,
        peso: [],
        repeticiones: [],
        numeroSerie: (_seriesPorEjercicio[ejercicio]?.length ?? 0) + 1,
      );
      if (_seriesPorEjercicio[ejercicio] == null) {
        _seriesPorEjercicio[ejercicio] = [];
      }
      _seriesPorEjercicio[ejercicio]!.add(nuevaSerie);
    });
  }

  void _eliminarSerie(Ejercicio ejercicio, int index) {
    setState(() {
      if (_seriesPorEjercicio.containsKey(ejercicio) &&
          _seriesPorEjercicio[ejercicio]!.length > index) {
        _seriesPorEjercicio[ejercicio]!.removeAt(index);
        final series = _seriesPorEjercicio[ejercicio];
        if (series != null) {
          for (int i = 0; i < series.length; i++) {
            series[i] = series[i].copyWith(numeroSerie: i + 1);
          }
        }
      }
    });
  }

  void _actualizarTipoSerie(Ejercicio ejercicio, int index, TipoSerie nuevoTipo) {
    setState(() {
      final serie = _seriesPorEjercicio[ejercicio]![index];

      if (nuevoTipo == TipoSerie.dropset) {
        _seriesPorEjercicio[ejercicio]![index] = serie.copyWith(
          tipo: nuevoTipo,
          subseries: [
            Serie(
              tipo: TipoSerie.normal,
              peso: [],
              repeticiones: [],
              numeroSerie: 1,
            )
          ],
        );
      } else {
        _seriesPorEjercicio[ejercicio]![index] = serie.copyWith(
          tipo: nuevoTipo,
          subseries: null,
        );
      }
    });
  }

  void _actualizarRepeticiones(Ejercicio ejercicio, int index, int valor) {
    setState(() {
      final serie = _seriesPorEjercicio[ejercicio]![index];
      final nuevasReps = List<int>.from(serie.repeticiones)..add(valor);
      _seriesPorEjercicio[ejercicio]![index] =
          serie.copyWith(repeticiones: nuevasReps);
    });
  }

  void _actualizarPeso(Ejercicio ejercicio, int index, double valor) {
    setState(() {
      final serie = _seriesPorEjercicio[ejercicio]![index];
      final nuevosPesos = List<double>.from(serie.peso)..add(valor);
      _seriesPorEjercicio[ejercicio]![index] =
          serie.copyWith(peso: nuevosPesos);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar plantilla' : 'Crear plantilla'),
        actions: [
          if (isEdit)
            IconButton(
                onPressed: () {
                  // TODO: implementar eliminar rutina aquí
                },
                icon: Icon(Icons.delete, color: theme.colorScheme.error)),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(Icons.star, color: theme.colorScheme.onPrimary),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                    onPressed: _guardar,
                    label: Text(isEdit ? 'Guardar cambios' : 'Crear'),
                  ),
                  OutlinedButton.icon(
                    icon: Icon(Icons.cancel, color: theme.colorScheme.error),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      side: BorderSide(color: theme.colorScheme.error, width: 1.5),
                    ),
                    onPressed: () => Navigator.pop(context),
                    label: Text('Cancelar'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 350,
                      child: TextFormField(
                        controller: _nombreController,
                        decoration: InputDecoration(
                          labelText: 'Nombre de la plantilla',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                        ),
                        validator: (v) =>
                        v == null || v.isEmpty ? 'Escribe un nombre' : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 200,
                      child: OutlinedButton.icon(
                        icon: Icon(Icons.add, color: theme.colorScheme.primary),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.primary,
                          side: BorderSide(
                              color: theme.colorScheme.primary, width: 1.5),
                        ),
                        label: Text('Añadir ejercicio'),
                        onPressed: _onAddEjercicioPressed,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (_ejercicios.isEmpty)
                Center(child: Text('No hay ejercicios añadidos.')),
              ..._ejercicios.map((ejercicio) {
                return EjercicioCard(
                  ejercicio: ejercicio,
                  onRemove: () {
                    setState(() {
                      _ejercicios.remove(ejercicio);
                      _seriesPorEjercicio.remove(ejercicio);
                    });
                  },
                  series: _seriesPorEjercicio[ejercicio] ?? [],
                  onAddSerie: () => _agregarSerie(ejercicio),
                  onEliminarSerie: (index) => _eliminarSerie(ejercicio, index),
                  onActualizarTipoSerie: (index, tipo) =>
                      _actualizarTipoSerie(ejercicio, index, tipo),
                  onActualizarRepeticiones: (index, rep) =>
                      _actualizarRepeticiones(ejercicio, index, rep),
                  onActualizarPeso: (index, peso) =>
                      _actualizarPeso(ejercicio, index, peso),
                  theme: theme,
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}