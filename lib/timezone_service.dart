import 'dart:convert';
import 'package:http/http.dart' as http;

class TimezoneService {
  final String _apiKey = 'FC4JTYGKNLUN';

  Future<String> getCityTime(double lat, double lon) async {
    final url = Uri.parse(
      'http://api.timezonedb.com/v2.1/get-time-zone'
      '?key=$_apiKey&format=json&by=position&lat=$lat&lng=$lon',
    );

    try {
      final response = await http.get(url);
      print("TimeZone API URL: $url");
      print("TimeZone API Status Code: ${response.statusCode}");
      print("TimeZone API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK' && data['formatted'] != null) {
          // Extract time from formatted string like "2024-01-01 14:30:00"
          String formatted = data['formatted'];
          print("Formatted time: $formatted");
          return formatted;
        } else {
          print("TimeZoneDB Error: ${data['message']}");
        }
      } else {
        print("TimeZone API Error: ${response.statusCode}");
      }
    } catch (e) {
      print("TimeZone HTTP Error: $e");
    }

    return "Time not available";
  }
}