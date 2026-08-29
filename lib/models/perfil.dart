class Perfil {
  final String id;
  final String apodo;
  final String? avatarUrl;
  final DateTime? createdAt;

  Perfil({
    required this.id,
    required this.apodo,
    this.avatarUrl,
    this.createdAt,
  });

  factory Perfil.fromMap(Map<String, dynamic> map) {
    return Perfil(
      id: map['id'] as String,
      apodo: map['apodo'] as String? ?? 'Muralista',
      avatarUrl: map['avatar_url'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'apodo': apodo,
      'avatar_url': avatarUrl,
    };
  }
}
