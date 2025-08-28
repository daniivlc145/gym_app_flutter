import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/post.dart';
import 'supabase_service.dart';

class ForumService {
  final SupabaseClient supabase = SupabaseService().client;

  // 🔹 Obtener datos del usuario (nombre + intereses)
  Future<Map<String, dynamic>> getCurrentUserDataForum() async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('No hay usuario autenticado');

    final response = await supabase
        .from('usuario')
        .select('nombre_usuario_foro, intereses_foro')
        .eq('pk_usuario', user.id)
        .single();

    return response;
  }

  // 🔹 Actualizar nombre de usuario en el foro
  Future<void> updateUserForumName(String nombreUsuarioForo) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Error al obtener usuario');

    final response = await supabase
        .from('usuario')
        .update({'nombre_usuario_foro': nombreUsuarioForo})
        .eq('pk_usuario', user.id)
        .select()
        .single();

    if (response == null || response.isEmpty) {
      throw Exception('Error al actualizar los datos del usuario');
    }
  }

  // 🔹 Contar posts de un usuario
  Future<int> getNumeroPosts() async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('No hay usuario autenticado');

    final count = await supabase
        .from('post')
        .count()
        .eq('fk_usuario', user.id);

    return count;
  }

  // 🔹 Contar comentarios de un usuario
  Future<int> getNumeroComentarios() async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('No hay usuario autenticado');

    final count = await supabase
        .from('comentario_foro')
        .count()
        .eq('fk_usuario', user.id);

    return count;
  }

  // 🔹 Obtener todos los topics (solo títulos)
  Future<List<String>> getAllTopics() async {
    final response = await supabase.from('topic').select('titulo');
    return List<String>.from(response.map((e) => e['titulo']));
  }

  // 🔹 Obtener todos los topics (ids y títulos)
  Future<List<Map<String, dynamic>>> getAllTopicsFull() async {
    final response = await supabase.from('topic').select('pk_topic, titulo');
    return List<Map<String, dynamic>>.from(response);
  }

  // 🔹 Actualizar intereses del usuario
  Future<void> updateUserInteresesForo(List<String> uuids) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('No autenticado');

    final response = await supabase
        .from('usuario')
        .update({'intereses_foro': uuids})
        .eq('pk_usuario', user.id)
        .select()
        .maybeSingle();

    if (response == null) {
      throw Exception("No se pudo actualizar los intereses");
    }
  }

  // 🔹 Crear un post (incluyendo subida de fotos)
  Future<void> createPost({
    required String titulo,
    required String descripcion,
    required String fkTopic,
    List<String>? etiquetas,
    List<File>? fotosLocales,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception("Usuario no autenticado");

    try {
      // ---- SUBIR FOTOS AL BUCKET ----
      final List<String> fotosUrls = [];
      if (fotosLocales != null && fotosLocales.isNotEmpty) {
        for (var file in fotosLocales) {
          final fileExt = file.path.split('.').last;
          final fileName = "${DateTime.now().millisecondsSinceEpoch}.$fileExt";
          final filePath = "posts/${user.id}/$fileName";

          await supabase.storage
              .from('fotos_post')
              .upload(filePath, file,
              fileOptions: const FileOptions(cacheControl: '3600', upsert: true));

          final publicUrl = supabase.storage.from('fotos_post').getPublicUrl(filePath);
          fotosUrls.add(publicUrl);
        }
      }

      // ---- INSERTAR POST ----
      await supabase.from('post').insert({
        'titulo': titulo,
        'descripcion': descripcion,
        'fk_topic': fkTopic,
        'fk_usuario': user.id,
        'etiquetas': etiquetas ?? [],
        'fotos': fotosUrls,
      });
    } catch (e) {
      throw Exception("Error creando post: $e");
    }
  }

  // 🔹 Obtener posts recientes filtrados por intereses
  Future<List<Post>> getRecentPosts({int limit = 30}) async {
    final userData = await getCurrentUserDataForum();
    final intereses = List<String>.from(userData['intereses_foro'] ?? []);

    var query = supabase.from('post').select(
        'pk_post, titulo, descripcion, created_at, fk_topic, fk_usuario, fotos, etiquetas');

    if (intereses.isNotEmpty) {
      query = query.inFilter('fk_topic', intereses);
    }

    final List data = await query.order('created_at', ascending: false).limit(limit);

    return data.map((e) => Post.fromMap(e)).toList();
  }

  // 🔹 Obtener posts populares (ordenados por votos + filtrados por intereses)
  Future<List<Post>> getPopularPosts({int limit = 30}) async {
    final userData = await getCurrentUserDataForum();
    final intereses = List<String>.from(userData['intereses_foro'] ?? []);

    PostgrestFilterBuilder query = supabase.from('post').select(
        'pk_post, titulo, descripcion, created_at, fk_topic, fk_usuario, fotos, etiquetas, post_voto(tipo_voto)');

    if (intereses.isNotEmpty) {
      query = query.inFilter('fk_topic', intereses);
    }

    final List data = await query.limit(limit);

    // calcular votos y mapear a Post
    final posts = data.map<Post>((map) {
      final votos = (map['post_voto'] as List?)
          ?.fold<int>(0, (sum, v) => sum + ((v['tipo_voto'] == 1) ? 1 : -1)) ?? 0;
      return Post.fromMap(map, votos: votos);
    }).toList();

    // ordenar por votos y fecha
    posts.sort((a, b) {
      final cmp = b.votos.compareTo(a.votos);
      return cmp != 0 ? cmp : b.createdAt.compareTo(a.createdAt);
    });

    return posts.take(limit).toList();
  }

  // 🔹 Buscar posts
  // 🔹 Buscar posts en orden de prioridad: titulo > descripcion > etiquetas
  Future<List<Post>> searchPosts(String query) async {
    // 1️⃣ Buscar primero en el título
    final resultTitulo = await supabase
        .from('post')
        .select(
        'pk_post, titulo, descripcion, etiquetas, fk_topic, created_at, fk_usuario, fotos')
        .ilike('titulo', '%$query%');

    if (resultTitulo.isNotEmpty) {
      return List<Map<String, dynamic>>.from(resultTitulo)
          .map((e) => Post.fromMap(e))
          .toList();
    }

    // 2️⃣ Luego en la descripción
    final resultDescripcion = await supabase
        .from('post')
        .select(
        'pk_post, titulo, descripcion, etiquetas, fk_topic, created_at, fk_usuario, fotos')
        .ilike('descripcion', '%$query%');

    if (resultDescripcion.isNotEmpty) {
      return List<Map<String, dynamic>>.from(resultDescripcion)
          .map((e) => Post.fromMap(e))
          .toList();
    }

    // 3️⃣ Finalmente en etiquetas (que es array<string>)
    final resultEtiquetas = await supabase
        .from('post')
        .select(
        'pk_post, titulo, descripcion, etiquetas, fk_topic, created_at, fk_usuario, fotos')
        .contains('etiquetas', [query]); // ✅ busca coincidencia en array de etiquetas

    if (resultEtiquetas.isNotEmpty) {
      return List<Map<String, dynamic>>.from(resultEtiquetas)
          .map((e) => Post.fromMap(e))
          .toList();
    }

    // 4️⃣ Si no hay coincidencias, devolver lista vacía
    return [];
  }

  // 🔹 Obtener posts por topic
  Future<List<Post>> getPostsByTopic(String topicId, {int limit = 30}) async {
    final response = await supabase
        .from('post')
        .select('*')
        .eq('fk_topic', topicId)
        .order('created_at', ascending: false)
        .limit(limit);

    return List<Map<String, dynamic>>.from(response).map((e) => Post.fromMap(e)).toList();
  }

  // 🔹 Traducir UUIDs a títulos
  Future<List<String>> getTopicTitlesFromIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final rows = await supabase.from('topic').select('titulo').inFilter('pk_topic', ids);
    return List<String>.from(rows.map((e) => e['titulo']));
  }

  // 🔹 Traducir títulos a UUIDs
  Future<List<String>> getTopicIdsFromTitles(List<String> titles) async {
    if (titles.isEmpty) return [];
    final rows = await supabase.from('topic').select('pk_topic').inFilter('titulo', titles);
    return List<String>.from(rows.map((e) => e['pk_topic']));
  }

  // Votar un post
  Future<void> votePost(String postId, bool isUpvote) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception("Usuario no autenticado");

    await supabase.from('post_voto').upsert({
      'fk_post': postId,
      'fk_usuario': user.id,
      'tipo_voto': isUpvote ? 1 : -1
    });
  }
}