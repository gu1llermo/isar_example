import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_example/domain/entities/note.dart';
import 'package:isar_example/infrastructure/repositories/note_repository_impl.dart';
import 'package:isar_example/presentation/providers/notes/notes_repository_provider.dart';

final asyncNotesProvider =
    AsyncNotifierProvider<NotesNotifier, List<Note>>(() => NotesNotifier());

class NotesNotifier extends AsyncNotifier<List<Note>> {
  late NoteRepositoryImpl _notesRepository;

  Future<List<Note>> _fetchNotes() async {
    return await getAllNotes();
    // final listNotes = await _notesRepository.getAllNotes();
    // return listNotes;
  }

  @override
  FutureOr<List<Note>> build() async {
    _notesRepository = ref.watch(notesRepositoryProvider);
    // print('Aquí');
    return await _fetchNotes();
  }

  Future<void> add(Note note) async {
    // Set the state to loading
    // state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _notesRepository.add(note);
      return await _fetchNotes();
    });
  }

  Future<void> updateNote(Note note) async {
    // Set the state to loading
    // state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _notesRepository.update(note);
      return await _fetchNotes();
    });
  }

  Future<void> toggle(Note note) async {
    // state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final noteToggled = note.copyWith(isCompleted: !note.isCompleted);
      await _notesRepository.update(noteToggled);
      return await _fetchNotes();
    });
  }

  FutureOr<List<Note>> getAllNotes() async {
    // esto no debe actualizar ningún cambio de estado ojo
    final listNotes = await _notesRepository.getAllNotes();
    return listNotes;
    // return await _fetchNotes();
  }

  FutureOr<Note?> getNoteById(int id) async {
    // esto no debe actualizar ningún cambio de estado ojo
    return await _notesRepository.getById(id);
  }

  Future<void> delete(Note note) async {
    // Set the state to loading
    // state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _notesRepository.delete(note);
      return await _fetchNotes();
    });
  }
}
