class ImageItem {
  final int id;
  final String nom_img;
  final DateTime date_ajout;
  final int id_memo;

  ImageItem({
    this.id = 0,
    this.nom_img = "",
    required this.date_ajout,
    this.id_memo = 0,
  });
}
