// así es como quiero que se maneje mis notas

import 'package:isar_example/config/helpers/tools.dart';

class Note {
  final int? id;
  final String title;
  final String content;
  final bool isCompleted;
  int? timeStamp;

  Note(
      {this.id,
      this.title = '',
      this.content = '',
      this.isCompleted = false,
      this.timeStamp}) {
    timeStamp = getTimeStamp();
  }

  Note copyWith({
    int? id,
    String? title,
    String? content,
    bool? isCompleted,
    int? timeStamp,
  }) =>
      Note(
        id: id ?? this.id,
        title: title ?? this.title,
        content: content ?? this.content,
        isCompleted: isCompleted ?? this.isCompleted,
        timeStamp: timeStamp ?? this.timeStamp,
      );
}
