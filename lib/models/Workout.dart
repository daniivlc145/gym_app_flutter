class Workout {

  final String pk_entrenamiento;
  final String titulo;
  final String? descripcion;
  final List<String>? fotos;
  final int duracion;
  final String fk_usuario;
  final List<Map<String, dynamic>> ejercicios;
  final DateTime hora_inicio;
  final DateTime hora_final;
  final String fk_gimnasio;

  Workout({
    required this.pk_entrenamiento,
    required this.titulo,
    this.descripcion,
    this.fotos,
    required this.duracion,
    required this.fk_usuario,
    required this.ejercicios,
    required this.hora_inicio,
    required this.hora_final,
    required this.fk_gimnasio
  });

}