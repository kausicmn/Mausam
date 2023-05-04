import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:my_app/weather.dart';
import 'package:my_app/widgets/daily_forecast.dart';
import 'package:my_app/widgets/current_weather.dart';
import 'package:my_app/screens/empty_search_page.dart';
import 'package:my_app/screens/empty_map_page.dart';
import 'package:my_app/screens/settings_page.dart';
import 'package:my_app/weather_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Weather App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final WeatherService _weatherService =
      WeatherService("db03fae9679641cde35e0f9ba462dce9");
  bool _isLoading = false;
  bool _isFahrenheit = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentWeatherData();
    _loadTemperatureUnit();
  }

  Future<void> _loadCurrentWeatherData() async {
    setState(() {
      _isLoading = true;
    });

    await _weatherService
        .getCurrentWeather(); // Call the getCurrentWeather() method

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadTemperatureUnit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isFahrenheit = prefs.getBool('isFahrenheit') ?? false;
    });
  }

  void _updateTemperatureUnit(bool isFahrenheit) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFahrenheit', isFahrenheit);
    setState(() {
      _isFahrenheit = isFahrenheit;
    });
  }

  @override
  Widget build(BuildContext context) {
    var temperature = _weatherService.currentWeather?.temperature ?? 0;
    if (_isFahrenheit) {
      temperature = (temperature * 9 / 5) + 32;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(
                    isFahrenheit: _isFahrenheit,
                    onTemperatureUnitChanged: _updateTemperatureUnit,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            CurrentWeather(
              weatherService: _weatherService,
              useFahrenheit: _isFahrenheit,
            ),
            DailyForecast(weatherService: _weatherService),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.map),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EmptyMapPage()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const EmptySearchPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
