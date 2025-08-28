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

  late TextEditingController _nombreUsuarioForoController;
  String _nombreUsuarioForo = "";

  /// manejamos los intereses con ValueNotifier para evitar rebuilds completos
  late ValueNotifier<List<String>> _interesesNotifier;
  /// manejamos el botón de "guardar" con ValueNotifier<bool>
  late ValueNotifier<bool> _editandoNotifier;

  @override
  void initState() {
    super.initState();
    _nombreUsuarioForoController = TextEditingController();
    _interesesNotifier = ValueNotifier<List<String>>([]);
    _editandoNotifier = ValueNotifier<bool>(false);
    _cargarDatos();
  }

  void _cargarDatos() {
    _userData = _forumService.getCurrentUserDataForum();
    _numeroPosts = _forumService.getNumeroPosts();
    _numeroComentarios = _forumService.getNumeroComentarios();
    _allTopics = _forumService.getAllTopics();
  }

  Future<void> _guardarCambios(
      String nombreInicial, List<String> interesesInicialesTitulos) async {
    try {
      if (_nombreUsuarioForo.trim().isNotEmpty &&
          _nombreUsuarioForo != nombreInicial) {
        await _forumService.updateUserForumName(_nombreUsuarioForo.trim());
      }

      final actuales = _interesesNotifier.value;
      if (!listEquals(actuales, interesesInicialesTitulos)) {
        final uuids = await _forumService.getTopicIdsFromTitles(actuales);
        await _forumService.updateUserInteresesForo(uuids);
      }

      _editandoNotifier.value = false; // ya se guardó
      _cargarDatos();

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
    _nombreUsuarioForoController.dispose();
    _scrollController.dispose();
    _interesesNotifier.dispose();
    _editandoNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes de Foros')),

      // 🔹 Floating button para guardar
      floatingActionButton: ValueListenableBuilder<bool>(
        valueListenable: _editandoNotifier,
        builder: (context, editando, _) {
          return FloatingActionButton.extended(
            onPressed: editando
                ? () async {
              final userData = await _userData;
              final nombreUserInicial =
                  userData['nombre_usuario_foro'] ?? '';
              final interesesInicialesUUIDs =
                  (userData['intereses_foro'] as List?)?.cast<String>() ?? [];
              final interesesInicialesTitulos =
              await _forumService.getTopicTitlesFromIds(interesesInicialesUUIDs);

              await _guardarCambios(nombreUserInicial, interesesInicialesTitulos);
            }
                : null,
            label: const Text("Guardar cambios"),
            icon: const Icon(Icons.save),
            backgroundColor: editando
                ? Theme.of(context).colorScheme.primary
                : Colors.grey,
          );
        },
      ),

      body: FutureBuilder<Map<String, dynamic>>(
        future: _userData,
        builder: (context, userSnap) {
          if (userSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (userSnap.hasError || userSnap.data == null) {
            return const Center(
              child: Text('Error cargando usuario',
                  style: TextStyle(color: Colors.red)),
            );
          }

          final nombreUserInicial = userSnap.data!['nombre_usuario_foro'] ?? '';
          final interesesInicialesUUIDs =
              (userSnap.data!['intereses_foro'] as List?)?.cast<String>() ?? [];

          // Inicializar controller UNA SOLA VEZ
          if (_nombreUsuarioForo.isEmpty) {
            _nombreUsuarioForo = nombreUserInicial;
            _nombreUsuarioForoController.text = nombreUserInicial;
          }

          return FutureBuilder<List<String>>(
              future: _forumService.getTopicTitlesFromIds(interesesInicialesUUIDs),
              builder: (context, titulosSnap) {
                if (titulosSnap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (titulosSnap.hasError) {
                  return Center(
                      child: Text("Error cargando títulos de intereses",
                          style: TextStyle(color: Colors.red)));
                }

                final interesesInicialesTitulos = titulosSnap.data ?? [];

                if (_interesesNotifier.value.isEmpty) {
                  _interesesNotifier.value =
                  List<String>.from(interesesInicialesTitulos);
                }

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 36),

                        // Nombre
                        TextField(
                          controller: _nombreUsuarioForoController,
                          onChanged: (nuevo) {
                            _nombreUsuarioForo = nuevo;
                            _editandoNotifier.value = true;
                          },
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
                                String value =
                                snap.connectionState ==
                                    ConnectionState.waiting
                                    ? "..."
                                    : (snap.hasError || snap.data == null
                                    ? "Error"
                                    : "${snap.data}");
                                return ForumMetricCard(
                                    value: value, label: "Posts");
                              },
                            ),
                            const SizedBox(width: 18),
                            FutureBuilder<int>(
                              future: _numeroComentarios,
                              builder: (context, snap) {
                                String value =
                                snap.connectionState ==
                                    ConnectionState.waiting
                                    ? "..."
                                    : (snap.hasError || snap.data == null
                                    ? "Error"
                                    : "${snap.data}");
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
                            if (topicSnap.connectionState ==
                                ConnectionState.waiting ||
                                _allTopics == null) {
                              return const SizedBox(
                                height: 130,
                                child: Center(
                                    child: LinearProgressIndicator()),
                              );
                            }
                            if (topicSnap.hasError) {
                              return SizedBox(
                                height: 130,
                                child: Center(
                                  child: Text(
                                      "Error cargando intereses: ${topicSnap.error}",
                                      style: TextStyle(color: Colors.red)),
                                ),
                              );
                            }
                            if (!topicSnap.hasData ||
                                topicSnap.data == null) {
                              return const SizedBox(
                                height: 130,
                                child: Center(
                                    child: Text("No hay intereses disponibles")),
                              );
                            }

                            return Container(
                              constraints: const BoxConstraints(
                                maxHeight: 200,
                              ),
                              padding: const EdgeInsets.all(4.0),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.background,
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
                                  child: ValueListenableBuilder<List<String>>(
                                    valueListenable: _interesesNotifier,
                                    builder: (context, seleccionados, _) {
                                      return ForumTopicsSelector(
                                        allTopics: topicSnap.data!,
                                        selectedTopics: seleccionados,
                                        onSelectionChanged: (newSel) {
                                          _interesesNotifier.value = newSel;
                                          _editandoNotifier.value = true;
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              });
        },
      ),
    );
  }
}