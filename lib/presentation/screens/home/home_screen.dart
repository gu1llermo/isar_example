import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
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

final notasPruebas = <Note>[
  Note(title: 'Hola', id: 21),
  Note(title: 'Mundo', id: 22),
];
final notasPruebasUpdate = <Note>[
  Note(title: 'Hello', id: 21),
  Note(title: 'World', id: 22),
];

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const String path = '/';
  static const String name = 'home_screen';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Todo example'),
      ),
      body: const HomeView(),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'add',
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
          // const SizedBox(height: 10),
          // FloatingActionButton(
          //   heroTag: 'clear',
          //   onPressed: () {
          //     if (isLoading) {
          //       showCustomSnackbar(context,
          //           content: const Text('Sincronizando, espere un momento...'));
          //       return;
          //     }
          //     ref.read(asyncNotesProvider.notifier).clear();
          //   },
          //   child: const Icon(Icons.delete_forever),
          // ),
          // const SizedBox(height: 10),
          // FloatingActionButton(
          //   heroTag: 'addAll', // todo addAll
          //   onPressed: () {
          //     if (isLoading) {
          //       showCustomSnackbar(context,
          //           content: const Text('Sincronizando, espere un momento...'));
          //       return;
          //     }
          //     ref.read(asyncNotesProvider.notifier).addAll(notasPruebas);
          //   },
          //   child: const Icon(Icons.add_a_photo_outlined),
          // ),
          // const SizedBox(height: 10),
          // FloatingActionButton(
          //   heroTag: 'updateAll', // todo updateAll
          //   onPressed: () {
          //     if (isLoading) {
          //       showCustomSnackbar(context,
          //           content: const Text('Sincronizando, espere un momento...'));
          //       return;
          //     }
          //     ref
          //         .read(asyncNotesProvider.notifier)
          //         .updateAll(notasPruebasUpdate);
          //   },
          //   child: const Icon(Icons.update),
          // ),
          // const SizedBox(height: 10),
          // FloatingActionButton(
          //   heroTag: 'deleteAll', // todo deletAll
          //   onPressed: () {
          //     if (isLoading) {
          //       showCustomSnackbar(context,
          //           content: const Text('Sincronizando, espere un momento...'));
          //       return;
          //     }
          //     ref.read(asyncNotesProvider.notifier).deleteAll(notasPruebas);
          //   },
          //   child: const Icon(Icons.delete_sweep_rounded),
          // ),
        ],
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

        return FadeInDown(
          duration: const Duration(milliseconds: 600),
          from: 50,
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80, left: 5, right: 5),
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
        // debugPrint(stackTrace.toString());
        isLoading = false;

        return Center(child: Text('Error: $error'));
      },
      loading: () {
        isLoading = true;
        if (_notesBackup == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return FadeInUp(
          duration: const Duration(milliseconds: 600),
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

  String convertTimeStamp(int timestamp) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final formatter = DateFormat('dd-MM-yyyy HH:mm:ss');
    final formattedTimeStamp = formatter.format(dateTime);
    return formattedTimeStamp;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final timeStamp = convertTimeStamp(note.timeStamp!);

    return Dismissible(
      key: ValueKey(note.id.toString()),
      onDismissed: (direction) async {
        await ref.read(asyncNotesProvider.notifier).delete(note);
      },
      child: Card(
        elevation: 3,
        child: ListTile(
          enabled: isActive!,
          title: Text(
            note.title,
            // '${note.id}.- ${note.title}',
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
          //   onPressed: () {},
          //   icon: const Badge(
          //     label: Text('Offline'),
          //     backgroundColor: Colors.orangeAccent,
          //     textColor: Colors.black87,
          //     child: Icon(Icons.wifi),
          //   ),
          // ),
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
