import 'package:isar_example/config/helpers/tools.dart';
import 'package:isar_example/domain/entities/note.dart';
import 'package:isar_example/infrastructure/models/google_sheets/note_google_sheets.dart';

class NoteMapper {
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

  static Map<String, dynamic> listEntityToMap(List<Note> notes) => {
        "notes": List<dynamic>.from(notes.map(entityToMap)),
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
