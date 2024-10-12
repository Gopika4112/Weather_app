import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/services/weather_service.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  //api key
  final _weatherService = WeatherService('YOUR_API_KEY_HERE');
  Weather? _weather;
  final TextEditingController _cityController = TextEditingController();
  bool _isLoading = false;

  //fetch weather for entered city
  Future<void> _fetchWeatherByCity(String cityName) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final Weather weather = await _weatherService.getWeather(cityName);
      setState(() {
        _weather = weather;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print(e);
    }
  }

  //fetch weather for current location
  Future<void> _fetchWeather() async {
    //get current city
    String cityName = await _weatherService.getCurrentCity();
    //get weather for city
    try {
      final weather = await _weatherService.getWeather(cityName);
      setState(() {
        _weather = weather;
      });
    } catch (e) {
      print(e);
    }
  }

  //weather animations
  String getWeatherAnimation(String? mainCondition) {
    if (mainCondition == null) return 'assets/sunny.json';
    switch (mainCondition.toLowerCase()) {
      case 'clouds':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return 'assets/cloud.json';
      case 'mist':
        return 'assets/mist.json';
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return 'assets/rain.json';
      case 'thunderstorm':
        return 'assets/thunderstorm.json';
      case 'thunder':
        return 'assets/thunder.json';
      case 'snow':
        return 'assets/snow.json';
      case 'clear':
        return 'assets/sunny.json';
      default:
        return 'assets/sunny.json';
    }
  }

  //init state
  @override
  void initState() {
    super.initState();
    //fetch weather on startup
    _fetchWeather();
  }

  //background color
  Color getBackgroundColor(String? mainCondition) {
    if (mainCondition == null) return Colors.blue[400]!; // Default color

    switch (mainCondition.toLowerCase()) {
      case 'clear':
        return Colors.blue[400]!;
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return Colors.grey;
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return Colors.blueGrey;
      case 'thunderstorm':
        return Colors.indigo;
      case 'snow':
        return Colors.white;
      default:
        return Colors.blue[400]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: getBackgroundColor(_weather?.mainCondition),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              //city input field
              const SizedBox(height: 60),
              TextField(
                controller: _cityController,
                decoration: InputDecoration(
                    hintText: 'Enter city name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: IconButton(
                        onPressed: () {
                          String cityName = _cityController.text.trim();
                          if (cityName.isEmpty) {
                            _fetchWeather(); //fetch weather for current location
                            _cityController.clear();
                          } else {
                            _fetchWeatherByCity(cityName);
                          }
                        },
                        icon: const Icon(Icons.search))),
              ),
              const SizedBox(height: 60),
              //city name
              _isLoading
                  ? const CircularProgressIndicator()
                  : Text(
                      _weather?.cityName ?? "Loading city...",
                      style: const TextStyle(
                        fontSize: 28, // Adjust the font size as needed
                        color: Colors.white, // Set the text color to white
                      ),
                    ),
              const SizedBox(height: 20),
              //animation
              if (_weather != null) ...[
                SizedBox(
                    height: 300,
                    width: 300,
                    child: Lottie.asset(
                        getWeatherAnimation(_weather?.mainCondition))),
                const SizedBox(height: 30),
                //temperature
                Text('${_weather?.temperature.round()}°C',
                    style: const TextStyle(fontSize: 40, color: Colors.white)),
                //weather condition
                Text(_weather?.mainCondition ?? "",
                    style: TextStyle(fontSize: 20, color: Colors.white)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
