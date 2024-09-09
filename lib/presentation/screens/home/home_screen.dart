import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '/presentation/screens/screens.dart';
import 'package:isar_example/domain/entities/note.dart';
import 'package:isar_example/presentation/providers/notes/notes_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const String path = '/';
  static const String name = 'home_screen';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todo example')),
      body: const HomeView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // final note = Note(title: 'Hola mundo');
          // ref.read(asyncNotesProvider.notifier).add(note);
          context.push<Note>(
            EditScreen.path,
            extra: Note(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncNotes = ref.watch(asyncNotesProvider);
    final scrollNotesController = ref.watch(scrollNotesProvider);

    return asyncNotes.when(
      data: (notes) => ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: notes.length,
        controller: scrollNotesController,
        itemBuilder: (context, index) {
          final indice = (notes.length) - index - 1;
          final note = notes[indice];
          return NoteView(note: note);
        },
      ),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}

class NoteView extends ConsumerWidget {
  const NoteView({super.key, required this.note});
  final Note note;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(
        note.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        note.content,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),

      onTap: () {
        context.push<Note>(
          EditScreen.path,
          extra: note,
        );
      },
      // trailing
      trailing: IconButton(
          onPressed: () {
            ref.read(asyncNotesProvider.notifier).delete(note);
          },
          icon: const Icon(Icons.delete_forever)),
      leading: Checkbox(
        value: note.isCompleted,
        onChanged: (value) {
          ref.read(asyncNotesProvider.notifier).toggle(note);
        },
      ),
    );
  }
}
