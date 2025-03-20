import 'supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient supabase = SupabaseService().client;

  Future<void> signUp(String nombreUsuario, String email, String nombre,
      String apellidos, String password, String telefono) async {
    final AuthResponse res =
        await supabase.auth.signUp(email: email, password: password, data: {
      'nombre': nombre,
      'apellidos': apellidos,
      'nombre_usuario': nombreUsuario,
      'telefono': telefono,
    });
    final Session? session = res.session;
    final User? user = res.user;
    if (session == null || user == null) {
      throw Exception('Error al registrar el usuario');
    }
  }

  Future<bool> emailExistsInDatabase(String email) async {
    try {
      final response = await supabase
          .from('usuario')
          .select('correo')
          .eq('correo', email)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('Error al comprobar email en base de datos: $e');
      throw Exception('Esta dirección de correo ya existe en la base de datos');
    }
  }

  Future<bool> usernameExistsInDatabase(String nombreUsuario) async {
    try {
      final response = await supabase
          .from('usuario')
          .select('nombre_usuario')
          .eq('nombre_usuario', nombreUsuario)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('Error al comprobar nombre de usuario en base de datos: $e');
      throw Exception('Este nombre de usuario ya existe en la base de datos');
    }
  }
}
