import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart'; // ✅ para compartir
import 'package:gym_app/screens/create_post_screen.dart';
import '../models/post.dart';
import '../services/forum_service.dart';
import '../widgets/forum_filter_header.dart';

class ForumsScreen extends StatefulWidget {
  @override
  _ForumsScreenState createState() => _ForumsScreenState();
}

class _ForumsScreenState extends State<ForumsScreen> {
  final ForumService _forumService = ForumService();
  bool isLoading = true;
  String filtro = 'POPULAR';
  List<Post> posts = [];

  Future<void> _cargarDatos() async {
    setState(() => isLoading = true);
    try {
      if (filtro == 'POPULAR') {
        posts = await _forumService.getPopularPosts();
      } else {
        posts = await _forumService.getRecentPosts();
      }
    } catch (e) {
      debugPrint('❌ Error al cargar datos: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar posts'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Foros'),
      ),
      body: isLoading
          ? Center(
        child: Platform.isAndroid
            ? const CircularProgressIndicator()
            : const CupertinoActivityIndicator(),
      )
          : Column(
        children: [
          ForumFilterHeader(
            selected: filtro,
            onChanged: (value) {
              setState(() {
                filtro = value;
              });
              _cargarDatos();
            },
          ),
          Expanded(
            child: posts.isEmpty
                ? const Center(child: Text("No hay posts disponibles"))
                : ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.titulo,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          post.descripcion,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // 🔹 Miniatura de imagen si existe
                        if (post.fotos.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  post.fotos.first, // primera imagen
                                  height: 120,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              if (post.fotos.length > 1)
                                Container(
                                  margin: const EdgeInsets.all(6),
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '+${post.fotos.length - 1}',
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ),
                            ],
                          ),
                        ],

                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text("${post.votos}"),
                                IconButton(
                                  onPressed: () async {
                                    try {
                                      await _forumService.votePost(post.id, true);
                                      setState(() => post.votos += 1); // ✅ actualizamos rápido
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Error al votar")),
                                      );
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.thumb_up_alt_outlined,
                                    color: Colors.green,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    try {
                                      await _forumService.votePost(post.id, false);
                                      setState(() => post.votos -= 1); // ✅ actualizamos rápido
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Error al votar")),
                                      );
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.thumb_down_alt_outlined,
                                    color: Colors.red,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    // TODO: Navegar a detalle del post con comentarios
                                  },
                                  icon: const Icon(Icons.comment, color: Colors.teal),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () {
                                final shareText = "${post.titulo}\n\n${post.descripcion}";
                                Share.share(shareText);
                              },
                              icon: const Icon(Icons.share, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),

                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CreatePostScreen()),
          );
          if (created == true) {
            _cargarDatos(); // ✅ Refrescar al volver
          }
        },
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        child: const Icon(Icons.add),
        tooltip: 'Crear post',
      ),
    );
  }
}