import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '/presentation/screens/screens.dart';
import 'package:isar_example/domain/entities/note.dart';
import 'package:isar_example/presentation/providers/notes/notes_provider.dart';

void showCustomSnackbar(BuildContext context,
    {required Widget content, Duration duration = const Duration(seconds: 3)}) {
  ScaffoldMessenger.of(context).clearSnackBars();
  final snackbar = SnackBar(
    duration: duration,
    content: content,
    action: SnackBarAction(
      label: 'ok',
      onPressed: () {},
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackbar);
}

bool isLoading = true;

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
          if (isLoading) {
            showCustomSnackbar(context,
                content: const Text('Sincronizando, espere un momento...'));
            return;
          }
          context.push(
            EditScreen.path,
            extra: Note(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  List<Note>? _notesBackup;
  // bool _isLoading = true;

// @override
//   void initState() {

//     super.initState();
//   WidgetsBinding.instance
//         .addPostFrameCallback((_) => showSnackBar(context));
//   }

  // void showSnackBar(BuildContext context) {

  //   if (_isLoading) {
  //     const content = Row(
  //       children: [
  //         Text('Sincronizando...'),
  //         CircularProgressIndicator(),
  //       ],
  //     );
  //     showCustomSnackbar(context, content);
  //   } else {
  //     const content = Text('Sincronizado exitosamente! ;)');
  //     if (_notesBackup != null) {
  //       showCustomSnackbar(context, content,
  //           duration: const Duration(seconds: 3));
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final asyncNotes = ref.watch(asyncNotesProvider);
    final scrollNotesController = ScrollController();
    // ref.read(isLoadingProvider.notifier).state = true;
    return asyncNotes.when(
      data: (notes) {
        isLoading = false;
        _notesBackup = notes;

        return FadeInUp(
          duration: const Duration(milliseconds: 400),
          from: 50,
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: notes.length,
            controller: scrollNotesController,
            itemBuilder: (context, index) {
              final indice = (notes.length) - index - 1;
              final note = notes[indice];
              return NoteView(
                  note: note, scrollController: scrollNotesController);
            },
          ),
        );
      },
      error: (error, stackTrace) {
        isLoading = false;
        return Center(child: Text('Error: $error'));
      },
      loading: () {
        isLoading = true;
        if (_notesBackup == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return FadeInDown(
          duration: const Duration(milliseconds: 400),
          from: 50,
          child: Column(
            children: [
              const SizedBox(height: 2),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Sincronizando... '),
                  CircularProgressIndicator(),
                ],
              ),
              const SizedBox(height: 2),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: _notesBackup!.length,
                  controller: scrollNotesController,
                  itemBuilder: (context, index) {
                    final indice = (_notesBackup!.length) - index - 1;
                    final note = _notesBackup![indice];
                    return NoteView(
                      note: note,
                      scrollController: scrollNotesController,
                      isActive: false,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
      // loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}

void moveScrollNotes(ScrollController scrollNotesController) async {
  if (!scrollNotesController.hasClients) return;

  await Future.delayed(const Duration(milliseconds: 400));
  scrollNotesController.animateTo(0,
      duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
}

class NoteView extends ConsumerWidget {
  const NoteView({
    super.key,
    required this.note,
    required this.scrollController,
    this.isActive = true,
  });
  final Note note;
  final ScrollController scrollController;
  final bool? isActive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(note.id.toString()),
      onDismissed: (direction) async {
        await ref.read(asyncNotesProvider.notifier).delete(note);
        moveScrollNotes(scrollController);
      },
      child: Card(
        elevation: 3,
        child: ListTile(
          enabled: isActive!,
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
            context.push(
              EditScreen.path,
              extra: note,
            );
          },

          // trailing
          // trailing: IconButton(
          //     onPressed: () {
          //       ref.read(asyncNotesProvider.notifier).delete(note);
          //     },
          //     icon: const Icon(Icons.delete_forever)),
          leading: Checkbox(
            value: note.isCompleted,
            onChanged: isActive!
                ? (value) {
                    ref.read(asyncNotesProvider.notifier).toggle(note);
                  }
                : null,
          ),
        ),
      ),
    );
  }
}
