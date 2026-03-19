class Category {
  final int? id;
  final String name;
  final String? description;
  final String? createdAt;

  Category({
    this.id,
    required this.name,
    this.description,
    this.createdAt,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      description: map['description'] as String?,
      createdAt: map['created_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description ?? '',
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };
  }

  Category copyWith({
    int? id,
    String? name,
    String? description,
    String? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
