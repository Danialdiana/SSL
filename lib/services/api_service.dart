import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class ApiService {
  static Future<Map<String, List<Map<String, String>>>> fetchDictionary() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:8080/videos'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data.map((key, value) => MapEntry(
              key,
              List<Map<String, String>>.from(
                  value.map((item) => Map<String, String>.from(item))),
            ));
      } else {
        debugPrint('Ошибка загрузки словаря: ${response.statusCode}');
        return {};
      }
    } catch (e) {
      debugPrint('Ошибка подключения: $e');
      return {};
    }
  }
}