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
  Future<int> add(Note note) async {
    final db = await database;

    late int key;
    await db.transaction((txn) async {
      key = await store.add(txn, NoteMapper.entityToMap(note));

      // tengo que hacer así para que la nota contenga el id respectivo
      final noteCopy = note.copyWith(id: key);
      await store.record(key).update(txn, NoteMapper.entityToMap(noteCopy));
    });

    return key;
  }

  @override
  Future<void> addAll(List<Note> notes) async {
    final db = await database;

    await db.transaction((txn) async {
      for (Note note in notes) {
        int key = await store.add(txn, NoteMapper.entityToMap(note));

        // tengo que hacer así para que la nota contenga el id respectivo
        final noteCopy = note.copyWith(id: key);
        await store.record(key).update(txn, NoteMapper.entityToMap(noteCopy));
      }
    });
  }

  @override
  Future<int> delete(Note note) async {
    if (note.id == null) return -1;
    final db = await database;
    final key = note.id!;

    await store.record(key).delete(db);

    // await store.delete(db, finder: Finder(filter: Filter.byKey(key)));

    return key;
  }

  @override
  Future<void> clear() async {
    final db = await database;
    await store.delete(db);
  }

  @override
  Future<List<Note>> getAllNotes() async {
    final db = await database;
    final snapshots = await store.query().getSnapshots(db);
    final listNotes = snapshots
        .map((snapshot) => NoteMapper.mapToEntity(snapshot.value))
        .toList();
    return listNotes;
  }

  @override
  Future<Note?> getById(int id) async {
    final db = await database;
    final mapRecord = await store.record(id).get(db);
    // supongo que si no lo consigue regresa null
    if (mapRecord == null) return null;
    return NoteMapper.mapToEntity(mapRecord);
  }

  @override
  Future<int> update(Note note) async {
    if (note.id == null) return -1;
    final db = await database;
    final key = note.id!;

    // el key tiene que existir para que se actualice
    await store.record(key).update(db, NoteMapper.entityToMap(note));

    // await store.update(db, NoteMapper.entityToMap(note),
    //     finder: Finder(filter: Filter.byKey(key)));
    return key;
  }
}
