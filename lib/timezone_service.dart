import 'dart:convert';
import 'package:http/http.dart' as http;

class TimezoneService {
  final String _apiKey = 'FC4JTYGKNLUN'; // make sure it's valid

  Future<String> getCityTime(double lat, double lon) async {
    final url = Uri.parse(
      'http://api.timezonedb.com/v2.1/get-time-zone'
      '?key=$_apiKey&format=json&by=position&lat=$lat&lng=$lon',
    );

    try {
      final response = await http.get(url);
      print("API URL: $url");
      print("API Status Code: ${response.statusCode}");
      print("API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK' && data['formatted'] != null) {
          return data['formatted'];
        } else {
          print("TimeZoneDB Error: ${data['message']}");
        }
      }
    } catch (e) {
      print("HTTP Error: $e");
    }

    return "Time not available";
  }
}
