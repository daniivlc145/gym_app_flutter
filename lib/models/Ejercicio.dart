class Ejercicio {
  final int pk_ejercicio;
  final String nombre;
  final String grupo_muscular;
  final String equipamiento;

  Ejercicio({
    required this.pk_ejercicio,
    required this.nombre,
    required this.grupo_muscular,
    required this.equipamiento,
  });

  factory Ejercicio.fromMap(Map<String, dynamic> map) {
    return Ejercicio(
      pk_ejercicio: map['pk_ejercicio'] ?? '',
      nombre: map['nombre'] ?? '',
      grupo_muscular: map['grupo_muscular'] ?? '',
      equipamiento: map['equipamiento'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pk_ejercicio': pk_ejercicio,
      'nombre': nombre,
      'grupo_muscular': grupo_muscular,
      'equipamiento': equipamiento,
    };
  }
}
