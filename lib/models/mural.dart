class Mural {
  final int? id;
  final String titulo;
  final String? descripcion;
  final String? fotoUrl;
  final double latitud;
  final double longitud;
  final DateTime? createdAt;
  final String? userId;
  final String? autorApodo;
  final String? autorAvatarUrl;

  Mural({
    this.id,
    required this.titulo,
    this.descripcion,
    this.fotoUrl,
    required this.latitud,
    required this.longitud,
    this.createdAt,
    this.userId,
    this.autorApodo,
    this.autorAvatarUrl,
  });

  factory Mural.fromMap(Map<String, dynamic> map) {
    return Mural(
      id: map['id'] as int?,
      titulo: map['titulo'] as String,
      descripcion: map['descripcion'] as String?,
      fotoUrl: map['foto_url'] as String?,
      latitud: (map['latitud'] as num).toDouble(),
      longitud: (map['longitud'] as num).toDouble(),
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      userId: map['user_id'] as String?,
    );
  }

  Mural conAutor({String? apodo, String? avatarUrl}) {
    return Mural(
      id: id,
      titulo: titulo,
      descripcion: descripcion,
      fotoUrl: fotoUrl,
      latitud: latitud,
      longitud: longitud,
      createdAt: createdAt,
      userId: userId,
      autorApodo: apodo,
      autorAvatarUrl: avatarUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'foto_url': fotoUrl,
      'latitud': latitud,
      'longitud': longitud,
      'user_id': userId,
    };
  }
}