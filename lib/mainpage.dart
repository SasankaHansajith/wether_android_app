import 'package:flutter/material.dart';
import 'weather_service.dart';
import 'timezone_service.dart';
import 'settings_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String city = "",
      country = "",
      temperature = "",
      humidity = "",
      windSpeed = "";
  String longitude = "",
      latitude = "",
      condition = "",
      description = "",
      currentTime = "";
  bool _hasData = false;
  bool _isLoading = false;

  String _backgroundImage = 'assets/images/Day.jpg';

  final TextEditingController _controller = TextEditingController();
  final WeatherService weatherService = WeatherService();
  final TimezoneService timezoneService = TimezoneService();

  Future<void> fetchWeather(String cityName) async {
    final trimmedCity = cityName.trim();
    if (trimmedCity.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final data = await weatherService.fetchWeather(trimmedCity);
      final lat = double.tryParse(data['rawLatitude'] ?? '');
      final lon = double.tryParse(data['rawLongitude'] ?? '');
      String fetchedTime = "00:00";

      if (lat != null && lon != null) {
        final fullTime = await timezoneService.getCityTime(lat, lon);
        if (fullTime.contains(" ")) {
          final timePart = fullTime.split(" ")[1];
          final parts = timePart.split(":");
          if (parts.length >= 2) {
            fetchedTime = "${parts[0]}:${parts[1]}";
          }
        }
      }

      final bgImage = getBackgroundImageByTime(fetchedTime);

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
        currentTime = fetchedTime;
        _backgroundImage = bgImage;
        _hasData = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Could not fetch weather or time for $trimmedCity"),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
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
      currentTime = "";
      _backgroundImage = 'assets/images/Day.jpg';
      _hasData = false;
    });
  }

  String getBackgroundImageByTime(String timeString) {
    try {
      final hour = int.parse(timeString.split(":")[0]);

      if (hour >= 6 && hour < 12) {
        return 'assets/images/Morning.jpg';
      } else if (hour >= 12 && hour < 18) {
        return 'assets/images/Day.jpg';
      } else {
        return 'assets/images/Night.jpg';
      }
    } catch (e) {
      return 'assets/images/Day.jpg'; // fallback
    }
  }

  String getIconPath(String condition) {
    final c = condition.toLowerCase();
    if (c.contains('clear')) return 'assets/icon/clear.png';
    if (c.contains('cloud')) return 'assets/icon/clouds.png';
    if (c.contains('rain')) return 'assets/icon/rain.png';
    if (c.contains('drizzle')) return 'assets/icon/drizzle.png';
    if (c.contains('snow')) return 'assets/icon/snow.png';
    if (c.contains('fog') || c.contains('mist')) return 'assets/icon/fog.png';
    if (c.contains('thunderstorm')) return 'assets/icon/thunderstorm.png';
    return 'assets/icon/clear.png';
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isPortrait = media.orientation == Orientation.portrait;
    final screenWidth = media.size.width;
    final screenHeight = media.size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 800),
            child: Container(
              key: ValueKey(_backgroundImage),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(_backgroundImage),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.5)),
          SafeArea(
            child:
                _hasData
                    ? buildWeatherContent(screenWidth, isPortrait)
                    : buildWelcomeContent(screenWidth, screenHeight),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
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
                        MaterialPageRoute(builder: (_) => const SettingsPage()),
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
      ),
    );
  }

  Widget buildWelcomeContent(double screenWidth, double screenHeight) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Hi! 👋",
              style: TextStyle(
                fontSize: 36,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "What country's weather do you want to check?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.white70),
            ),
            const SizedBox(height: 30),
            buildSearchBar(),
          ],
        ),
      ),
    );
  }

  Widget buildSearchBar() {
    return TextField(
      controller: _controller,
      style: const TextStyle(color: Colors.white),
      cursorColor: Colors.white,
      onSubmitted: (value) {
        if (value.trim().isNotEmpty) {
          fetchWeather(value);
          _controller.clear();
        }
      },
      decoration: InputDecoration(
        hintText: "Search city...",
        hintStyle: const TextStyle(color: Colors.white70),
        prefixIcon: const Icon(Icons.search, color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget buildWeatherContent(double screenWidth, bool isPortrait) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: 20,
      ),
      child: Column(
        children: [
          buildSearchBar(),
          const SizedBox(height: 20),
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.white))
          else ...[
            Center(
              child: Text(
                currentTime,
                style: TextStyle(
                  fontSize: isPortrait ? 46 : 36,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                _InfoCard(Icons.water_drop, humidity, "Humidity"),
                _InfoCard(Icons.air, windSpeed, "Wind"),
                _InfoCard(Icons.language, longitude, "Longitude"),
                _InfoCard(Icons.my_location, latitude, "Latitude"),
              ],
            ),
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Text(
                    temperature,
                    style: TextStyle(
                      fontSize: isPortrait ? 50 : 40,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Image.asset(getIconPath(condition), width: 55, height: 55),
                  const SizedBox(height: 10),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "$city, $country",
                    style: const TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),
          ],
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _InfoCard(this.icon, this.value, this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * 0.4,
      height: screenWidth * 0.28,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
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
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
