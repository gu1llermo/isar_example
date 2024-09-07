import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_example/domain/entities/note.dart';
import 'package:isar_example/presentation/providers/notes/notes_provider.dart';

class EditScreen extends StatelessWidget {
  const EditScreen({super.key, required this.note});
  final Note note;

  static const String path = '/edit';
  static const String name = 'edit_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: EditView(note: note),
    );
  }
}

class EditView extends ConsumerStatefulWidget {
  const EditView({super.key, required this.note});
  final Note note;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EditViewState();
}

class _EditViewState extends ConsumerState<EditView> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  bool hasChanged() {
    if (_titleController.text == widget.note.title &&
        _contentController.text == widget.note.content) {
      return false;
    }

    return true;
  }

  bool titleChanged() {
    return _titleController.text != widget.note.title;
  }

  bool contentChanged() {
    return _contentController.text != widget.note.content;
  }

  bool isEmptyBothFields() {
    return _titleController.text.trim().isEmpty &&
        _contentController.text.trim().isEmpty;
  }

  bool isNewNote(Note note) {
    return note.title.isEmpty && note.content.isEmpty;
  }

  void procesaBack(Note note) {
    if (isEmptyBothFields() && hasChanged()) {
      // quiere decir que eliminaron el contenido de la nota
      ref.read(asyncNotesProvider.notifier).delete(note);
      return;
    }
    if (!hasChanged()) {
      return;
    }
    // si llega aquí es porque hubo un cambio
    String title = note.title;
    String content = note.content;
    if (titleChanged()) {
      title = _titleController.text;
    }
    if (contentChanged()) {
      content = _contentController.text;
    }
    if (isNewNote(note)) {
      ref
          .read(asyncNotesProvider.notifier)
          .add(note.copyWith(title: title, content: content));
    } else {
      ref
          .read(asyncNotesProvider.notifier)
          .updateNote(note.copyWith(title: title, content: content));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          TextField(
            canRequestFocus: true,
            autofocus: true,
            style: const TextStyle(fontSize: 20),
            decoration: const InputDecoration(hintText: 'Título'),
            controller: _titleController,
            textInputAction: TextInputAction.next,
            onTapOutside: (event) {
              procesaBack(widget.note);
            },
          ),
          Expanded(
            child: TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                hintText: 'Nota',
                border: InputBorder.none,
              ),
              keyboardType: TextInputType.multiline,
              maxLines: null,
              expands: true,
              onTapOutside: (event) {
                procesaBack(widget.note);
              },
            ),
          ),
        ],
      ),
    );
  }
}
