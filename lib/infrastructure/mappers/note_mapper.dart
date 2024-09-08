import 'package:isar_example/domain/entities/note.dart';
import 'package:isar_example/infrastructure/models/isar/note_isar.dart';
import 'package:isar_example/infrastructure/models/sembast/note_sembast.dart';

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

// todo revisar después
  static Note noteSembastToEntity(NoteSembast noteSembast) => Note(
      id: noteSembast.id,
      content: noteSembast.content ?? '',
      isCompleted: noteSembast.isCompleted,
      title: noteSembast.title ?? '');

// todo revisar después
  static NoteSembast entityToNoteSembast(Note note) => NoteSembast()
    ..id = note.id
    ..content = note.content
    ..isCompleted = note.isCompleted
    ..title = note.title;
}
