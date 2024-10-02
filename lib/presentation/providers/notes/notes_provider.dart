import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synchronized/synchronized.dart';
import 'package:isar_example/domain/entities/note.dart';
import 'package:isar_example/infrastructure/repositories/note_repository_impl.dart';
import 'package:isar_example/presentation/providers/notes/notes_repository_provider.dart';

final asyncNotesProvider =
    AsyncNotifierProvider<NotesNotifier, List<Note>>(() => NotesNotifier());

class NotesNotifier extends AsyncNotifier<List<Note>> {
  late NoteRepositoryImpl _localNotesRepository;
  late NoteRepositoryImpl _remoteNotesRepository;

  late NoteRepositoryImpl _createNotesRepository;
  late NoteRepositoryImpl _updateNotesRepository;
  late NoteRepositoryImpl _deleteNotesRepository;

  Timer? _timer;
  // bool _isBusy = false;
  final _lock = Lock();

  Future<void> _fetchNotes() async {
    state = await AsyncValue.guard(() async {
      return await getAllNotes();
    });
  }

  // cómo puedo desplegar una función periódica una sola vez
  // que verifique cada cierto tiempo que hay tareas
  // pendientes por sincronizar?
  // quiero que una sola vez se inicie

  // ahora tengo que reconocer el último momento en que se
  // sincronizó el repositorio local

  @override
  FutureOr<List<Note>> build() async {
    _remoteNotesRepository = ref.watch(remoteNotesRepositoryProvider);
    _localNotesRepository = ref.watch(localNotesRepositoryProvider);

    _createNotesRepository = ref.watch(createNotesRepositoryProvider);
    _updateNotesRepository = ref.watch(updateNotesRepositoryProvider);
    _deleteNotesRepository = ref.watch(deleteNotesRepositoryProvider);

    // tienes que hacerlo así, cada vez que inicia la app, se iniicia éste chequeo
    _timer ??= Timer.periodic(Duration(seconds: 5), (timer) async {
      if (await hasNotesPendingForSync()) {
        // try {
        await _lock.synchronized(() async => await syncPendingNotes());
        // await syncPendingNotes();

        // await _syncLocalRepository();
        // await _fetchNotes();

        // } on DioException  {
        //   //
        // }
      } else {
        if (await hasUpdate()) {
          try {
            await _lock.synchronized(() async => await _syncLocalRepository());
            // await _syncLocalRepository();
            await _fetchNotes();
          } on DioException catch (e) {
            // no haces nada, problemas con el internet
            debugPrint(e.message ?? 'error en la conexión');
          }
        }
      }
    });

    try {
      await _syncLocalRepository();
    } on DioException catch (e) {
      // no haces nada
      debugPrint(e.message ?? 'error en la conexión');
    }

    return await getAllNotes();
  }

  Future<bool> hasUpdate() async {
    try {
      final remoteRepositoryLastUpdate =
          await _remoteNotesRepository.getLastUpdate();
      final localRepositoryLastUpdate =
          await _localNotesRepository.getLastUpdate();

      return remoteRepositoryLastUpdate > localRepositoryLastUpdate;
    } on DioException {
      return false;
    }
  }

  Future<void> syncPendingNotes() async {
    // if (_isBusy) return;
    // _isBusy = true;
    try {
      await _syncNotesCreated();
      await _syncNotesUpdated();
      await _syncNotesDeleted();
      // todo después que se sincroniza todo
      // await _syncLocalRepository();
      //await _fetchNotes();

      // todo setear momento de sincronización
    } on DioException {
      // _isBusy = false;
      //debugPrint(e.message ?? 'Problema de conexión');
      // no me interesa hacer nada porque simplemente no hay conexión a internet
    }
    // _isBusy = false; // creo que podría usr finally pero no estoy seguro
  }

  Future<void> _syncNotesCreated() async {
    final List<Note> notes = await _createNotesRepository.getAllNotes();
    if (notes.isEmpty) return;
    await _remoteNotesRepository.addAll(notes);
    await _createNotesRepository.deleteAll(notes);
  }

  Future<void> _syncNotesUpdated() async {
    final List<Note> notes = await _updateNotesRepository.getAllNotes();
    if (notes.isEmpty) return;
    await _remoteNotesRepository.updateAll(notes);
    await _updateNotesRepository.deleteAll(notes);
  }

  Future<void> _syncNotesDeleted() async {
    final List<Note> notes = await _deleteNotesRepository.getAllNotes();
    if (notes.isEmpty) return;
    await _remoteNotesRepository.deleteAll(notes);
    await _deleteNotesRepository.deleteAll(notes);
  }

  Future<void> _syncLocalRepository() async {
    // if (_isBusy) return;
    // _isBusy = true;
    try {
      // debo llamar a todas las notas en la nube
      // además del tiempo de sincronización y guardar ese registro
      // el momento de sincronización me lo dice la tabla remota
      final List<Note> remoteNotes = await _remoteNotesRepository.getAllNotes();
      // guardamos esas notas
      await _localNotesRepository.clear();
      await _localNotesRepository.addAll(remoteNotes);

      final lastUpdate = await _remoteNotesRepository.getLastUpdate();
      await _localNotesRepository.setLastUpdate(lastUpdate);

      // _fetchNotes();
    } on DioException {
      // _isBusy = false;
      rethrow;
    }
    // _isBusy = false;
  }

