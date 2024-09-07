import 'package:isar/isar.dart';
import 'package:isar_example/domain/entities/note.dart';

abstract class NotesDatasource {
  // aquí defino mis reglas de negocio, el cómo se tienen que comportar los datas sources
  Future<List<Note>> getAllNotes();
  Future<Note?> getById(Id id);
  Future<void> add(Note note);
  Future<void> delete(Note note);
  Future<void> update(Note note);
  // Future<void> initializeDb();
}
