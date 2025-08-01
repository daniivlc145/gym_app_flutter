import 'package:gym_app/models/Ejercicio.dart';

class Rutina {
  final String id;
  final String nombre;
  final String fkUsuario;
  final List<Ejercicio> ejercicios;

  Rutina({
    required this.id,
    required this.nombre,
    required this.fkUsuario,
    required this.ejercicios,
  });
}