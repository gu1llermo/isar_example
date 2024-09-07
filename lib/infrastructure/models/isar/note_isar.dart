import 'package:isar/isar.dart';

part 'note_isar.g.dart';

@Collection()
class NoteIsar {
  Id? id;
  String? title;
  String? content;
  late bool isCompleted;
}
