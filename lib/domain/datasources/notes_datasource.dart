import 'package:isar_example/domain/entities/note.dart';

abstract class NotesDatasource {
  // aquí defino mis reglas de negocio, el cómo se tienen que comportar los datas sources
  Future<List<Note>> getAllNotes();
  Future<Note?> getById(int id);
  Future<bool> add(Note note);
  Future<bool> delete(Note note);
  Future<bool> update(Note note);
}
