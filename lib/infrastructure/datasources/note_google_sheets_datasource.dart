import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:isar_example/domain/datasources/notes_datasource.dart';
import 'package:isar_example/domain/entities/note.dart';
import 'package:isar_example/infrastructure/mappers/note_mapper.dart';
import 'package:isar_example/infrastructure/models/google_sheets/add_note_response.dart';
import 'package:isar_example/infrastructure/models/google_sheets/get_all_notes_response.dart';
import 'package:isar_example/infrastructure/models/google_sheets/get_note_response.dart';
import 'package:isar_example/infrastructure/models/google_sheets/google_sheets_exception.dart';

class NoteGoogleSheetsDatasource extends NotesDatasource {
  final dio = Dio();
  final baseUrl =
      'https://script.google.com/macros/s/AKfycbw_2zzgn0t0xEV7sgoeSYGrU09kRaMW8SJI5OC76Y4GItuDXzD-I9TntCT_RdVLGgiA/exec';

  @override
  Future<int> add(Note note) async {
    final response = await doPost({
      "comando": "addNote",
      "parametros": {
        "note": NoteMapper.entityToMap(note),
      }
    });
    if (response == null) {
      return -1; // significa que no se guardó
    }

    final addResponse = AddNoteResponse.fromMap(response.data);

    final id = addResponse.data.id;

    return id;
  }

  @override
  Future<int> delete(Note note) async {
    final response = await doPost({
      "comando": "deleteNote",
      "parametros": {
        "note": NoteMapper.entityToMap(note),
      }
    });
    if (response == null) {
      return -1; // significa que no se guardó
    }

    final addResponse = AddNoteResponse.fromMap(response.data);

    final id = addResponse.data.id;

    return id;
  }

  // @override
  // Future<List<Note>> getAllNotes() async {
  //   Response<dynamic>? response;
  //   try {
  //     response = await dio.get(
  //         "https://script.google.com/macros/s/AKfycby4PAfuY7tWghKPIJKa1QJ_phceHDUNbWtByh-d8QP4c3Qun1gGBNwElPaP-AqcxfxP/exec",
  //         queryParameters: {"comando": "getAllNotes"});
  //   } on DioException catch (e) {
  //     // no hace nada
  //     response = null;
  //   }
  //   if (response == null) {
  //     return [];
  //   }

  //   final notesResponse = NotesResponse.fromJson(response.data);

  //   final List<Note> notes = notesResponse.data.notes
  //       .map(NoteMapper.noteGoogleSheetsToEntity)
  //       .toList();

  //   return notes;
  // }

  Future<Response<dynamic>?> doPost(Map<String, dynamic> body) async {
    final bodyJson = jsonEncode(body);
    Response<dynamic>? response;
    try {
      response = await dio.post(baseUrl,
          options: Options(
            headers: {HttpHeaders.contentTypeHeader: "application/json"},
          ),
          data: bodyJson);
    } on DioException catch (e) {
      /// Handle redirect with code 302
      if (e.response?.statusCode == 302) {
        final url = e.response?.headers['location']!.first;
        response = await dio.get(url!);
      }
    }
    return response;
  }

  @override
  Future<List<Note>> getAllNotes() async {
    final response = await doPost({"comando": "getAllNotes"});

    if (response == null) {
      throw 'No hay conexión a internet';
    }

    final notesResponse = GetAllNotesResponse.fromJson(response.data);

    final List<Note> notes = notesResponse.data.notes
        .map(NoteMapper.noteGoogleSheetsToEntity)
        .toList();

    return notes;
  }

  // @override
  // Future<List<Note>> getAllNotes() async {
  //   final bodyJson = jsonEncode({"comando": "getAllNotes"});
  //   Response<dynamic>? response;
  //   try {
  //     response = await dio.post(
  //         "https://script.google.com/macros/s/AKfycbwppOxEKIqUFVI4oDb-TpscfNdnza41gvJtTrgQfITNDMSZKDTZRLGl5k3lL70-l3NG/exec",
  //         options: Options(
  //           headers: {HttpHeaders.contentTypeHeader: "application/json"},
  //         ),
  //         data: bodyJson);
  //   } on DioException catch (e) {
  //     /// Handle redirect with code 302
  //     if (e.response?.statusCode == 302) {
  //       final url = e.response?.headers['location']!.first;
  //       response = await dio.get(url!);
  //     }
  //   }
  //   if (response == null) {
  //     return [];
  //   }

  //   final notesResponse = NotesResponse.fromJson(response.data);

  //   final List<Note> notes = notesResponse.data.notes
  //       .map(NoteMapper.noteGoogleSheetsToEntity)
  //       .toList();

  //   return notes;
  // }

  @override
  Future<Note?> getById(int id) async {
    final response = await doPost({
      "comando": "getNoteById",
      "parametros": {
        "id": id,
      }
    });

    if (response == null) {
      throw 'No hay conexión a internet';
    }

    final noteResponse = GetNoteResponse.fromJson(response.data);

    final noteGoogleSheet = noteResponse.data.note;
    if (noteGoogleSheet == null) {
      return null;
    }

    final note = NoteMapper.noteGoogleSheetsToEntity(noteGoogleSheet);

    return note;
  }

  @override
  Future<int> update(Note note) async {
    final response = await doPost({
      "comando": "updateNote",
      "parametros": {
        "note": NoteMapper.entityToMap(note),
      }
    });
    if (response == null) {
      return -1; // significa que no se guardó
    }

    final addResponse = AddNoteResponse.fromMap(response.data);

    final id = addResponse.data.id;

    return id;
  }
}
