import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:isar_example/infrastructure/mappers/note_mapper.dart';

import 'package:sembast/sembast_io.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:sembast_web/sembast_web.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:isar_example/domain/datasources/notes_datasource.dart';
import 'package:isar_example/domain/entities/note.dart';

class NoteSembastDatasource extends NotesDatasource {
  Database? _database;
  final String nameStore;
  final String nameDb;
  late StoreRef<int, Map<String, Object?>> _store;
  late StoreRef<Object?, Object?> _preferenceStore;
  int? _index;
  static const String _prefixIndex = '2';
  static const int _indexInicial = 0;

  static const int _lastUpdateInicial = 0;

  NoteSembastDatasource({required this.nameStore, required this.nameDb}) {
    _store = intMapStoreFactory.store(nameStore);
    _preferenceStore = StoreRef.main();
  }

  Future<int> _initIndex() async {
    final db = await database;
    return await _preferenceStore.record('index').get(db) as int? ??
        int.parse('$_prefixIndex$_indexInicial');
    // _indexInicial;
  }

  // localDatabes siempre empieza en 0 su id, así 10 es el id 0
  // esto es para diferenciarlo del remote id, porque estoy trabajando con int

  Future<int> get index async => _index ??= await _initIndex();

  Future<int> _getNewindex() async {
    final i = await index;

    final indexTxt = i.toString();
    final result = indexTxt.substring(1, indexTxt.length);
    final indexResult = '$_prefixIndex${(int.parse(result) + 1).toString()}';
    final newIndex = int.parse(indexResult);

    await _saveIndex(newIndex);

    return newIndex;
  }

  Future<void> _saveIndex(int index) async {
    final db = await database;
    _index = index;
    _preferenceStore.record('index').put(db, index);
  }

  /// When set to true, the database will be opened from a volatile a space in
  /// memory instead. Great for testing purposes.
  bool openDatabaseFromMemory = false;

  /// The local database.
  Future<Database> get database async => _database ??= await _createDatabase();

  Future<Database> _createDatabase() async {
    final fileName = nameDb;

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
  String getPrefixIndex() {
    return _prefixIndex;
  }

  @override
  Future<int> add(Note note) async {
    final db = await database;

    final int key = note.id ?? await _getNewindex();
    await db.transaction((txn) async {
      //key = await _store.add(txn, NoteMapper.entityToMap(note));

      // tengo que hacer así para que la nota contenga el id respectivo
      final noteCopy = note.copyWith(id: key);
      await _store.record(key).add(txn, NoteMapper.entityToMap(noteCopy));
    });

    return key;
  }

  @override
  Future<void> addAll(List<Note> notes) async {
    // aquí tengo que asumir que las notas ya tienen su id respectivo
    // porque la idea es sincronizar el repositorio local con el remoto
    // para que agregue aqui en el local, debería borrar previamente éste reposotio local

    final db = await database;

    await db.transaction((txn) async {
      for (Note note in notes) {
        // int key = await _store.add(txn, NoteMapper.entityToMap(note));
        int key = note.id!;

        // tengo que hacer así para que la nota contenga el id respectivo
        //final noteCopy = note.copyWith(id: key);
        // add genera erro si el id/key existe, así que debe estar limpia la base de datos
        // puedo usar put, pero quiero usar add, porque la base de datos local tienes
        // limpiarla previamente antes de usar éste comando
        await _store.record(key).add(txn, NoteMapper.entityToMap(note));
      }
    });
  }

  @override
  Future<void> deleteAll(List<Note> notes) async {
    // aquí tengo que asumir que las notas ya tienen su id respectivo
    // porque la idea es sincronizar el repositorio local con el remoto
    // para que agregue aqui en el local, debería borrar previamente éste reposotio local

    final db = await database;

    await db.transaction((txn) async {
      for (Note note in notes) {
        int key = note.id!;
        await _store.record(key).delete(txn);
      }
    });
  }

  @override
  Future<void> updateAll(List<Note> notes) async {
    // aquí tengo que asumir que las notas ya tienen su id respectivo
    // porque la idea es sincronizar el repositorio local con el remoto
    // para que agregue aqui en el local, debería borrar previamente éste reposotio local

    final db = await database;

    await db.transaction((txn) async {
      for (Note note in notes) {
        int key = note.id!;
        await _store.record(key).update(txn, NoteMapper.entityToMap(note));
      }
    });
  }

  @override
  Future<int> delete(Note note) async {
    if (note.id == null) return -1;
    final db = await database;
    final key = note.id!;

    await _store.record(key).delete(db);

    // await store.delete(db, finder: Finder(filter: Filter.byKey(key)));

    return key;
  }

  // Future<void> _checkIndex() async {// lo quité porque quiero que sea único
  // lo va a manejar varias fuentes
  //   // hago esto porque es local
  //   final allNotes = await getAllNotes();
  //   if (allNotes.isEmpty) {
  //     await _saveIndex(_indexInicial);
  //   }
  // }

  @override
  Future<void> clear() async {
    final db = await database;
    await _store.delete(db);
  }

  @override
  Future<List<Note>> getAllNotes() async {
    final db = await database;
    final snapshots = await _store.query().getSnapshots(db);
    final listNotes = snapshots
        .map((snapshot) => NoteMapper.mapToEntity(snapshot.value))
        .toList();
    listNotes
        .sort((note1, note2) => note1.timeStamp!.compareTo(note2.timeStamp!));
    return listNotes;
  }

  @override
  Future<Note?> getById(int id) async {
    final db = await database;
    final mapRecord = await _store.record(id).get(db);
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
    await _store.record(key).update(db, NoteMapper.entityToMap(note));

    // await store.update(db, NoteMapper.entityToMap(note),
    //     finder: Finder(filter: Filter.byKey(key)));
    return key;
  }

  @override
  Future<int> getLastUpdate() async {
    final db = await database;
    final lastUpdate =
        await _preferenceStore.record('lastUpdate').get(db) as int? ??
            _lastUpdateInicial;
    return lastUpdate;
  }

  @override
  Future<void> setLastUpdate(int lastUpdate) async {
    final db = await database;
    await _preferenceStore.record('lastUpdate').put(db, lastUpdate);
  }
}
