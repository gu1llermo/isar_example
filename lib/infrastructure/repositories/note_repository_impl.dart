import 'package:isar_example/domain/datasources/notes_datasource.dart';
import 'package:isar_example/domain/entities/note.dart';
import 'package:isar_example/domain/repositories/notes_repository.dart';

class NoteRepositoryImpl extends NotesRepository {
  final NotesDatasource datasource;
  NoteRepositoryImpl(this.datasource);

  @override
  Future<void> add(Note note) async {
    await datasource.add(note);
  }

  @override
  Future<void> delete(Note note) async {
    await datasource.delete(note);
  }

  @override
  Future<List<Note>> getAllNotes() async {
    return await datasource.getAllNotes();
  }

  @override
  Future<Note?> getById(int id) async {
    return await datasource.getById(id);
  }

  @override
  Future<void> update(Note note) async {
    await datasource.update(note);
  }
}
