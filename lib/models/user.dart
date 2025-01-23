class User {
  final int id;
  final String name;
  final String? avatar;

  User({required this.id, required this.name, this.avatar});

  User copyWith({int? id, String? name, String? avatar}) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
    );
  }
}
