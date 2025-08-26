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

  factory Ejercicio.fromId(int pkEjercicio) => Ejercicio(
    pk_ejercicio: pkEjercicio,
    nombre: '',
    grupo_muscular: '',
    equipamiento: '',
  );

  Map<String, dynamic> toMap() {
    return {
      'pk_ejercicio': pk_ejercicio,
      'nombre': nombre,
      'grupo_muscular': grupo_muscular,
      'equipamiento': equipamiento,
    };
  }

  Ejercicio copyWith({
    int? pk_ejercicio,
    String? nombre,
    String? grupo_muscular,
    String? equipamiento,
  }) {
    return Ejercicio(
      pk_ejercicio: pk_ejercicio ?? this.pk_ejercicio,
      nombre: nombre ?? this.nombre,
      grupo_muscular: grupo_muscular ?? this.grupo_muscular,
      equipamiento: equipamiento ?? this.equipamiento,
    );
  }
}
