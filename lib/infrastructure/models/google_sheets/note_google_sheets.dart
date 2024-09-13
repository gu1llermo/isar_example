class NoteGoogleSheets {
  final int? id;
  final String title;
  final String content;
  final bool isCompleted;
  final int timeStamp;

  NoteGoogleSheets({
    required this.id,
    required this.title,
    required this.content,
    required this.isCompleted,
    required this.timeStamp,
  });

  factory NoteGoogleSheets.fromJson(Map<String, dynamic> json) {
    final id = json["id"];
    final title = json["title"];
    final content = json["content"];
    final isCompleted = json["isCompleted"];
    final timeStamp = json["timeStamp"];
    return NoteGoogleSheets(
        id: id,
        title: title,
        content: content,
        isCompleted: isCompleted,
        timeStamp: timeStamp);
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "content": content,
        "isComplete": isCompleted,
        "timeStamp": timeStamp,
      };
}
