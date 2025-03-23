import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import 'dart:io';

class UserService {
  final SupabaseClient supabase = SupabaseService().client;

  Future<Map<String, dynamic>> getCurrentUserData() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No hay usuario autenticado');
      }

      final response = await supabase
          .from('usuario')
          .select('nombre, apellidos, telefono, correo, medidas, nombre_usuario, nombre_usuario_foro, foto_usuario')
          .eq('pk_usuario', user.id)
          .single();

      return response;
    } catch (e) {
      print('Error al obtener datos de usuario: $e');
      throw Exception('No se pudieron recuperar los datos del usuario');
    }
  }

  Future<void> updateUserDataFromSettings(String nombre, String apellidos, String telefono, File? imagen) async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception('Error al obtener usuario');
      }

      String? rutaImagenSubida;
      if (imagen != null) {
        rutaImagenSubida = await subirImagenUsuario(imagen);
      }

      final updateData = {
        'nombre': nombre,
        'apellidos': apellidos,
        'telefono': telefono,
      };

      if (rutaImagenSubida != null) {
        updateData['foto_usuario'] = rutaImagenSubida;
      }

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

  Future<String> subirImagenUsuario(File imagen) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'private/$fileName';

      await Supabase.instance.client.storage
          .from('fotousuario')
          .upload(path, imagen, fileOptions: FileOptions(upsert: true));

      final signedUrl = await supabase.storage
          .from('fotousuario')
          .createSignedUrl(path, 31536000);

      print("URL firmada generada: $signedUrl");
      return signedUrl;
    } catch (e) {
      print('Error al subir la imagen: $e');
      throw Exception('Error al subir la imagen');
    }
  }

}
