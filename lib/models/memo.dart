import 'package:hive/hive.dart';

part 'memo.g.dart';

@HiveType(typeId: 0)
class Memo extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String content;

  @HiveField(2)
  DateTime createdAt;

  Memo({required this.title, required this.content, required this.createdAt});
}