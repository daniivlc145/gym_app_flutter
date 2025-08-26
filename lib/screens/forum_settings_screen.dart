import 'package:flutter/material.dart';
import 'package:gym_app/services/forum_service.dart';
import 'package:gym_app/widgets/forum_metric_card.dart';
import 'package:gym_app/widgets/forum_topics_selector.dart';
import 'package:flutter/foundation.dart';

class ForumSettingsScreen extends StatefulWidget {
  const ForumSettingsScreen({Key? key}) : super(key: key);

  @override
  State<ForumSettingsScreen> createState() => _ForumSettingsScreenState();
}

class _ForumSettingsScreenState extends State<ForumSettingsScreen> {
  final ForumService _forumService = ForumService();
  final ScrollController _scrollController = ScrollController();

  late Future<Map<String, dynamic>> _userData;
  late Future<int> _numeroPosts;
  late Future<int> _numeroComentarios;
  Future<List<String>>? _allTopics;

  String _nombreUsuarioForo = "";
  List<String> _interesesSeleccionados = [];
  bool _editando = false;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  void _cargarDatos() {
    _userData = _forumService.getCurrentUserDataForum();
    _numeroPosts = _forumService.getNumeroPosts();
    _numeroComentarios = _forumService.getNumeroComentarios();
    _allTopics = _forumService.getAllTopics();
  }

  void _actualizarNombre(String nuevo) {
    setState(() {
      _nombreUsuarioForo = nuevo;
      _editando = true;
    });
  }

  void _actualizarIntereses(List<String> nuevos) {
    setState(() {
      _interesesSeleccionados = nuevos;
      _editando = true;
    });
  }

  Future<void> _guardarCambios(String nombreInicial, List<String> interesesIniciales) async {
    try {
      if (_nombreUsuarioForo.trim().isNotEmpty &&
          _nombreUsuarioForo != nombreInicial) {
        await _forumService.updateUserForumName(_nombreUsuarioForo.trim());
      }
      if (!listEquals(_interesesSeleccionados, interesesIniciales)) {
        await _forumService.updateUserInteresesForo(_interesesSeleccionados);
      }
      setState(() {
        _editando = false;
        _cargarDatos(); // Refresca los datos
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Datos guardados!'),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error al guardar: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes de Foros')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userData,
        builder: (context, userSnap) {
          if (userSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (userSnap.hasError || userSnap.data == null) {
            return const Center(
                child: Text('Error cargando usuario',
                    style: TextStyle(color: Colors.red)));
          }

          final nombreUserInicial = userSnap.data!['nombre_usuario_foro'] ?? '';
          final interesesIniciales =
              (userSnap.data!['intereses_foro'] as List?)?.cast<String>() ?? [];

          if (_nombreUsuarioForo.isEmpty) _nombreUsuarioForo = nombreUserInicial;
          if (_interesesSeleccionados.isEmpty) _interesesSeleccionados =
          List<String>.from(interesesIniciales);

          return SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 36),

                    // NOMBRE como TextField editable
                    TextField(
                      controller: TextEditingController(text: _nombreUsuarioForo),
                      onChanged: _actualizarNombre,
                      decoration: const InputDecoration(
                        labelText: "Nombre de usuario foro (@)",
                        border: OutlineInputBorder(),
                        prefixText: "@",
                      ),
                      maxLength: 25,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Métricas
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FutureBuilder<int>(
                          future: _numeroPosts,
                          builder: (context, snap) {
                            String value = snap.connectionState == ConnectionState.waiting
                                ? "..." :
                            (snap.hasError || snap.data == null ? "Error" : "${snap.data}");
                            return ForumMetricCard(value: value, label: "Posts");
                          },
                        ),
                        const SizedBox(width: 18),
                        FutureBuilder<int>(
                          future: _numeroComentarios,
                          builder: (context, snap) {
                            String value = snap.connectionState == ConnectionState.waiting
                                ? "..." :
                            (snap.hasError || snap.data == null ? "Error" : "${snap.data}");
                            return ForumMetricCard(
                              value: value,
                              label: "Comentarios",
                              width: 130,
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Tus intereses",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(height: 10),

                    FutureBuilder<List<String>>(
                      future: _allTopics,
                      builder: (context, topicSnap) {
                        if (_allTopics == null ||
                            topicSnap.connectionState == ConnectionState.waiting) {
                          return const SizedBox(
                            height: 130,
                            child: Center(child: LinearProgressIndicator()),
                          );
                        }
                        if (topicSnap.hasError) {
                          return SizedBox(
                            height: 130,
                            child: Center(
                              child: Text("Error cargando intereses: ${topicSnap.error}",
                                  style: TextStyle(color: Colors.red)),
                            ),
                          );
                        }
                        if (!topicSnap.hasData || topicSnap.data == null) {
                          return const SizedBox(
                            height: 130,
                            child: Center(child: Text("No hay intereses disponibles")),
                          );
                        }
                        return Container(
                          constraints: const BoxConstraints(
                            maxHeight: 200,
                          ),
                          padding: const EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.background, // Si tienes AppTheme, usa tu color aquí
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline,
                              width: 1,
                            ),
                          ),
                          child: Scrollbar(
                            thumbVisibility: true,
                            controller: _scrollController,
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              scrollDirection: Axis.vertical,
                              child: ForumTopicsSelector(
                                allTopics: topicSnap.data!,
                                selectedTopics: _interesesSeleccionados,
                                onSelectionChanged: _actualizarIntereses,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 40),

                    ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text("Guardar cambios"),
                      onPressed: _editando
                          ? () => _guardarCambios(nombreUserInicial, interesesIniciales)
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}