import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:isar_example/domain/datasources/notes_datasource.dart';
import 'package:isar_example/domain/entities/note.dart';
import 'package:isar_example/infrastructure/mappers/note_mapper.dart';
import 'package:isar_example/infrastructure/models/google_sheets/add_note_response.dart';
import 'package:isar_example/infrastructure/models/google_sheets/get_all_notes_response.dart';

class NoteGoogleSheetsDatasource extends NotesDatasource {
  final dio = Dio();
  final baseUrl =
      'https://script.google.com/macros/s/AKfycbzSHxr7oW8uUB2SStxdCNSQ7dssg2zzaOWNaJ1sJSL4qPkeW4G9zWJZpuAnZgT9wozC/exec';

  @override
  Future<bool> add(Note note) async {
    final response = await doPost({
      "comando": "addNote",
      "parametros": {
        "note": NoteMapper.entityToMap(note),
      }
    });
    if (response == null) {
      return false; // significa que no se guardó
    }

    //final addResponse = AddNoteResponse.fromMap(response.data);

    //final id = addResponse.data.id;

    return true;
  }

  @override
  Future<bool> delete(Note note) async {
    final response = await doPost({
      "comando": "deleteNote",
      "parametros": {
        "note": NoteMapper.entityToMap(note),
      }
    });
    if (response == null) {
      return false; // significa que no se guardó
    }

    //final addResponse = AddNoteResponse.fromMap(response.data);

    //final id = addResponse.data.id;

    return true;
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
      return [];
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
  Future<Note?> getById(int id) {
    // TODO: implement getById
    throw UnimplementedError();
  }

  @override
  Future<bool> update(Note note) async {
    final response = await doPost({
      "comando": "updateNote",
      "parametros": {
        "note": NoteMapper.entityToMap(note),
      }
    });
    if (response == null) {
      return false; // significa que no se guardó
    }

    //final addResponse = AddNoteResponse.fromMap(response.data);

    //final id = addResponse.data.id;

    return true;
  }
}
