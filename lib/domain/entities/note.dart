// así es como quiero que se maneje mis notas

class Note {
  final int? id;
  final String title;
  final String content;
  final bool isCompleted;

  Note({this.id, this.title = '', this.content = '', this.isCompleted = false});

  Note copyWith({int? id, String? title, String? content, bool? isCompleted}) =>
      Note(
          id: id ?? this.id,
          title: title ?? this.title,
          content: content ?? this.content,
          isCompleted: isCompleted ?? this.isCompleted);
}
