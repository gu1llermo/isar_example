import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  Future<void> _fetchNotes() async {
    state = await AsyncValue.guard(() async {
      return await getAllNotes();
    });
  }

  @override
  FutureOr<List<Note>> build() async {
    _remoteNotesRepository = ref.watch(remoteNotesRepositoryProvider);
    // _localNotesRepository = ref.watch(remoteNotesRepositoryProvider);
    _localNotesRepository = ref.watch(localNotesRepositoryProvider);

    _createNotesRepository = ref.watch(createNotesRepositoryProvider);
    _updateNotesRepository = ref.watch(updateNotesRepositoryProvider);
    _deleteNotesRepository = ref.watch(deleteNotesRepositoryProvider);

    return await getAllNotes();
  }

  Future<void> add(Note note) async {
    // Set the state to loading
    state = const AsyncValue.loading();
    await _localNotesRepository.add(note);
    _fetchNotes();
    // aquí debería primero intentar agregar esa nota
    // al repositorio remoto
    // en acso que falle se agrega a la lista de tareas
    // pendientes por agregar
    // cómo puedo agregar ésta nota al directorio remoto?

    // agrega a tareas pendientes por crear en el repositorio remoto
    //_createNotesRepository.add(note); // ya se agregó al repositorio
    // de tareas pendientes por agregar al repositorio remoto

    //debugPrint('Hola');
  }

  Future<void> addAll(List<Note> notes) async {
    // Set the state to loading
    state = const AsyncValue.loading();

    await _localNotesRepository.addAll(notes);
    _fetchNotes();
  }

  Future<void> updateAll(List<Note> notes) async {
    // Set the state to loading
    state = const AsyncValue.loading();

    await _localNotesRepository.updateAll(notes);
    _fetchNotes();
  }

  Future<void> deleteAll(List<Note> notes) async {
    // Set the state to loading
    state = const AsyncValue.loading();

    await _localNotesRepository.deleteAll(notes);
    _fetchNotes();
  }

  Future<void> updateNote(Note note) async {
    // Set the state to loading
    state = const AsyncValue.loading();

    await _localNotesRepository.update(note);
    _fetchNotes();
  }

  Future<void> toggle(Note note) async {
    // state = const AsyncValue.loading();

    final noteToggled = note.copyWith(isCompleted: !note.isCompleted);
    await _localNotesRepository.update(noteToggled);
    _fetchNotes();
  }

  FutureOr<List<Note>> getAllNotes() async {
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
    // state = const AsyncValue.loading();

    await _localNotesRepository.delete(note);
    _fetchNotes();
  }

  Future<void> clear() async {
    // Set the state to loading
    // state = const AsyncValue.loading();

    await _localNotesRepository.clear();
    _fetchNotes();
  }
}
