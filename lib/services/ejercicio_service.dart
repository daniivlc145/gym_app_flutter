import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gym_app/models/Ejercicio.dart';
import 'supabase_service.dart';

class EjercicioService {
  final SupabaseClient supabase = SupabaseService().client;
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<List<String>> getDistinctGrupoMuscular() async {
    final response = await _supabaseClient.rpc('get_distinct_grupo_muscular');
    return List<String>.from((response as List).map((item) => item['grupo_muscular']));
  }

  Future<List<String>> getDistinctEquipamiento() async {
    final response = await _supabaseClient.rpc('get_distinct_equipamiento');
    return List<String>.from((response as List).map((item) => item['equipamiento']));
  }

  Future<List<Ejercicio>> buscarEjercicios({
    String? nombre,
    List<String>? grupoMuscular,
    List<String>? equipamiento,
  }) async {
    try {
      var query = _supabaseClient.from('ejercicio').select('''
        pk_ejercicio,
        nombre,
        grupo_muscular,
        equipamiento
      ''');

      if (nombre != null && nombre.isNotEmpty) {
        query = query.ilike('nombre', '%$nombre%');
      }

      if (grupoMuscular != null && grupoMuscular.isNotEmpty) {
        query = query.inFilter('grupo_muscular', grupoMuscular);
      }

      if (equipamiento != null && equipamiento.isNotEmpty) {
        query = query.inFilter('equipamiento', equipamiento);
      }

      final response = await query;

      List<Ejercicio> ejercicios = [];
      for (var item in response) {
        // Aquí directamente mapeamos los datos a un objeto Ejercicio
        Ejercicio ejercicio = Ejercicio(
          pk_ejercicio: item['pk_ejercicio'],
          nombre: item['nombre'],
          grupo_muscular: item['grupo_muscular'],
          equipamiento: item['equipamiento'],
        );
        ejercicios.add(ejercicio);
      }

      return ejercicios;
    } catch (e) {
      throw Exception('Error al buscar ejercicios: $e');
    }
  }

  Future<String> getNombreEjercicioPorId(String idEjercicio) async {
    try {
      final response = await supabase
          .from('ejercicio')
          .select()
          .eq('pk_ejercicio', idEjercicio);

      if (response.isEmpty) {
        throw Exception('No se encontró el ejercicio');
      }
      final nombreEjercicio = response.first['nombre'] as String?;
      if (nombreEjercicio == null) {
        throw Exception('El ejercicio no tiene nombre');
      }
      return nombreEjercicio;
    } catch (e) {
      print('EXCEPTION: $e');
      throw Exception(e);
    }
  }
}
