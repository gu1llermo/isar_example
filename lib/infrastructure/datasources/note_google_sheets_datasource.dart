import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';
import 'package:isar_example/domain/datasources/notes_datasource.dart';
import 'package:isar_example/domain/entities/note.dart';
import 'package:isar_example/infrastructure/mappers/note_mapper.dart';
import 'package:isar_example/infrastructure/models/google_sheets/add_note_response.dart';
import 'package:isar_example/infrastructure/models/google_sheets/get_all_notes_response.dart';
import 'package:isar_example/infrastructure/models/google_sheets/get_note_response.dart';

class NoteGoogleSheetsDatasource extends NotesDatasource {
  final dio = Dio();
  final baseUrl =
      'https://script.google.com/macros/s/AKfycbwdurgujwVbsqgzqBWNRAIIu-G2Ix3kREiEdFjj5yckP2XKAP436oWyouzB_0XEhoaV/exec';

  int _lastUpdateBackup = 0;
  static const String _prefixIndex = '1';

  @override
  Future<int> add(Note note) async {
    final response = await doPost({
      "comando": "addNote",
      "parametros": {
        "note": NoteMapper.entityToMap(note),
      }
    });
    // if (response == null) {
    //   return -1; // significa que no se guardó
    // }
    try {
      final addResponse = AddNoteResponse.fromMap(response!.data);
      final id = addResponse.data.id;
      return id;
    } on Exception {
      rethrow;
    }
  }

  @override
  String getPrefixIndex() {
    return _prefixIndex;
  }

  @override
  Future<int> getLastUpdate() async {
    final response = await doPost({
      "comando": "getLastUpdate",
    });

    if (response! is String) {
      // es porque hubo un error en la recepción
      return _lastUpdateBackup;
    } else {
      final addResponse = AddNoteResponse.fromMap(response!.data);

      final lastUpdate = addResponse.data.lastUpdate!;
      _lastUpdateBackup = lastUpdate;
      return lastUpdate;
    }
    // try {
    //   final addResponse = AddNoteResponse.fromMap(response!.data);

    //   final lastUpdate = addResponse.data.lastUpdate!;
    //   _lastUpdateBackup = lastUpdate;
    //   return lastUpdate;
    // } on Exception {
    //   return _lastUpdateBackup;
    // }
  }

  @override
  Future<int> delete(Note note) async {
    final response = await doPost({
      "comando": "deleteNote",
      "parametros": {
        "note": NoteMapper.entityToMap(note),
      }
    });

    try {
      final addResponse = AddNoteResponse.fromMap(response!.data);
      final id = addResponse.data.id;
      return id;
    } on Exception {
      rethrow;
    }
  }

  Future<Response<dynamic>?> doPost(Map<String, dynamic> body) async {
    final bodyJson = jsonEncode(body);

    Response<dynamic>? response;
    try {
      response = await dio.post(
        baseUrl,
        options: Options(
          headers: {HttpHeaders.contentTypeHeader: "text/plain"},
          // headers: {HttpHeaders.contentTypeHeader: "application/json"},//
          // tuve que cambiar de Json a text/plain por problemas de cors en flutter wep
        ),
        data: bodyJson,
      );
    } on DioException catch (e) {
      // Handle redirect with code 302
      if (e.response?.statusCode == 302) {
        final url = e.response?.headers['location']!.first;
        response = await redirectDoGet(url!);
      } else {
        rethrow;
      }
    }
    return response;
  }

  Future<Response<dynamic>?> redirectDoGet(String url) async {
    Response<dynamic>? response;

    response = await dio.get(url);

    return response;
  }

  @override
  Future<List<Note>> getAllNotes() async {
    final response = await doPost({"comando": "getAllNotes"});

    try {
      final notesResponse = GetAllNotesResponse.fromJson(response!.data);
      final List<Note> notes = notesResponse.data.notes
          .map(NoteMapper.noteGoogleSheetsToEntity)
          .toList();
      return notes;
    } on Exception {
      rethrow;
    }
  }

  @override
  Future<Note?> getById(int id) async {
    final response = await doPost({
      "comando": "getNoteById",
      "parametros": {
        "id": id,
      }
    });

    try {
      final noteResponse = GetNoteResponse.fromJson(response!.data);
      final noteGoogleSheet = noteResponse.data.note;
      if (noteGoogleSheet == null) {
        return null; // es que no consiguió la nota
      }
      final note = NoteMapper.noteGoogleSheetsToEntity(noteGoogleSheet);
      return note;
    } on Exception {
      rethrow;
    }
  }

  @override
  Future<int> update(Note note) async {
    final response = await doPost({
      "comando": "updateNote",
      "parametros": {
        "note": NoteMapper.entityToMap(note),
      }
    });

    try {
      final addResponse = AddNoteResponse.fromMap(response!.data);
      final id = addResponse.data.id;
      return id;
    } on Exception {
      rethrow;
    }
  }

  @override
  Future<void> addAll(List<Note> notes) async {
    await doPost({
      "comando": "addAll",
      "parametros": NoteMapper.listEntityToMap(notes),
    });
  }

  @override
  Future<void> deleteAll(List<Note> notes) async {
    await doPost({
      "comando": "deleteAll",
      "parametros": NoteMapper.listEntityToMap(notes),
    });
  }

  @override
  Future<void> updateAll(List<Note> notes) async {
    await doPost({
      "comando": "updateAll",
      "parametros": NoteMapper.listEntityToMap(notes),
    });
  }

  @override
  Future<void> clear() async {
    await doPost({
      "comando": "clearDb",
    });

    // if (response == null) {
    //   debugPrint('Pasé por aquí');
    //   return;
    //   //return -1; // significa que no se guardó
    // }

    // final addResponse = AddNoteResponse.fromMap(response.data);

    // final id = addResponse.data.id;

    // return id;
  }

  @override
  Future<void> setLastUpdate(int lastUpdate) {
    throw 'No deberías implementar ésta función de setLastUpdate en remoteRepository';
  }
}
