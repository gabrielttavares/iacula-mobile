final class AuthorModel {
  const AuthorModel({
    required this.id,
    required this.name,
    required this.description,
    required this.worksCount,
    required this.assetPath,
  });

  final String id;
  final String name;
  final String description;
  final int worksCount;
  final String assetPath;

  factory AuthorModel.fromJson(Map<String, dynamic> json) {
    final worksCountRaw = json['worksCount'];
    final parsedWorksCount = switch (worksCountRaw) {
      int() => worksCountRaw,
      String() => int.tryParse(worksCountRaw) ?? 0,
      _ => 0,
    };

    return AuthorModel(
      id: (json['id'] as String? ?? '').trim(),
      name: (json['name'] as String? ?? '').trim(),
      description: (json['description'] as String? ?? '').trim(),
      worksCount: parsedWorksCount,
      assetPath: (json['assetPath'] as String? ?? '').trim(),
    );
  }
}
