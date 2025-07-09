import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = "6102df53bc0b239e37f00b54886a9997";
  final String apiUrl = "https://api.openweathermap.org/data/2.5/weather";

  Future<Map<String, dynamic>> fetchWeather(String city) async {
    final url = Uri.parse("$apiUrl?q=$city&appid=$apiKey&units=metric");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final lat = json['coord']['lat'];
      final lon = json['coord']['lon'];
      final countryCode = json['sys']['country'] ?? "";
      final country = _getCountryName(countryCode);

      return {
        "temperature": "${json['main']['temp'].round()} ℃",
        "humidity": "${json['main']['humidity']}%",
        "windSpeed": "${json['wind']['speed']} Km/h",
        "longitude": "$lon° E",
        "latitude": "$lat° N",
        "rawLongitude": lon.toString(), // Add these
        "rawLatitude": lat.toString(),
        "condition": json['weather'][0]['main'].toLowerCase(),
        "description": json['weather'][0]['description'],
        "city": json['name'],
        "country": country,
      };
    } else if (response.statusCode == 404) {
      throw Exception("City not found: $city");
    } else {
      throw Exception("Failed to fetch weather: ${response.statusCode}");
    }
  }

  String _getCountryName(String code) {
    const countryMap = {
      "LK": "Sri Lanka",
      "US": "USA",
      "GB": "United Kingdom",
      "IN": "India",
      "FR": "France",
      "JP": "Japan",
      "CN": "China",
      "DE": "Germany",
      "IT": "Italy",
      "CA": "Canada",
      "AU": "Australia",
      "RU": "Russia",
      "BR": "Brazil",
    };
    return countryMap[code] ?? code;
  }
}
