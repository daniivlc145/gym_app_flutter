import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import 'dart:io';

class GimnasioService {
  final SupabaseClient supabase = SupabaseService().client;

  Future<Map<String, dynamic>> getInfoGimnasio(String pkGimnasio) async {
    try {
      final gimnasioDataResponse = await supabase
          .from('gimnasio')
          .select('''
          nombre, 
          ciudad, 
          codigo_postal, 
          cadena_gimnasio(pk_cadena_gimnasio, nombre, logo)
        ''')
          .eq('pk_gimnasio', pkGimnasio)
          .single();
      return gimnasioDataResponse;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<List<Map<String, dynamic>>> getGimnasiosDeUsuarioActivo() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No hay usuario autenticado');
      }

      // Obtener los gimnasios del usuario a través de getGimnasiosDeUsuario
      final gimnasios = await getGimnasiosDeUsuario(user.id);

      return gimnasios;
    } catch (e) {
      print('Error en getGimnasiosDeUsuarioActivo: $e');
      throw e.toString();
    }
  }




  Future<List<Map<String, dynamic>>> getGimnasiosDeUsuario(String idUsuario) async{
    try {
      final gimnasioDeUsuarioResponse = await supabase
          .from('usuario_gimnasio')
          .select('fk_gimnasio')
          .eq('fk_usuario', idUsuario);

      if (gimnasioDeUsuarioResponse.isEmpty || gimnasioDeUsuarioResponse == null) {
        return [];
      }

      final List<String> gimnasioIds = gimnasioDeUsuarioResponse
          .map<String>((item) => item['fk_gimnasio'].toString())
          .toList();

      final List<Map<String, dynamic>> gimnasiosInfo = await Future.wait(
          gimnasioIds.map((gimnasioId) => getInfoGimnasio(gimnasioId))
      );

      for (int i = 0; i < gimnasiosInfo.length; i++) {
        gimnasiosInfo[i]['pk_gimnasio'] = gimnasioIds[i];
      }

      return gimnasiosInfo;
    }catch(e){
      throw e.toString();
    }
  }

  Future<void> addGymAUsuario(String gymId) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No hay usuario autenticado');
      }

      await supabase
          .from('usuario_gimnasio')
          .insert({
        'fk_usuario': user.id,
        'fk_gimnasio': gymId
      });

    } catch (e) {
      print('Error detallado: $e');
      throw Exception('Error al agregar el gimnasio: $e');
    }
  }

  Future<void> eliminarGymAUsuario(String gymId) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No hay usuario autenticado');
      }

      final response = await supabase
          .from('usuario_gimnasio')
          .delete()
          .eq('fk_usuario', user.id)
          .eq('fk_gimnasio', gymId);

      if (response.error != null) {
        throw Exception('Error al eliminar el gimnasio: ${response.error!.message}');
      }
    }catch(e){
      throw Exception('Error al eliminar el gimnasio: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getListaDeCadenasGym() async {
    try {
      final response = await supabase
          .from('cadena_gimnasio')
          .select('pk_cadena_gimnasio, nombre, logo');

      return response;

    }catch(e){
      throw e.toString();
    }
  }

  Future<List<Map<String, dynamic>>> getListaDeGymsPorCadena(String idCadena) async {
    try {
      final gimnasiosResponse = await supabase
          .from('gimnasio')
          .select('pk_gimnasio')
          .eq('fk_cadena_gimnasio', idCadena);

      if (gimnasiosResponse.isEmpty || gimnasiosResponse == null) {
        return [];
      }

      final List<String> gimnasioIds = gimnasiosResponse
          .map<String>((item) => item['pk_gimnasio'].toString())
          .toList();

      final List<Map<String, dynamic>> gimnasiosInfo = await Future.wait(
          gimnasioIds.map((gimnasioId) => getInfoGimnasio(gimnasioId))
      );

      return gimnasiosInfo;
    } catch(e){
      throw e.toString();
    }
  }

  Future<List<Map<String, dynamic>>> getListaDeGimnasios() async {
    try {
      final gimnasiosResponse = await supabase
          .from('gimnasio')
          .select('pk_gimnasio');

      if (gimnasiosResponse.isEmpty || gimnasiosResponse == null) {
        return [];
      }

      final List<String> gimnasioIds = gimnasiosResponse
          .map<String>((item) => item['pk_gimnasio'].toString())
          .toList();

      final List<Map<String, dynamic>> gimnasiosInfo = await Future.wait(
          gimnasioIds.map((gimnasioId) => getInfoGimnasio(gimnasioId))
      );

      return gimnasiosInfo;

    }catch(e){
      throw e.toString();
    }
  }

  Future<List<Map<String, dynamic>>> buscarGimnasios({
    String? nombre,
    String? codigoPostal,
    List<String>? cadenas,
  }) async {
    try {
      var query = supabase.from('gimnasio').select('''
      pk_gimnasio,
      nombre,
      ciudad,
      codigo_postal,
      cadena_gimnasio(pk_cadena_gimnasio, nombre, logo)
    ''');

      if (nombre != null && nombre.isNotEmpty) {
        query = query.ilike('nombre', '%$nombre%');
      }

      if (codigoPostal != null && codigoPostal.isNotEmpty) {
        query = query.eq('codigo_postal', codigoPostal);
      }

      if (cadenas != null && cadenas.isNotEmpty) {
        query = query.inFilter('fk_cadena_gimnasio', cadenas);
      }

      final response = await query;


      return response;
    } catch (e) {
      throw Exception('Error al buscar gimnasios: $e');
    }
  }


}