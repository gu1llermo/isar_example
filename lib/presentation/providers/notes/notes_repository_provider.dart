import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_example/domain/datasources/notes_datasource.dart';
import 'package:isar_example/infrastructure/datasources/note_isar_datasource.dart';
import 'package:isar_example/infrastructure/repositories/note_repository_impl.dart';

final notesRepositoryProvider = Provider(
  (ref) {
    final datasource = ref.watch(datasourceProvider);

    final notesRepository = NoteRepositoryImpl(datasource);

    return notesRepository;
  },
);

// me parece que cuando cambia de datasource debería hacer otras cosas más

// final datasourceProvider = StateProvider<NotesDatasource>((ref) {
//   return NoteIsarDatasource(); // es el valor de su estado inicial
// });

final datasourceProvider =
    NotifierProvider<DatasourceNotifier, NotesDatasource>(
        () => DatasourceNotifier());

class DatasourceNotifier extends Notifier<NotesDatasource> {
  @override
  NotesDatasource build() {
    return NoteIsarDatasource();
  }

  void onlineMode() {}
  void offLineMode() {
    // pero antes de seleciconar creo que debería hacer sincronización ó algo así
    state = NoteIsarDatasource();
  }
}
