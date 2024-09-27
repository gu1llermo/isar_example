import 'dart:async';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'package:isar_example/infrastructure/mappers/note_mapper.dart';
import 'package:isar_example/domain/datasources/notes_datasource.dart';
import 'package:isar_example/domain/entities/note.dart';
import 'package:isar_example/infrastructure/models/isar/note_isar.dart';

class NoteIsarDatasource extends NotesDatasource {
// NoteIsarSchema

  Isar? _isar;

  Future<Isar> initializeDb() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = dir.path;
    return await Isar.open(
      [NoteIsarSchema],
      directory: path,
    );
  }

  Future<Isar> get isarDb async => _isar ??= await initializeDb();

  @override
  Future<int> add(Note note) async {
    final isar = await isarDb;
    final id = await isar.writeTxn(() async {
      return await isar.noteIsars
          .put(NoteMapper.entityToNoteIsar(note)); // insert & update
    });
    return id;
  }

  @override
  Future<int> delete(Note note) async {
    final isar = await isarDb;
    if (note.id == null) return -1; // si es null entonces no hace nada
    final succes = await isar.writeTxn(() async {
      return await isar.noteIsars.delete(note.id!); // delete
    });
    return succes ? note.id! : -1;
  }

  @override
  Future<List<Note>> getAllNotes() async {
    final isar = await isarDb;
    final listNoteIsar = await isar.noteIsars.where().findAll();
    final allNotes = listNoteIsar.map(NoteMapper.noteIsarToEntity).toList();
    return allNotes;
  }

  @override
  Future<int> update(Note note) async {
    final isar = await isarDb;
    final id = await isar.writeTxn(() async {
      return await isar.noteIsars
          .put(NoteMapper.entityToNoteIsar(note)); // insert & update
    });
    return id;
  }

  @override
  Future<Note?> getById(int id) async {
    final isar = await isarDb;
    final noteIsar = await isar.noteIsars.get(id); // get
    if (noteIsar == null) return null;
    final note = NoteMapper.noteIsarToEntity(noteIsar);
    return note;
  }

  @override
  Future<void> addAll(List<Note> notes) {
    // TODO: implement addAll
    throw UnimplementedError();
  }

  @override
  Future<void> clear() {
    // TODO: implement clear
    throw UnimplementedError();
  }
}
