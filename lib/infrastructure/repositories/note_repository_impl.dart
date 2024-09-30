import 'package:isar_example/domain/datasources/notes_datasource.dart';
import 'package:isar_example/domain/entities/note.dart';
import 'package:isar_example/domain/repositories/notes_repository.dart';

class NoteRepositoryImpl extends NotesRepository {
  final NotesDatasource datasource;
  NoteRepositoryImpl(this.datasource);

  @override
  Future<int> add(Note note) async {
    return await datasource.add(note);
  }

  @override
  Future<int> delete(Note note) async {
    return await datasource.delete(note);
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
  Future<int> update(Note note) async {
    return await datasource.update(note);
  }

  @override
  Future<void> addAll(List<Note> notes) async {
    await datasource.addAll(notes);
  }

  @override
  Future<void> deleteAll(List<Note> notes) async {
    await datasource.deleteAll(notes);
  }

  @override
  Future<void> updateAll(List<Note> notes) async {
    await datasource.updateAll(notes);
  }

  @override
  Future<void> clear() async {
    await datasource.clear();
  }

  @override
  Future<int> getLastUpdate() async {
    return await datasource.getLastUpdate();
  }

  @override
  Future<void> setLastUpdate(int lastUpdate) async {
    await datasource.setLastUpdate(lastUpdate);
  }

  @override
  String getPrefixIndex() {
    return datasource.getPrefixIndex();
  }
}
