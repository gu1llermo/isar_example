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
  Future<bool> add(Note note) async {
    // yo necesito que me notifiques sí pudistes hacer tú función
    // porque sino lo pudistes hacer deberían planificar hacerlo en otro momento.

    final db = await database;
    final key = await store.add(db, NoteMapper.entityToMap(note));
    final noteCopy = note.copyWith(id: key);
    update(noteCopy);
    // tengo que hacer así para que la nota contenga el id respectivo
    return true;
  }

  @override
  Future<bool> delete(Note note) async {
    if (note.id == null) return true;
    final db = await database;
    final key = note.id!;
    await store.delete(db, finder: Finder(filter: Filter.byKey(key)));
    return true;
  }

  @override
  Future<List<Note>> getAllNotes() async {
    final db = await database;
    final snapshot = await store.query().getSnapshots(db);
    final listNotes =
        snapshot.map((e) => NoteMapper.mapToEntity(e.value)).toList();
    return listNotes;
  }

  @override
  Future<Note?> getById(int id) async {
    final db = await database;
    var noteRecord = await (store.record(id).getSnapshot(db)
        as FutureOr<RecordSnapshot<int, Map<String, Object>>?>);
    if (noteRecord?.value == null) return null;
    return NoteMapper.mapToEntity(noteRecord!.value);
  }

  @override
  Future<bool> update(Note note) async {
    if (note.id == null) return true;
    final db = await database;
    final key = note.id!;

    await store.update(db, NoteMapper.entityToMap(note),
        finder: Finder(filter: Filter.byKey(key)));
    return true;
  }
}
