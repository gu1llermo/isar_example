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
  Future<void> add(Note note) async {
    final isar = await isarDb;
    await isar.writeTxn(() async {
      await isar.noteIsars
          .put(NoteMapper.entityToNoteIsar(note)); // insert & update
    });
  }

  @override
  Future<void> delete(Note note) async {
    final isar = await isarDb;
    if (note.id == null) return; // si es null entonces no hace nada
    await isar.writeTxn(() async {
      await isar.noteIsars.delete(note.id!); // delete
    });
  }

  @override
  Future<List<Note>> getAllNotes() async {
    final isar = await isarDb;
    final listNoteIsar = await isar.noteIsars.where().findAll();
    final allNotes = listNoteIsar.map(NoteMapper.noteIsarToEntity).toList();
    return allNotes;
  }

  @override
  Future<void> update(Note note) async {
    final isar = await isarDb;
    await isar.writeTxn(() async {
      await isar.noteIsars
          .put(NoteMapper.entityToNoteIsar(note)); // insert & update
    });
  }

  @override
  Future<Note?> getById(int id) async {
    final isar = await isarDb;
    final noteIsar = await isar.noteIsars.get(id); // get
    if (noteIsar == null) return null;
    final note = NoteMapper.noteIsarToEntity(noteIsar);
    return note;
  }
}
