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
  // GET ROUTINES BY CREATOR ID
  // ===============================
  static Future<List<RoutineModel>> getRoutinesByCreator(
      String createdBy) async {
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

}
