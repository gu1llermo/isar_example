import 'package:isar_example/domain/entities/note.dart';

abstract class NotesRepository {
  // los repositorios son los que van a allamar a los datasources
  Future<List<Note>> getAllNotes();
  Future<Note?> getById(int id);
  Future<bool> add(Note note);
  Future<bool> delete(Note note);
  Future<bool> update(Note note);
  // Future<void> initializeDb();
}
