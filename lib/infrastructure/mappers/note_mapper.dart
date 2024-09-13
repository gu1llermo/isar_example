import 'package:isar_example/config/helpers/tools.dart';
import 'package:isar_example/domain/entities/note.dart';
import 'package:isar_example/infrastructure/models/google_sheets/note_google_sheets.dart';
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

  static Note mapToEntity(Map<String, dynamic>? json) => Note(
        id: json?['id'],
        content: json?['content'] ?? '',
        isCompleted: json?['isCompleted'] ?? false,
        title: json?['title'] ?? '',
        timeStamp: json?['timeStamp'] ?? getTimeStamp(),
      );

  static Map<String, dynamic> entityToMap(Note note) => {
        'id': note.id,
        'content': note.content,
        'isCompleted': note.isCompleted,
        'title': note.title,
        'timeStamp': note.timeStamp
      };

  static Note noteGoogleSheetsToEntity(NoteGoogleSheets noteGoogleSheet) =>
      Note(
          id: noteGoogleSheet.id,
          content: noteGoogleSheet.content,
          isCompleted: noteGoogleSheet.isCompleted,
          title: noteGoogleSheet.title,
          timeStamp: noteGoogleSheet.timeStamp);

  static NoteGoogleSheets entityToNoteGoogleSheets(Note note) =>
      NoteGoogleSheets(
        id: note.id,
        content: note.content,
        isCompleted: note.isCompleted,
        title: note.title,
        timeStamp: note.timeStamp ?? getTimeStamp(),
      );
}
