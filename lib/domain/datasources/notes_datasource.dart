import 'package:isar_example/domain/entities/note.dart';

abstract class NotesDatasource {
  // aquí defino mis reglas de negocio, el cómo se tienen que comportar los datas sources
  Future<List<Note>> getAllNotes();
  Future<Note?> getById(int id);
  Future<int> add(Note note);
  Future<void> addAll(List<Note> notes);
  Future<int> delete(Note note);
  Future<void> clear(); // borra la base de datos completamente
  Future<int> update(Note note);
}
