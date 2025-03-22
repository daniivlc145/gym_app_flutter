import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

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
}
