import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gym_app/services/supabase_service.dart';
import 'package:gym_app/models/Gimnasio.dart';

class GimnasioService {
  final SupabaseClient supabase = SupabaseService().client;

  Future<Gimnasio> getInfoGimnasio(String pkGimnasio) async {
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

      final Map<String, dynamic> gimnasioMap = {
        'pk_gimnasio': pkGimnasio,
        'nombre': gimnasioDataResponse['nombre'],
        'ciudad': gimnasioDataResponse['ciudad'],
        'codigo_postal': gimnasioDataResponse['codigo_postal'],
        'cadena_gimnasio': gimnasioDataResponse['fk_cadena_gimnasio'],
        'logo': gimnasioDataResponse['cadena_gimnasio']?['logo'],
      };
      return Gimnasio.fromMap(gimnasioMap);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<List<Gimnasio>> getGimnasiosDeUsuarioActivo() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No hay usuario autenticado');
      }

      return await getGimnasiosDeUsuario(user.id);
    } catch (e) {
      print('Error en getGimnasiosDeUsuarioActivo: $e');
      throw e.toString();
    }
  }

  Future<List<Gimnasio>> getGimnasiosDeUsuario(String idUsuario) async{
    try {
      final gimnasioDeUsuarioResponse = await supabase
          .from('usuario_gimnasio')
          .select('fk_gimnasio')
          .eq('fk_usuario', idUsuario);

      if (gimnasioDeUsuarioResponse.isEmpty) {
        return [];
      }

      final List<String> gimnasioIds = gimnasioDeUsuarioResponse
          .map<String>((item) => item['fk_gimnasio'].toString())
          .toList();

      final List<Gimnasio> gimnasios = await Future.wait(
          gimnasioIds.map((gimnasioId) => getInfoGimnasio(gimnasioId))
      );

      return gimnasios;
    } catch(e) {
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

    }catch(e){
      throw Exception('Error al eliminar el gimnasio: $e');
    }
  }


  Future<List<Gimnasio>> getListaDeGymsPorCadena(String idCadena) async {
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

      final List<Gimnasio> gimnasios = await Future.wait(
          gimnasioIds.map((gimnasioId) => getInfoGimnasio(gimnasioId))
      );

      return gimnasios;
    } catch(e){
      throw e.toString();
    }
  }

  Future<List<Gimnasio>> getListaDeGimnasios() async {
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

      final List<Gimnasio> gimnasios = await Future.wait(
          gimnasioIds.map((gimnasioId) => getInfoGimnasio(gimnasioId))
      );

      return gimnasios;

    }catch(e){
      throw e.toString();
    }
  }

  Future<List<Gimnasio>> buscarGimnasios({
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

      List<Gimnasio> gimnasios = [];
      for (var item in response) {
        final Map<String, dynamic> gimnasioMap = {
          'pk_gimnasio': item['pk_gimnasio'],
          'nombre': item['nombre'],
          'ciudad': item['ciudad'],
          'codigo_postal': item['codigo_postal'],
          'cadena_gimnasio': item['fk_cadena_gimnasio'],
          'logo': item['cadena_gimnasio']?['logo'],
        };
        gimnasios.add(Gimnasio.fromMap(gimnasioMap));
      }


      return gimnasios;
    } catch (e) {
      throw Exception('Error al buscar gimnasios: $e');
    }
  }


}