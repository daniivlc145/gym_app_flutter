class Post {
  final String id;
  final DateTime createdAt;
  final String titulo;
  final String descripcion;
  final String fkTopic;
  final String fkUsuario;
  final List<String> fotos;
  final List<String> etiquetas;
  int votos;

  Post({
    required this.id,
    required this.createdAt,
    required this.titulo,
    required this.descripcion,
    required this.fkTopic,
    required this.fkUsuario,
    required this.fotos,
    required this.etiquetas,
    this.votos = 0,
  });

  factory Post.fromMap(Map<String, dynamic> map, {int votos = 0}) {
    return Post(
      id: map['pk_post'] as String,
      createdAt: DateTime.parse(map['created_at']),
      titulo: map['titulo'] ?? '',
      descripcion: map['descripcion'] ?? '',
      fkTopic: map['fk_topic'] ?? '',
      fkUsuario: map['fk_usuario'] ?? '',
      fotos: List<String>.from(map['fotos'] ?? []),
      etiquetas: List<String>.from(map['etiquetas'] ?? []),
      votos: votos,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'fk_topic': fkTopic,
      'fk_usuario': fkUsuario,
      'fotos': fotos,
      'etiquetas': etiquetas,
    };
  }
}