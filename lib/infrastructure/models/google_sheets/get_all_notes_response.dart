// To parse this JSON data, do
//
//     final googleSheetsResponse = googleSheetsResponseFromJson(jsonString);

import 'package:isar_example/infrastructure/models/google_sheets/note_google_sheets.dart';

class GetAllNotesResponse {
  final bool hasError;
  final Data data;
  final int code;
  final String msg;

  GetAllNotesResponse({
    required this.hasError,
    required this.data,
    required this.code,
    required this.msg,
  });

  factory GetAllNotesResponse.fromJson(Map<String, dynamic> json) =>
      GetAllNotesResponse(
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
  final List<NoteGoogleSheets> notes;

  Data({
    required this.notes,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        notes: List<NoteGoogleSheets>.from(
            json["notes"].map((x) => NoteGoogleSheets.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "notes": List<dynamic>.from(notes.map((x) => x.toJson())),
      };
}
