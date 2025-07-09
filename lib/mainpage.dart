import 'dart:async';
import 'package:flutter/material.dart';
import 'weather_service.dart';
import 'settings_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String city = "";
  String country = "";
  String temperature = "";
  String humidity = "";
  String windSpeed = "";
  String longitude = "";
  String latitude = "";
  String condition = "";
  String description = "";
  String currentTime = "";

  bool _hasData = false;
  Timer? _timer;

  final TextEditingController _controller = TextEditingController();
  final WeatherService weatherService = WeatherService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateTime();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateTime() {
    final now = TimeOfDay.now();
    if (mounted) {
      setState(() {
        currentTime = now.format(context);
      });
    }
  }

  Future<void> fetchWeather(String cityName) async {
    try {
      final data = await weatherService.fetchWeather(cityName);
      setState(() {
        city = data['city'] ?? "";
        country = data['country'] ?? "";
        temperature = data['temperature'] ?? "";
        humidity = data['humidity'] ?? "";
        windSpeed = data['windSpeed'] ?? "";
        longitude = data['longitude'] ?? "";
        latitude = data['latitude'] ?? "";
        condition = data['condition'] ?? "";
        description = data['description'] ?? "";
        _hasData = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not fetch weather for $cityName")),
      );
    }
  }

  void clearWeather() {
    setState(() {
      city = "";
      country = "";
      temperature = "";
      humidity = "";
      windSpeed = "";
      longitude = "";
      latitude = "";
      condition = "";
      description = "";
      _hasData = false;
    });
  }

  IconData getWeatherIcon(String condition) {
    condition = condition.toLowerCase();
    if (condition.contains('rain') || condition.contains('drizzle')) {
      return Icons.beach_access;
    } else if (condition.contains('cloud')) {
      return Icons.cloud;
    } else if (condition.contains('clear')) {
      return Icons.wb_sunny;
    } else if (condition.contains('snow')) {
      return Icons.ac_unit;
    } else if (condition.contains('mist') || condition.contains('fog')) {
      return Icons.blur_on;
    } else if (condition.contains('thunderstorm')) {
      return Icons.flash_on;
    } else {
      return Icons.wb_cloudy;
    }
  }

  String getBackgroundImage(String condition) {
    condition = condition.toLowerCase();
    if (condition.contains('rain') || condition.contains('drizzle')) {
      return 'assets/images/rain.jpg';
    } else if (condition.contains('cloud')) {
      return 'assets/images/clouds.jpg';
    } else if (condition.contains('clear')) {
      return 'assets/images/clear.jpg';
    } else if (condition.contains('snow')) {
      return 'assets/images/snow.jpg';
    } else if (condition.contains('mist') || condition.contains('fog')) {
      return 'assets/images/fog.jpg';
    } else if (condition.contains('thunderstorm')) {
      return 'assets/images/thunderstorm.jpg';
    } else {
      return 'assets/images/default.jpg';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(getBackgroundImage(condition)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(color: Colors.black.withOpacity(0.5)),
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _controller,
                        style: const TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        onSubmitted: (value) {
                          if (value.isNotEmpty) {
                            fetchWeather(value);
                            _controller.clear();
                          }
                        },
                        decoration: InputDecoration(
                          hintText: "Search city...",
                          hintStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.white,
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_hasData) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              currentTime,
                              style: const TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            _infoCard(Icons.water_drop, humidity, "Humidity"),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _infoCard(Icons.air, windSpeed, "Wind"),
                              const SizedBox(width: 10),
                              _infoCard(Icons.language, longitude, "Longitude"),
                              const SizedBox(width: 10),
                              _infoCard(
                                Icons.my_location,
                                latitude,
                                "Latitude",
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(25),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.1),
                                Colors.white.withOpacity(0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                temperature,
                                style: const TextStyle(
                                  fontSize: 64,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Icon(
                                getWeatherIcon(condition),
                                size: 60,
                                color: Colors.yellowAccent,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                description,
                                style: const TextStyle(
                                  fontSize: 22,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "$city, $country",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white60,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 80),
                      ],
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 35,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: clearWeather,
                        child: const Icon(
                          Icons.home,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SettingsPage(),
                            ),
                          );
                        },
                        child: const Icon(
                          Icons.settings,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _infoCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _infoCard(this.icon, this.value, this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 95,
      height: 95,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 26, color: Colors.white),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: Colors.white70),
          ),
        ],

        
      ),
    );
  }
}
