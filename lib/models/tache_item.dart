class TacheItem {
  final int id;
  String contenu;
  final int id_memo;
  final DateTime createdAt;
  bool fait;

  TacheItem({
    this.id = 0,
    this.contenu = "",
    this.id_memo = 0,
    required this.fait,
    required this.createdAt,
  });
}
