class Usuario {
  final String nombre;
  final String apellidos;
  final String telefono;
  final String correo;
  final Map<String, dynamic>? medidas;
  final String nombreUsuario;
  final String? nombreUsuarioForo;
  final String? fotoUsuario;

  Usuario({
    required this.nombre,
    required this.apellidos,
    required this.telefono,
    required this.correo,
    this.medidas,
    required this.nombreUsuario,
    this.nombreUsuarioForo,
    this.fotoUsuario,
  });

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      nombre: map['nombre'] ?? '',
      apellidos: map['apellidos'] ?? '',
      telefono: map['telefono'] ?? '',
      correo: map['correo'] ?? '',
      medidas: map['medidas'],
      nombreUsuario: map['nombre_usuario'] ?? '',
      nombreUsuarioForo: map['nombre_usuario_foro'],
      fotoUsuario: (map['foto_usuario'] != null && map['foto_usuario'].toString().isNotEmpty)
          ? map['foto_usuario'].toString().replaceAll("'", "")
          : 'https://tu-servidor.com/avatar_default.png',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'apellidos': apellidos,
      'telefono': telefono,
      'correo': correo,
      'medidas': medidas,
      'nombre_usuario': nombreUsuario,
      'nombre_usuario_foro': nombreUsuarioForo,
      'foto_usuario': fotoUsuario,
    };
  }

}