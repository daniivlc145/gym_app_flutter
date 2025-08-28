import 'supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient supabase = SupabaseService().client;

  Future<void> signUp(String nombreUsuario, String email, String nombre,
      String apellidos, String password, String telefono) async {
    try {
      bool emailExists = await emailExistsInDatabase(email);
      bool usernameExists = await usernameExistsInDatabase(nombreUsuario);

      if (emailExists) {
        throw Exception('Este correo electrónico ya está registrado');
      }

      if (usernameExists) {
        throw Exception('Este nombre de usuario ya está en uso');
      }

      final AuthResponse res =
          await supabase.auth.signUp(email: email, password: password);

      final User? user = res.user;

      if (user == null) {
        throw Exception('Error al registrar el usuario');
      }

      final insertResponse = await supabase.from('usuario').insert({
        'pk_usuario': user.id,
        'correo': email,
        'nombre': nombre,
        'apellidos': apellidos,
        'nombre_usuario': nombreUsuario,
        'telefono': telefono,
        'nombre_usuario_foro': nombreUsuario
      });

      return insertResponse;
    } on PostgrestException catch (postgrestError) {
      print('Postgres Error: ${postgrestError.message}');
      throw Exception(
          'Error al insertar en la base de datos: ${postgrestError.message}');
    } on AuthException catch (authError) {
      print('Authentication Error: ${authError.message}');
      throw Exception(authError.message);
    } catch (e) {
      print('Unexpected Signup Error: $e');
      throw Exception('Error durante el registro: $e');
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

  Future<void> logIn(String correo, String password) async {
    try {
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: correo,
        password: password,
      );
      final Session? session = res.session;
      final User? user = res.user;

      if (session == null || user == null) {
        throw Exception('Error de autenticación');
      }
    } on AuthException catch (e) {
      print('Authentication Error: ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      print('Login Error: $e');
      throw Exception('Error durante el inicio de sesión');
    }
  }

  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
    } catch (e) {
      print('Log out error: $e');
      throw Exception('Error al cerrar sesión');
    }
  }
}
