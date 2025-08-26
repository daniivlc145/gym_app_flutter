import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class ForumService {
  final SupabaseClient supabase = SupabaseService().client;
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<Map<String, dynamic>> getCurrentUserDataForum() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No hay usuario autenticado');
      }

      final response = await supabase
          .from('usuario')
          .select('nombre_usuario_foro, intereses_foro')
          .eq('pk_usuario', user.id)
          .single();

      return response;
    } catch (e) {
      print('Error al obtener datos de usuario: $e');
      throw Exception('No se pudieron recuperar los datos del usuario');
    }
  }

  Future<void> updateUserForumName(String nombreUsuarioForo) async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception('Error al obtener usuario');
      }

      final updateData = {
        'nombre_usuario_foro': nombreUsuarioForo,
      };


      final response = await supabase
          .from('usuario')
          .update(updateData)
          .eq('pk_usuario', user.id)
          .select()
          .single();

      if (response == null || response.isEmpty) {
        throw Exception('Error al actualizar los datos del usuario');
      }
    } on PostgrestException catch (postgrestError) {
      print('Postgres Error: ${postgrestError.message}');
      throw Exception('Error al actualizar en la base de datos: ${postgrestError.message}');
    } catch (e) {
      print('Unexpected Update Error: $e');
      throw Exception('Error durante la actualización: $e');
    }
  }


  Future<int> getNumeroPosts() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('No hay usuario autenticado');

      final count = await Supabase.instance.client
          .from('post')
          .count()
          .eq('fk_usuario', user.id);

      return count;
    } catch (e) {
      print('Error al obtener el número de posts del usuario: $e');
      throw Exception('No se pudieron recuperar los datos');
    }
  }

  Future<int> getNumeroComentarios() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('No hay usuario autenticado');

      final count = await Supabase.instance.client
          .from('comentario_foro')
          .count()
          .eq('fk_usuario', user.id);

      return count;
    } catch (e) {
      print('Error al obtener el número de comentarios del usuario: $e');
      throw Exception('No se pudieron recuperar los datos');
    }
  }

  Future<List<String>> getAllTopics() async {
    final response = await supabase // o tu cliente
        .from('topic')
        .select('titulo');
    return List<String>.from(response.map((e) => e['titulo']));
  }

  Future<void> updateUserInteresesForo(List<String> intereses) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('No autenticado');
    await supabase
        .from('usuario')
        .update({'intereses_foro': intereses})
        .eq('pk_usuario', user.id);
  }



}