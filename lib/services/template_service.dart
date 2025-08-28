import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class TemplateService {
  final SupabaseClient supabase = SupabaseService().client;

  Future<int> getNumeroPlantillasDeUsuario(String id) async {
    try {
      final rutinaList = await supabase
          .from('rutina')
          .select()
          .eq('fk_usuario', id);


      final count = rutinaList.length;

      if (count == 0) {
        print("No se han encontrado rutinas para el usuario");
      } else {
        print("Se han encontrado $count rutinas");
      }
      return count;
    } catch (e) {
      print('EXCEPTION: $e');
      throw Exception(e);
    }
  }

  Future<int> getNumeroPlantillasDeUsuarioActivo() async{
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No hay usuario autenticado');
      }
      return await getNumeroPlantillasDeUsuario(user.id);
    }catch(e) {
      throw Exception(e);
    }
  }

  Future<List<Map<String, dynamic>>> getRutinasDeUsuario(String id) async {
    try {
      final response = await supabase
          .from('rutina')
          .select('*')
          .eq('fk_usuario', id);

      List<Map<String, dynamic>> rutinas = [];

      for (var item in response) {
        if (item['ejercicios'] is String) {
          try {
            item['ejercicios'] = jsonDecode(item['ejercicios']);
          } catch (e) {
            print('Error al parsear ejercicios: $e');
            item['ejercicios'] = {};
          }
        }

        rutinas.add(Map<String, dynamic>.from(item));
      }

      return rutinas;
    } catch (e) {
      print('Error al obtener rutinas: $e');
      throw Exception('No se pudieron cargar las rutinas: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getRutinasDeUsuarioActivo() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No hay usuario autenticado');
      }
      return await getRutinasDeUsuario(user.id);
    } catch (e) {
      print('Error al obtener rutinas del usuario activo: $e');
      throw Exception('No se pudieron cargar las rutinas: $e');
    }
  }

  Future<Map<String, dynamic>> getRutinaPorId(String id) async {
    final response = await supabase
        .from('rutina')
        .select('*')
        .eq('pk_rutina', id)
        .single();

    if (response['ejercicios'] is String) {
      try {
        response['ejercicios'] = jsonDecode(response['ejercicios']);
      } catch (_) {
        response['ejercicios'] = [];
      }
    }

    return Map<String, dynamic>.from(response);
  }

  Future<Map<String, dynamic>> crearRutina(String nombre, List<Map<String, dynamic>> ejercicios) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No hay usuario autenticado');
      }

      final response = await supabase
          .from('rutina')
          .insert({
        'nombre': nombre,
        'fk_usuario': user.id,
        'ejercicios': ejercicios
      })
          .select()
          .single();

      if (response['ejercicios'] is String) {
        try {
          response['ejercicios'] = jsonDecode(response['ejercicios']);
        } catch (e) {
          print('Error al parsear ejercicios: $e');
          response['ejercicios'] = [];
        }
      }

      return Map<String, dynamic>.from(response);
    } catch (e) {
      print('Error al crear rutina: $e');
      throw Exception('No se pudo crear la rutina: $e');
    }
  }

  Future<Map<String, dynamic>> actualizarRutina(String rutinaId, String nombre, List<Map<String, dynamic>> ejercicios) async {
    try {
      final response = await supabase
          .from('rutina')
          .update({
        'nombre': nombre,
        'ejercicios': ejercicios
      })
          .eq('pk_rutina', rutinaId)
          .select()
          .single();

      if (response['ejercicios'] is String) {
        try {
          response['ejercicios'] = jsonDecode(response['ejercicios']);
        } catch (e) {
          print('Error al parsear ejercicios: $e');
          response['ejercicios'] = [];
        }
      }

      return Map<String, dynamic>.from(response);
    } catch (e) {
      print('Error al actualizar rutina: $e');
      throw Exception('No se pudo actualizar la rutina: $e');
    }
  }

  Future<void> eliminarRutina(String id) async {
    try {
      await supabase
          .from('rutina')
          .delete()
          .eq('pk_rutina', id);
    } catch (e) {
      print('Error al eliminar rutina: $e');
      throw Exception('No se pudo eliminar la rutina: $e');
    }
  }

}