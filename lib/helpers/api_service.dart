import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<Map<String, String>> getDrugSections(String name) async {
    final url = Uri.parse(
      'https://api.fda.gov/drug/label.json?search=openfda.generic_name:$name',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['results'] != null && data['results'].isNotEmpty) {
        final result = data['results'][0];

        String extractSection(dynamic section) {
          if (section is List) {
            return section.join('\n\n');
          } else if (section is String) {
            return section;
          } else {
            return 'No data available';
          }
        }

        return {
          'purpose:': extractSection(result['purpose:']),
          'usage': extractSection(result['indications_and_usage']),
          'warnings': extractSection(result['warnings']),
        };
      } else {
        throw Exception('No information available for this medicine.');
      }
    } else {
      throw Exception('Failed to fetch data (${response.statusCode})');
    }
  }

  static Exception(String s) {}
}
