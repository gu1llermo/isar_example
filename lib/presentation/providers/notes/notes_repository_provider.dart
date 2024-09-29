import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_example/infrastructure/datasources/note_google_sheets_datasource.dart';
import 'package:isar_example/infrastructure/repositories/note_repository_impl.dart';

import '../../../infrastructure/datasources/note_sembast_datasource.dart';

final localNotesRepositoryProvider =
    Provider((ref) => NoteRepositoryImpl(NoteSembastDatasource(
          nameStore: 'note_sembast_store',
          nameDb: 'notes.db',
        )));

final createNotesRepositoryProvider =
    Provider((ref) => NoteRepositoryImpl(NoteSembastDatasource(
          nameStore: 'create_store',
          nameDb: 'create.db',
        )));

final updateNotesRepositoryProvider =
    Provider((ref) => NoteRepositoryImpl(NoteSembastDatasource(
          nameStore: 'update_store',
          nameDb: 'update.db',
        )));

final deleteNotesRepositoryProvider =
    Provider((ref) => NoteRepositoryImpl(NoteSembastDatasource(
          nameStore: 'delete_store',
          nameDb: 'delete.db',
        )));

final remoteNotesRepositoryProvider =
    Provider((ref) => NoteRepositoryImpl(NoteGoogleSheetsDatasource()));

// me parece que cuando cambia de datasource debería hacer otras cosas más

// final datasourceProvider = StateProvider<NotesDatasource>((ref) {
//   return NoteIsarDatasource(); // es el valor de su estado inicial
// });

// final datasourceProvider =
//     NotifierProvider<DatasourceNotifier, NotesDatasource>(
//         () => DatasourceNotifier());

// class DatasourceNotifier extends Notifier<NotesDatasource> {
//   @override
//   NotesDatasource build() {
//     return NoteGoogleSheetsDatasource();
//     // return NoteSembastDatasource();
//     // return NoteIsarDatasource();
//   }

// }
