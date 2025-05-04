class Trip {
  final String id;
  final String name;
  final DateTime createdAt;
  final List<String> photoPaths;

  Trip({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.photoPaths,
  });

  int get photoCount => photoPaths.length;

  bool get isComplete => photoPaths.length >= 36;
}
