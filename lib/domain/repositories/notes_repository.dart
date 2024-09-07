import 'package:isar/isar.dart';
import 'package:isar_example/domain/entities/note.dart';

abstract class NotesRepository {
  // los repositorios son los que van a allamar a los datasources
  Future<List<Note>> getAllNotes();
  Future<Note?> getById(Id id);
  Future<void> add(Note note);
  Future<void> delete(Note note);
  Future<void> update(Note note);
  // Future<void> initializeDb();
}
