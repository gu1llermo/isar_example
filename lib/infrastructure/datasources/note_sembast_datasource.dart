import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:isar_example/infrastructure/mappers/note_mapper.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:sembast_web/sembast_web.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:isar_example/domain/datasources/notes_datasource.dart';
import 'package:isar_example/domain/entities/note.dart';

class NoteSembastDatasource extends NotesDatasource {
  Database? _database;

  /// When set to true, the database will be opened from a volatile a space in
  /// memory instead. Great for testing purposes.
  bool openDatabaseFromMemory = false;

  final store = intMapStoreFactory.store('note_sembast_store');

  /// The local database.
  Future<Database> get database async => _database ??= await _createDatabase();

  Future<Database> _createDatabase() async {
    const fileName = 'notes.db';

    if (openDatabaseFromMemory) {
      return databaseFactoryMemory.openDatabase(fileName);
    }

    if (kIsWeb) {
      return databaseFactoryWeb.openDatabase(fileName);
    }

    final dir = await getApplicationDocumentsDirectory();
    await dir.create(recursive: true);
    final path = join(dir.path, fileName);
    return databaseFactoryIo.openDatabase(path);
  }

  @override
  Future<void> add(Note note) async {
    final db = await database;

    final key = await store.add(db, NoteMapper.entityToJson(note));

    final noteCopy = note.copyWith(id: key);

    await update(noteCopy);
    // tengo que hacer así para que la nota contenga el id respectivo
  }

  @override
  Future<void> delete(Note note) async {
    if (note.id == null) return;
    final db = await database;
    final key = note.id!;
    await store.delete(db, finder: Finder(filter: Filter.byKey(key)));
  }

  @override
  Future<List<Note>> getAllNotes() async {
    final db = await database;
    final snapshot = await store.query().getSnapshots(db);
    final listNotes =
        snapshot.map((e) => NoteMapper.jsonToEntity(e.value)).toList();
    return listNotes;
  }

  @override
  Future<Note?> getById(int id) async {
    final db = await database;
    var noteRecord = await (store.record(id).getSnapshot(db)
        as FutureOr<RecordSnapshot<int, Map<String, Object>>?>);
    if (noteRecord?.value == null) return null;
    return NoteMapper.jsonToEntity(noteRecord!.value);
  }

  @override
  Future<void> update(Note note) async {
    if (note.id == null) return;
    final db = await database;
    final key = note.id!;

    await store.update(db, NoteMapper.entityToJson(note),
        finder: Finder(filter: Filter.byKey(key)));
  }
}
