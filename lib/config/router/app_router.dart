import 'package:go_router/go_router.dart';
import 'package:isar_example/domain/entities/note.dart';
import '/presentation/screens/screens.dart';

final appRouter = GoRouter(routes: [
  GoRoute(
    path: HomeScreen.path,
    name: HomeScreen.name,
    builder: (context, state) => const HomeScreen(),
  ),
  GoRoute(
    path: EditScreen.path,
    name: EditScreen.name,
    builder: (context, state) {
      Note note = state.extra as Note;
      return EditScreen(note: note);
    },
  ),
]);
