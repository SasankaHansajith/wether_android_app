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
        'city': json['name'],
        'country': country,
        'temperature': "${json['main']['temp'].round()}°C",
        'humidity': "${json['main']['humidity']}%",
        'windSpeed': "${json['wind']['speed']} m/s",
        'rawLatitude': lat.toString(),
        'rawLongitude': lon.toString(),
        'longitude': "${lon.toStringAsFixed(2)}°",
        'latitude': "${lat.toStringAsFixed(2)}°",
        'condition': json['weather'][0]['main'],
        'description': json['weather'][0]['description'],
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
      "BR": "Brazil",
      "MX": "Mexico",
      "ES": "Spain",
      "RU": "Russia",
      "KR": "South Korea",
      "TH": "Thailand",
      "VN": "Vietnam",
      "PH": "Philippines",
      "SG": "Singapore",
      "MY": "Malaysia",
      "ID": "Indonesia",
      "PK": "Pakistan",
      "BD": "Bangladesh",
      "NL": "Netherlands",
      "BE": "Belgium",
      "CH": "Switzerland",
      "AT": "Austria",
      "SE": "Sweden",
      "NO": "Norway",
      "DK": "Denmark",
      "FI": "Finland",
    };
    return countryMap[code] ?? code;
  }
}