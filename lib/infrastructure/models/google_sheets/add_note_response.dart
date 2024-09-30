// To parse this JSON data, do
//
//     final addNoteResponse = addNoteResponseFromJson(jsonString);

import 'dart:convert';

AddNoteResponse addNoteResponseFromJson(String str) =>
    AddNoteResponse.fromMap(json.decode(str));

String addNoteResponseToJson(AddNoteResponse data) => json.encode(data.toMap());

class AddNoteResponse {
  final bool hasError;
  final Data data;
  final int code;
  final String msg;

  AddNoteResponse({
    required this.hasError,
    required this.data,
    required this.code,
    required this.msg,
  });

  factory AddNoteResponse.fromMap(Map<String, dynamic> json) => AddNoteResponse(
        hasError: json["hasError"],
        data: Data.fromJson(json["data"]),
        code: json["code"],
        msg: json["msg"],
      );

  Map<String, dynamic> toMap() => {
        "hasError": hasError,
        "data": data.toJson(),
        "code": code,
        "msg": msg,
      };
}

class Data {
  final int id;
  final int? lastUpdate;

  Data({required this.id, this.lastUpdate});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"] ?? 0,
        lastUpdate: json["lastUpdate"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "lastUpdate": lastUpdate,
      };
}
