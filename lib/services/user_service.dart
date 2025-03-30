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
          .select('nombre, apellidos, telefono, correo, medidas, nombre_usuario, nombre_usuario_foro, foto_usuario, descripcion')
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

  Future<Map<String, dynamic>> getUserDataById (String id) async {
    try {

      final response = await supabase
          .from('usuario')
          .select('nombre, apellidos, telefono, correo, medidas, nombre_usuario, nombre_usuario_foro, foto_usuario, descripcion')
          .eq('pk_usuario', id)
          .single();

      return response;
    } catch (e) {
      print('Error al obtener datos de usuario: $e');
      throw Exception('No se pudieron recuperar los datos del usuario');
    }
  }

  Future<List<Map<String, dynamic>>> getAmigos() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No hay usuario autenticado');
      }

      final userId = user.id;

      final friendshipsResponse = await supabase
          .from('solicitud_amistad')
          .select('fk_usuario_origen, fk_usuario_destino')
          .or('fk_usuario_origen.eq.$userId, fk_usuario_destino.eq.$userId')
          .eq('estado', 'aceptado');

      List<String> friendIds = [];

      for (var friendship in friendshipsResponse) {
        final origin = friendship['fk_usuario_origen'];
        final destination = friendship['fk_usuario_destino'];

        if (origin != userId) {
          friendIds.add(origin);
        }
        if (destination != userId) {
          friendIds.add(destination);
        }
      }

      friendIds = friendIds.toSet().toList();

      final friendsDetailsResponse = await supabase
          .from('usuario')
          .select('pk_usuario, nombre_usuario, nombre, apellidos, foto_usuario')
          .filter('pk_usuario', 'in', friendIds);

      return friendsDetailsResponse;
    } catch (e) {
      print('Error al obtener amigos: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getSolicitudesEnviadas() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No hay usuario autenticado');
      }

      final userId = user.id;

      final enviadasResponse = await supabase
          .from('solicitud_amistad')
          .select('fk_usuario_destino')
          .eq('fk_usuario_origen', userId)
          .eq('estado', 'pendiente');

      List<String> usuariosEnviadosIds = enviadasResponse
          .map<String>((e) => e['fk_usuario_destino'] as String)
          .toList();

      if (usuariosEnviadosIds.isEmpty) return [];

      final enviadasDetailsResponse = await supabase
          .from('usuario')
          .select('pk_usuario, nombre_usuario, nombre, apellidos, foto_usuario')
          .inFilter('pk_usuario', usuariosEnviadosIds);

      return enviadasDetailsResponse;

    } catch (e) {
      print('Error al obtener solicitudes enviadas: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getSolicitudesRecibidas() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No hay usuario autenticado');
      }

      final userId = user.id;

      final recibidasResponse = await supabase
          .from('solicitud_amistad')
          .select('fk_usuario_origen')
          .eq('fk_usuario_destino', userId)
          .eq('estado', 'pendiente');

      List<String> usuariosRecibidosIds = recibidasResponse
          .map<String>((e) => e['fk_usuario_origen'] as String)
          .toList();

      if (usuariosRecibidosIds.isEmpty) return [];

      final recibidasDetailsResponse = await supabase
          .from('usuario')
          .select('pk_usuario, nombre_usuario, nombre, apellidos, foto_usuario')
          .inFilter('pk_usuario', usuariosRecibidosIds);

      return recibidasDetailsResponse;

    } catch (e) {
      print('Error al obtener solicitudes recibidas: $e');
      return [];
    }
  }

  Future<void> eliminarSolicitudEnviada(String otroUsuarioId) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No hay usuario autenticado');
      }

      final userId = user.id;

      await supabase
          .from('solicitud_amistad')
          .delete()
          .eq('fk_usuario_origen', userId)
          .eq('fk_usuario_destino', otroUsuarioId)
          .eq('estado', 'pendiente');

      print('Solicitud enviada eliminada con éxito.');

    } catch (e) {
      print('Error al eliminar la solicitud enviada: $e');
    }
  }

  Future<void> eliminarSolicitudRecibida(String otroUsuarioId) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No hay usuario autenticado');
      }

      final userId = user.id;

      await supabase
          .from('solicitud_amistad')
          .delete()
          .eq('fk_usuario_destino', userId)
          .eq('fk_usuario_origen', otroUsuarioId)
          .eq('estado', 'pendiente');

      print('Solicitud recibida eliminada con éxito.');

    } catch (e) {
      print('Error al eliminar la solicitud recibida: $e');
    }
  }

  Future<void> aceptarSolicitudAmistad(String otroUsuarioId) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No hay usuario autenticado');
      }

      final userId = user.id;

      await supabase
          .from('solicitud_amistad')
          .update({'estado': 'aceptado'})
          .eq('fk_usuario_origen', otroUsuarioId)
          .eq('fk_usuario_destino', userId)
          .eq('estado', 'pendiente');

      print('Solicitud de amistad aceptada con éxito.');

    } catch (e) {
      print('Error al aceptar la solicitud de amistad: $e');
      throw Exception('No se pudo aceptar la solicitud de amistad');
    }
  }

  Future<void> enviarSolicitudAmistad(String otroUsuarioId) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No hay usuario autenticado');
      }

      final userId = user.id;

      final existingRequest = await supabase
          .from('solicitud_amistad')
          .select()
          .or(
        'fk_usuario_origen.eq.$userId,fk_usuario_destino.eq.$otroUsuarioId'
            ',fk_usuario_origen.eq.$otroUsuarioId,fk_usuario_destino.eq.$userId',
      )
          .maybeSingle();

      if (existingRequest != null) {
        throw Exception('Ya existe una solicitud de amistad');
      }

      await supabase
          .from('solicitud_amistad')
          .insert({
        'fk_usuario_origen': userId,
        'fk_usuario_destino': otroUsuarioId,
        'estado': 'pendiente'
      });

      print('Solicitud de amistad enviada con éxito.');

    } catch (e) {
      throw Exception('No se pudo enviar la solicitud de amistad: $e');
    }
  }

  Future<List<Map<String, dynamic>>> buscarUsuarios(String query) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No hay usuario autenticado');
      }

      final userId = user.id;

      final response = await supabase
          .from('usuario')
          .select('pk_usuario, nombre_usuario, nombre, apellidos, foto_usuario')
          .eq('nombre_usuario', query)
          .neq('pk_usuario', userId)
          .limit(1);

      return response;
    } catch (e) {
      print('Error al buscar usuarios: $e');
      throw Exception('No se pudieron encontrar usuarios');
    }
  }

  Future<bool> existeSolicitudAmistad(String otroUsuarioId) async {
    try{
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('No autenticado');

      final userId = user.id;

      final existingRequest = await supabase
          .from('solicitud_amistad')
          .select()
          .or('fk_usuario_origen.eq.$userId,fk_usuario_destino.eq.$otroUsuarioId,fk_usuario_origen.eq.$otroUsuarioId,fk_usuario_destino.eq.$userId')
          .maybeSingle();

      return existingRequest != null;
    }catch(e){
      throw e.toString();
    }

  }




}
