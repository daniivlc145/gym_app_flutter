class Cadena {
  final String pk_cadena_gimnasio;
  final String nombre;
  final String? logo;

  Cadena({
    required this.pk_cadena_gimnasio,
    required this.nombre,
    this.logo,
  });

  factory Cadena.fromMap(Map<String, dynamic> map) {
    return Cadena(
      pk_cadena_gimnasio: map['pk_cadena_gimnasio'] ?? '',
      nombre: map['nombre'] ?? '',
      logo: (map['logo'] != null && map['logo'].toString().isNotEmpty)
          ? map['logo'].toString().replaceAll("'", "")
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pk_cadena_gimnasio': pk_cadena_gimnasio,
      'nombre': nombre,
      'logo': logo,
    };
  }
}