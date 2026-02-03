import 'dart:convert';
import 'package:http/http.dart' as http;

class NutritionService {
  static const String _apiKey = 'tlLjuHHslqn7jZWi9H2DhQ==zDRa0Bldl6jl8X2X';
  static const String _baseUrl = 'https://api.calorieninjas.com/v1/nutrition';

  static Future<Map<String, dynamic>?> fetchNutrition(String query) async {
    final uri = Uri.parse('$_baseUrl?query=$query');
    final response = await http.get(uri, headers: {'X-Api-Key': _apiKey});
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData['items'] != null && jsonData['items'].isNotEmpty) {
        return jsonData['items'][0];
      }
    }
    return null;
  }

  static Future<List<String>> getSuggestions(String query) async {
    if (query.trim().isEmpty) return [];
    final uri = Uri.parse('$_baseUrl?query=$query');
    final response = await http.get(uri, headers: {'X-Api-Key': _apiKey});
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List items = data['items'];
      return items
          .map<String>((item) => item['name'].toString())
          .toSet()
          .toList(); // Avoid duplicates
    } else {
      return [];
    }
  }
}
