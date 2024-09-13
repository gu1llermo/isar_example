// To parse this JSON data, do
//
//     final getNoteResponse = getNoteResponseFromJson(jsonString);

import 'package:isar_example/infrastructure/models/google_sheets/note_google_sheets.dart';

class GetNoteResponse {
  final bool hasError;
  final Data data;
  final int code;
  final String msg;

  GetNoteResponse({
    required this.hasError,
    required this.data,
    required this.code,
    required this.msg,
  });

  factory GetNoteResponse.fromJson(Map<String, dynamic> json) =>
      GetNoteResponse(
        hasError: json["hasError"],
        data: Data.fromJson(json["data"]),
        code: json["code"],
        msg: json["msg"],
      );

  Map<String, dynamic> toJson() => {
        "hasError": hasError,
        "data": data.toJson(),
        "code": code,
        "msg": msg,
      };
}

class Data {
  final NoteGoogleSheets? note;

  Data({
    required this.note,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        note: NoteGoogleSheets.fromMap(json["note"]),
      );

  Map<String, dynamic> toJson() => {
        "note": note?.toMap(),
      };
}
