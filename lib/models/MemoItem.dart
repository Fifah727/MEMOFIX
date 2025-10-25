class MemoItem {
  final int id;
  final String titre;
  final String text;
  final String category;
  final DateTime createdAt;
  bool isImportant;

  MemoItem({
    this.id = 0,
    this.titre = "",
    required this.text,
    this.category = 'Personnel',
    required this.createdAt,
    this.isImportant = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemoItem &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          createdAt == other.createdAt;

  @override
  int get hashCode => text.hashCode ^ createdAt.hashCode;
}
