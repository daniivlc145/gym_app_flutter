import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../services/auth_service.dart';

class Validators {
  static String? validateEmail(String value) {
    if (value.isEmpty) {
      return 'Por favor ingrese su correo electrónico';
    }
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@(($$[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$$)|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Por favor ingrese un correo electrónico válido';
    }
    return null;
  }

  static Future<String?> validateEmailForRegister(String value) async {
    if (value.isEmpty) {
      return 'Por favor ingrese su correo electrónico';
    }
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@(($$[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$$)|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Por favor ingrese un correo electrónico válido';
    }
    try {
      if (await AuthService().emailExistsInDatabase(value)) {
        return 'El correo electrónico ya está registrado.';
      }
    } catch (e) {
      return 'Error al verificar el correo electrónico';
    }
    return null;
  }

  static Future<String?> validateUsername(String value) async {
    if (value.isEmpty) {
      return 'El nombre de usuario es obligatorio';
    }
    try {
      if (await AuthService().usernameExistsInDatabase(value)) {
        return 'El nombre de usuario ya está en uso';
      }
    } catch (e) {
      return 'Error al verificar el nombre de usuario';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese su contraseña';
    }
    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    return null;
  }
}