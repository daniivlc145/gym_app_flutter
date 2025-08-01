import 'dart:io';
import 'Ejercicio.dart';

class Entrenamiento {
  final String pk_entrenamiento;
  final String nombre;
  final List<File>? fotos;
  final String descripcion;
  final Duration duracion;
  final String fkUsuario;
  final Map<String, Ejercicio> ejercicios;
  final DateTime fecha;
  final String? rutinaId;

  Entrenamiento({
    required this.pk_entrenamiento,
    required this.nombre,
    required this.fkUsuario,
    required this.ejercicios,
    required this.fecha,
    this.descripcion = '',
    this.fotos = const [],
    this.duracion = Duration.zero,
    this.rutinaId,
  });
}