class TypeSelectionStarted {
  final List<String> availableTypes;
  final int selectionSeconds;

  const TypeSelectionStarted({
    required this.availableTypes,
    required this.selectionSeconds,
  });

  factory TypeSelectionStarted.fromJson(Map<String, dynamic> json) {
    return TypeSelectionStarted(
      availableTypes: (json['availableTypes'] as List)
          .map((e) => e as String)
          .toList(),
      selectionSeconds: json['selectionSeconds'] as int,
    );
  }
}
