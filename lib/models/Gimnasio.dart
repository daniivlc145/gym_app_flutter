
class Gimnasio {
  final String pk_gimnasio;
  final String nombre;
  final String ciudad;
  final String? codigo_postal;
  final String cadena_gimnasio;
  final String? logo;

  Gimnasio({
    required this.pk_gimnasio,
    required this.nombre,
    required this.ciudad,
    this.codigo_postal,
    required this.cadena_gimnasio,
    this.logo
});

  factory Gimnasio.fromMap(Map<String, dynamic> map) {
    return Gimnasio(
        pk_gimnasio: map['pk_gimnasio'] ?? '',
        nombre: map['nombre'] ?? '',
        ciudad: map['ciudad'] ?? '',
        codigo_postal: map['codigo_postal'] ?? '',
        cadena_gimnasio: map['cadena_gimnasio'] ?? '',
        logo: (map['logo'] != null && map['logo'].toString().isNotEmpty)
            ? map['logo'].toString().replaceAll("'", "")
            : ''
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pk_gimnasio': pk_gimnasio,
      'nombre': nombre,
      'ciudad': ciudad,
      'codigo_postal': codigo_postal,
      'cadena_gimnasio': cadena_gimnasio,
      'logo': logo,
    };
  }

  String get ubicacion {
    if (codigo_postal != null && codigo_postal!.isNotEmpty && codigo_postal != 'NULL') {
      return '$ciudad, $codigo_postal';
    }
    return ciudad;
  }


}