import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/routine_model.dart';

class RoutineApi {
  // ===============================
  // IMPORTANT: Select your environment
  // ===============================

  // For EMULATOR:
  static const String baseUrl = "http://10.0.2.2:5000/chromabloom/routine";

  // For REAL PHONE:
  // static const String baseUrl ="http://172.28.0.221:5000/chromabloom/routine";  // <-- CHANGE IP IF NEEDED

  // ===============================
  // CREATE ROUTINE (POST)
  // ===============================
  static Future<bool> createRoutine(Map<String, dynamic> routineData) async {
    final url = Uri.parse("$baseUrl/create");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(routineData),
    );

    if (response.statusCode == 201) {
      return true; // success
    } else {
      // print backend error
      print("Create routine failed: ${response.body}");
      return false;
    }
  }

  // ===============================
  // GET ROUTINES BY CREATOR ID (GET)
  // ===============================
  static Future<List<RoutineModel>> getRoutinesByCreator(
    String createdBy,
  ) async {
    final url = Uri.parse("$baseUrl/getRoutine/$createdBy");

    final res = await http.get(url);

    print("GET URL: $url");
    print("STATUS: ${res.statusCode}");
    print("BODY: ${res.body}");

    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      final List list = decoded["data"] ?? [];

      return list.map((item) => RoutineModel.fromJson(item)).toList();
    } else {
      throw Exception("Failed to fetch routines: ${res.body}");
    }
  }

  // ===============================
  // GET ONE ROUTINE BY ID (GET)
  // ===============================
  static Future<RoutineModel> getRoutineById(String routineId) async {
    final url = Uri.parse("$baseUrl/getRoutineById/$routineId");

    final res = await http.get(url);

    print("GET ROUTINE BY ID URL: $url");
    print("STATUS: ${res.statusCode}");
    print("BODY: ${res.body}");

    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      return RoutineModel.fromJson(decoded["data"]);
    } else {
      throw Exception("Failed to fetch routine: ${res.body}");
    }
  }

  // ===============================
  // UPDATE ROUTINE (PUT)
  // ===============================
  static Future<bool> updateRoutine(
    String routineId,
    Map<String, dynamic> updateData,
  ) async {
    final url = Uri.parse("$baseUrl/updateRoutine/$routineId");

    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(updateData),
    );

    print("UPDATE URL: $url");
    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    return response.statusCode == 200;
  }

  // ===============================
  // Delete ROUTINE (DELETE)
  // ===============================
static Future<bool> deleteRoutine(String routineId) async {
  final url = Uri.parse("$baseUrl/deleteRoutine/$routineId");

  final res = await http.delete(url);

  print("DELETE URL: $url");
  print("STATUS: ${res.statusCode}");
  print("BODY: ${res.body}");

  if (res.statusCode == 200) {
    return true;
  } else {
    return false;
  }
}

}
