import 'dart:io';
import 'Ejercicio.dart';

class Entrenamiento {
  final String pk_entrenamiento;
  final String nombre;
  final List<File>? fotos;
  final String descripcion;
  final Duration duracion;
  final String fkUsuario;
  final Map<String, dynamic> ejercicios;
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

  Map<String, dynamic> toJson() {
    return {
      'pk_entrenamiento': pk_entrenamiento,
      'nombre': nombre,
      'descripcion': descripcion,
      'duracion': duracion.inSeconds,
      'fk_usuario': fkUsuario,
      'ejercicios': ejercicios, // 👈️ Guardamos el JSON tal cual
      'fecha': fecha.toIso8601String(),
      'fotos': fotos?.map((f) => f.path).toList() ?? [],
      'rutina_id': rutinaId,
    };
  }

  factory Entrenamiento.fromJson(Map<String, dynamic> json) {
    return Entrenamiento(
      pk_entrenamiento: json['pk_entrenamiento'],
      nombre: json['nombre'],
      descripcion: json['descripcion'] ?? '',
      duracion: Duration(seconds: json['duracion'] ?? 0),
      fkUsuario: json['fk_usuario'],
      ejercicios: json['ejercicios'] ?? {},
      fecha: DateTime.tryParse(json['fecha'] ?? '') ?? DateTime.now(),
      fotos: (json['fotos'] as List?)
          ?.whereType<String>()
          .map((e) => File(e))
          .toList(),
      rutinaId: json['rutina_id'],
    );
  }
}