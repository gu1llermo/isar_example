import 'package:isar_example/domain/entities/note.dart';
import 'package:isar_example/infrastructure/models/isar/note_isar.dart';

class NoteMapper {
  static Note noteIsarToEntity(NoteIsar noteIsar) => Note(
      id: noteIsar.id,
      content: noteIsar.content ?? '',
      isCompleted: noteIsar.isCompleted,
      title: noteIsar.title ?? '');

  static NoteIsar entityToNoteIsar(Note note) => NoteIsar()
    ..id = note.id
    ..content = note.content
    ..isCompleted = note.isCompleted
    ..title = note.title;
}
