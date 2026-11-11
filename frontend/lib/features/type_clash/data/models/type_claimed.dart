class TypeClaimed {
  final String type;
  final String username;

  const TypeClaimed({required this.type, required this.username});

  factory TypeClaimed.fromJson(Map<String, dynamic> json) {
    return TypeClaimed(
      type: json['type'] as String,
      username: json['username'] as String,
    );
  }
}
