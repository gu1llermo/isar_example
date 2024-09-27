import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_example/domain/entities/note.dart';
import 'package:isar_example/infrastructure/repositories/note_repository_impl.dart';
import 'package:isar_example/presentation/providers/notes/notes_repository_provider.dart';

final asyncNotesProvider =
    AsyncNotifierProvider<NotesNotifier, List<Note>>(() => NotesNotifier());

class NotesNotifier extends AsyncNotifier<List<Note>> {
  late NoteRepositoryImpl _localNotesRepository;
  // late NoteRepositoryImpl _remoteNotesRepository;

  Future<List<Note>> _fetchNotes() async {
    return await getAllNotes();
  }

  @override
  FutureOr<List<Note>> build() async {
    _localNotesRepository = ref.watch(localNotesRepositoryProvider);
    // _remoteNotesRepository = ref.watch(remoteNotesRepositoryProvider);
    // print('Aquí');
    return await _fetchNotes();
  }

  Future<void> add(Note note) async {
    // Set the state to loading
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _localNotesRepository.add(note);
      return await _fetchNotes();
    });
  }

  Future<void> addAll(List<Note> notes) async {
    // Set the state to loading
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _localNotesRepository.addAll(notes);
      return await _fetchNotes();
    });
  }

  Future<void> updateNote(Note note) async {
    // Set the state to loading
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _localNotesRepository.update(note);
      return await _fetchNotes();
    });
  }

  Future<void> toggle(Note note) async {
    // state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final noteToggled = note.copyWith(isCompleted: !note.isCompleted);
      await _localNotesRepository.update(noteToggled);
      return await _fetchNotes();
    });
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
    state = await AsyncValue.guard(() async {
      await _localNotesRepository.delete(note);
      return await _fetchNotes();
    });
  }

  Future<void> clear() async {
    // Set the state to loading
    // state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _localNotesRepository.clear();
      return await _fetchNotes();
    });
  }
}
