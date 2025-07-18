import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
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
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _videoError = false;

  final TextEditingController _controller = TextEditingController();
  final WeatherService weatherService = WeatherService();
  final TimezoneService timezoneService = TimezoneService();

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    _setInitialBackground();
  }

  void _setInitialBackground() {
    final currentHour = DateTime.now().hour;
    setState(() {
      _backgroundImage = getBackgroundImageByTime(currentHour);
    });
  }

  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.asset(
        'assets/videos/default.mp4',
      );
      await _videoController!.initialize();
      _videoController!.setLooping(true);
      _videoController!.setVolume(0.0);
      await _videoController!.play();

      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
          _videoError = false;
        });
      }
    } catch (e) {
      print('Error initializing video: $e');
      if (mounted) {
        setState(() {
          _videoError = true;
          _isVideoInitialized = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

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

      // Get current local time as fallback
      final now = DateTime.now();
      int currentHour = now.hour;
      String fetchedTime =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

      if (lat != null && lon != null) {
        try {
          final fullTime = await timezoneService.getCityTime(lat, lon);
          print("Full time received: $fullTime");

          if (fullTime != "Time not available" && fullTime.isNotEmpty) {
            // Extract time from "2024-01-01 14:30:00" format
            if (fullTime.contains(" ")) {
              final parts = fullTime.split(" ");
              if (parts.length >= 2) {
                final timePart = parts[1];
                final timeParts = timePart.split(":");
                if (timeParts.isNotEmpty) {
                  final hourString = timeParts[0];
                  currentHour = int.tryParse(hourString) ?? currentHour;
                  fetchedTime =
                      "${hourString}:${timeParts.length > 1 ? timeParts[1] : '00'}";
                  print("Extracted hour: $currentHour from time: $fetchedTime");
                }
              }
            }
          }
        } catch (e) {
          print("Error getting timezone: $e, using local time");
        }
      }

      // Get background image based on the hour
      final bgImage = getBackgroundImageByTime(currentHour);
      print("Current hour: $currentHour, Selected background: $bgImage");

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

      print("Background image updated to: $_backgroundImage");
    } catch (e) {
      print("Error fetching weather: $e");
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
    // Get current hour for default background
    final currentHour = DateTime.now().hour;
    final defaultBg = getBackgroundImageByTime(currentHour);

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
      _backgroundImage = defaultBg;
      _hasData = false;
    });

    print("Weather cleared, background reset to: $_backgroundImage");
  }

  String getBackgroundImageByTime(int hour) {
    print("Getting background for hour: $hour");

    String backgroundImage;

    if (hour >= 6 && hour < 12) {
      backgroundImage = 'assets/images/Morning.jpg';
      print("Morning time detected (6-12), using: $backgroundImage");
    } else if (hour >= 12 && hour < 18) {
      backgroundImage = 'assets/images/Day.jpg';
      print("Day time detected (12-18), using: $backgroundImage");
    } else {
      backgroundImage = 'assets/images/Night.jpg';
      print("Night time detected (18-6), using: $backgroundImage");
    }

    return backgroundImage;
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
    final isTablet = screenWidth > 600;
    final bottomPadding = media.padding.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  _hasData ? _backgroundImage : "assets/images/background.jpg",
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
          // Content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableHeight = constraints.maxHeight;
                final contentHeight =
                    availableHeight - 80; // Reserve space for bottom nav

                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: contentHeight),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 60 : 20,
                          vertical: 10,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child:
                                  _hasData
                                      ? buildWeatherContent(
                                        screenWidth,
                                        screenHeight,
                                        isPortrait,
                                        isTablet,
                                      )
                                      : buildWelcomeContent(
                                        screenWidth,
                                        screenHeight,
                                        isPortrait,
                                        isTablet,
                                      ),
                            ),
                            SizedBox(
                              height: bottomPadding > 0 ? bottomPadding : 80,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Bottom Navigation
          Positioned(
            bottom: bottomPadding > 0 ? bottomPadding + 10 : 20,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 50 : 35,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: clearWeather,
                    child: Icon(
                      Icons.home,
                      color: Colors.white,
                      size: isTablet ? 32 : 28,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsPage()),
                      );
                    },
                    child: Icon(
                      Icons.settings,
                      color: Colors.white,
                      size: isTablet ? 32 : 28,
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

  Widget buildWelcomeContent(
    double screenWidth,
    double screenHeight,
    bool isPortrait,
    bool isTablet,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Welcome to CityClime",
          style: TextStyle(
            fontSize: isTablet ? 40 : (isPortrait ? 32 : 28),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isPortrait ? 20 : 15),
        Text(
          "What country's weather do you want to check?",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white70,
            fontSize: isTablet ? 20 : (isPortrait ? 16 : 14),
          ),
        ),
        SizedBox(height: isPortrait ? 40 : 30),
        buildSearchBar(isTablet),
      ],
    );
  }

  Widget buildSearchBar(bool isTablet) {
    return TextField(
      controller: _controller,
      style: TextStyle(color: Colors.white, fontSize: isTablet ? 18 : 16),
      cursorColor: Colors.white,
      onSubmitted: (value) {
        if (value.trim().isNotEmpty) {
          fetchWeather(value);
          _controller.clear();
        }
      },
      decoration: InputDecoration(
        hintText: "Search city...",
        hintStyle: TextStyle(
          color: Colors.white70,
          fontSize: isTablet ? 18 : 16,
        ),
        prefixIcon: Icon(
          Icons.search,
          color: Colors.white,
          size: isTablet ? 28 : 24,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        contentPadding: EdgeInsets.symmetric(
          vertical: isTablet ? 20 : 16,
          horizontal: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget buildWeatherContent(
    double screenWidth,
    double screenHeight,
    bool isPortrait,
    bool isTablet,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildSearchBar(isTablet),
        SizedBox(height: isPortrait ? 30 : 20),
        if (_isLoading)
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: isTablet ? 4 : 3,
          )
        else ...[
          // Time Display
          Text(
            currentTime,
            style: TextStyle(
              fontSize: isTablet ? 56 : (isPortrait ? 46 : 36),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: isPortrait ? 25 : 15),

          // Weather Main Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isTablet ? 30 : 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  temperature,
                  style: TextStyle(
                    fontSize: isTablet ? 60 : (isPortrait ? 50 : 40),
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: isPortrait ? 15 : 10),
                Image.asset(
                  getIconPath(condition),
                  width: isTablet ? 70 : 55,
                  height: isTablet ? 70 : 55,
                ),
                SizedBox(height: isPortrait ? 15 : 10),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: isTablet ? 26 : (isPortrait ? 20 : 18),
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isPortrait ? 10 : 6),
                Text(
                  "$city, $country",
                  style: TextStyle(
                    fontSize: isTablet ? 18 : (isPortrait ? 14 : 12),
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          SizedBox(height: isPortrait ? 30 : 20),

          // Weather Info Cards
          if (isPortrait) ...[
            Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    Icons.water_drop,
                    humidity,
                    "Humidity",
                    isTablet,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _InfoCard(Icons.air, windSpeed, "Wind", isTablet),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    Icons.language,
                    longitude,
                    "Longitude",
                    isTablet,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _InfoCard(
                    Icons.my_location,
                    latitude,
                    "Latitude",
                    isTablet,
                  ),
                ),
              ],
            ),
          ] else ...[
            // Landscape layout - all cards in one row
            Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    Icons.water_drop,
                    humidity,
                    "Humidity",
                    isTablet,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _InfoCard(Icons.air, windSpeed, "Wind", isTablet),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _InfoCard(
                    Icons.language,
                    longitude,
                    "Longitude",
                    isTablet,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _InfoCard(
                    Icons.my_location,
                    latitude,
                    "Latitude",
                    isTablet,
                  ),
                ),
              ],
            ),
          ],
        ],
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final bool isTablet;

  const _InfoCard(
    this.icon,
    this.value,
    this.label,
    this.isTablet, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Container(
      height: isTablet ? 120 : (isPortrait ? 100 : 80),
      padding: EdgeInsets.all(isTablet ? 20 : 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: isTablet ? 32 : (isPortrait ? 26 : 20),
            color: Colors.white,
          ),
          SizedBox(height: isPortrait ? 8 : 4),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: isTablet ? 16 : (isPortrait ? 14 : 12),
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: isPortrait ? 4 : 2),
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isTablet ? 14 : (isPortrait ? 12 : 10),
                color: Colors.white70,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
