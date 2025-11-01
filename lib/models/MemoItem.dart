class MemoItem {
  final int id;
  final String titre;
  final String text;
  final int category;
  final DateTime createdAt;
  final DateTime modifiedAt;
  bool isImportant;
  bool verrouille;

  MemoItem({
    this.id = 0,
    this.titre = "",
    this.text = "",
    this.category = 1,
    required this.createdAt,
    required this.modifiedAt,
    this.isImportant = false,
    this.verrouille = false,
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