  Future<void> add(Note note) async {
    // Set the state to loading
    state = const AsyncValue.loading();

    //final notas = await _localNotesRepository.getAllNotes();

    final id = await _localNotesRepository.add(note);

    final noteCopy = note.copyWith(id: id);

    await agregaANotesPendientesPorCrear(noteCopy); // lo agrego al repositorio
    // de tareas pendientes por agregar al repositorio remoto

    // await _localNotesRepository.clear();
    // await _localNotesRepository.addAll([...notas, noteCopy]);

    await _fetchNotes();
  }

  Future<void> agregaANotesPendientesPorCrear(Note note) async {
    await _createNotesRepository.add(note); // lo agrego al repositorio
  }

  Future<void> agregaANotesPendientesPorActualizar(Note note) async {
    // imagínate que se creó la nota estando sin conexión
    // y lo quieren actualizar
    if (isLocalNote(note)) {
      // todavía no se a sincronizado
      await _createNotesRepository.update(note);
    } else {
      // ya es una nota que está sincronizada
      // pero recuerda que estás sin conexión
      final noteAux = await _updateNotesRepository.getById(note.id!);
      if (noteAux != null) {
        // significa que ya la había agregado
        // a pendiente por actualizar
        await _updateNotesRepository.update(note);
      } else {
        // es null, es decir no existe, entonces la agregamos
        await _updateNotesRepository.add(note); // lo agrego al repositorio
      }
    }
  }

  bool isLocalNote(Note note) {
    // me interesa saber si es una nota local
    // no se ha sincronizado aún
    return note.id!
        .toString()
        .startsWith(_localNotesRepository.getPrefixIndex());
  }

  Future<void> agregaANotesPendientesPorEliminar(Note note) async {
    // aquí puedo entender varias cosas
    // se creó, se modificó y ahora quiere eliminarse
    if (isLocalNote(note)) {
      //
      // eliminala de notas pendientes por crear
      // y de update, si no existe no pasa nada, solo se regresa un null
      // que igual no importa
      await _createNotesRepository.delete(note);
      await _updateNotesRepository.delete(note);
      //
    } else {
      // no es una nota local
      // entonces la agregamos al repositorio para eliminar
      await _deleteNotesRepository.add(note); // lo agrego al repositorio
    }
  }

  Future<bool> notesCreatedPendingForSync() async {
    final notas = await _createNotesRepository.getAllNotes();
    return notas.isNotEmpty;
  }

  Future<bool> notesUpdatedPendingForSync() async {
    final notas = await _updateNotesRepository.getAllNotes();
    return notas.isNotEmpty;
  }

  Future<bool> notesDeletedPendingForSync() async {
    final notas = await _deleteNotesRepository.getAllNotes();
    return notas.isNotEmpty;
  }

  Future<bool> hasNotesPendingForSync() async {
    final notesCreated = await notesCreatedPendingForSync();
    final notesUpdated = await notesUpdatedPendingForSync();
    final notesDeleted = await notesDeletedPendingForSync();
    return notesCreated || notesUpdated || notesDeleted;
  }

  Future<void> _addAll(List<Note> notes) async {
    // Set the state to loading
    state = const AsyncValue.loading();

    await _localNotesRepository.addAll(notes);
    await _fetchNotes();
  }

  Future<void> _updateAll(List<Note> notes) async {
    // Set the state to loading
    state = const AsyncValue.loading();

    await _localNotesRepository.updateAll(notes);
    await _fetchNotes();
  }

  Future<void> _deleteAll(List<Note> notes) async {
    // Set the state to loading
    state = const AsyncValue.loading();

    await _localNotesRepository.deleteAll(notes);
    await _fetchNotes();
  }

  Future<void> updateNote(Note note) async {
    // Set the state to loading
    state = const AsyncValue.loading();

    await _localNotesRepository.update(note);

    await agregaANotesPendientesPorActualizar(note);
    // lo agrego al repositorio de notas por actualizar
    await _fetchNotes();
  }

  Future<void> toggle(Note note) async {
    // state = const AsyncValue.loading();

    final noteToggled = note.copyWith(isCompleted: !note.isCompleted);
    await _localNotesRepository.update(noteToggled);

    await agregaANotesPendientesPorActualizar(noteToggled);
    // lo agrego al repositorio de notas por actualizar
    await _fetchNotes();
  }

  Future<List<Note>> getAllNotes() async {
    // esto no debe actualizar ningún cambio de estado ojo
    final listNotes = await _localNotesRepository.getAllNotes();
    return listNotes;
    // return await _fetchNotes();
  }

  FutureOr<Note?> getNoteById(int id) async {
    // esto no debe actualizar ningún cambio de estado ojo
    return await _localNotesRepository.getById(id);
  }

  Future<void> delete(Note note) async {
    // Set the state to loading
    state = const AsyncValue.loading();

    await _localNotesRepository.delete(note);

    await agregaANotesPendientesPorEliminar(note);
    await _fetchNotes();
  }

  Future<void> _clear() async {
    // todo después tengo que modificar éste código, porque quiero que borre todo solo cuando
    // vaya a sincronizarse
    // Set the state to loading
    state = const AsyncValue.loading();

    await _localNotesRepository.clear();
    await _fetchNotes();
  }
}
