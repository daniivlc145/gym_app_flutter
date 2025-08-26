import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gym_app/services/supabase_service.dart';
import 'package:gym_app/models/Entrenamiento.dart';

class TrainingService {
  final SupabaseClient supabase = SupabaseService().client;

  Future<List<Entrenamiento>> getEntrenamientosUsuario(String pkUsuario) async {
    try {
      final response = await supabase
          .from('entrenamiento')
          .select()
          .eq('fk_usuario', pkUsuario)
          .order('fecha', ascending: false);

      return (response as List)
          .map((row) => Entrenamiento.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Error en getEntrenamientosUsuario: $e');
      rethrow;
    }
  }

  Future<List<Entrenamiento>> getEntrenamientosUsuarioActivo() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No hay usuario autenticado');
      }
      return await getEntrenamientosUsuario(user.id);
    } catch (e) {
      print('❌ Error en getEntrenamientosUsuarioActivo: $e');
      rethrow;
    }
  }
}