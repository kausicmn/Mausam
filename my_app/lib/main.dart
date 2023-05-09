import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/position.dart';
import 'package:weather/weather.dart';
import 'package:geolocator/geolocator.dart';
import 'map_page.dart';
import 'SecondRoute.dart';
import 'settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp(
    given_city: '',
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key, required this.given_city}) : super(key: key);

  final String? given_city;

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.deepPurple,
      ),
      home: MyHomePage(
        title: 'MAUSAM', city_name: given_city ?? '',
        // storage: PhotoStorage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title, required this.city_name})
      : super(key: key);

  final String title;
  // final PhotoStorage storage;
  final String city_name;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  WeatherFactory wf = WeatherFactory("c5ceceaa1d1369e8dc11555bfd199406");
  bool _isFahrenheit = false;
  Position? _currentPosition;
  Weather? _currentWeather;
  List<Weather>? _forecast;
  Future<Position> _getcurrentlocation() {
    return PositionHelper().determinePosition();
  }

  Future<Weather> _currentweather(Position position) {
    return wf.currentWeatherByLocation(position.latitude, position.longitude);
  }

  Future<List<Weather>> _getForecast(Position position) {
    return wf.fiveDayForecastByLocation(position.latitude, position.longitude);
  }

  Future<void> _loadTemperatureUnit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isFahrenheit = prefs.getBool('isFahrenheit') ?? false;
    });
  }

  Future<void> _fetchWeatherData() async {
    _currentPosition = await _getcurrentlocation();
    if (super.widget.city_name != '') {
      _currentPosition = await getCityCoordinates(super.widget.city_name);
    }
    _currentWeather = await _currentweather(_currentPosition!);
    _forecast = await _getForecast(_currentPosition!);
    setState(() {});
  }

  void _updateTemperatureUnit(bool isFahrenheit) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFahrenheit', isFahrenheit);
    setState(() {
      _isFahrenheit = isFahrenheit;
    });
    await _fetchWeatherData();
  }

  Future<Position> getCityCoordinates(String cityName) async {
    final response = await http.get(Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$cityName&format=json&limit=1'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)[0];
      final latitude = double.parse(data['lat']);
      final longitude = double.parse(data['lon']);
      return Position(
          latitude: latitude,
          longitude: longitude,
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          timestamp: null);
    } else {
      throw Exception('Failed to load city coordinates');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadTemperatureUnit();
    _fetchWeatherData();
    //_pos = PositionHelper().determinePosition()
    print('You jnnsj on Item ${widget.city_name}');
  }

  String _getTemperatureUnit() {
    return _isFahrenheit ? '°F' : '°C';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () async {
              bool? isFahrenheit = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SettingsPage(
                          isFahrenheit: _isFahrenheit,
                          onTemperatureUnitChanged: _updateTemperatureUnit,
                        )),
              );
              if (isFahrenheit != null) {
                _updateTemperatureUnit(isFahrenheit);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: _currentWeather == null
                  ? CircularProgressIndicator()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentWeather!.areaName ?? '',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 15),
                        Text(
                          _isFahrenheit
                              ? '${_currentWeather!.temperature?.fahrenheit?.toInt() ?? ''}°F'
                              : '${_currentWeather!.temperature?.celsius?.toInt() ?? ''}°C',
                          style: const TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          _currentWeather!.weatherDescription ?? '',
                          style: const TextStyle(fontSize: 24),
                        ),
                      ],
                    ),
            ),
          ),
          Expanded(
            child: _forecast == null
                ? Text('Loading Please Wait')
                : SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      columnSpacing: 20.0,
                      columns: [
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Time')),
                        DataColumn(label: Text('Temperature')),
                        DataColumn(label: Text('Description')),
                      ],
                      rows: _forecast!
                          .map((weather) => DataRow(
                                cells: [
                                  DataCell(Text(
                                    DateFormat('MM/dd/yyyy')
                                        .format(weather.date!),
                                    style: TextStyle(fontSize: 14),
                                  )),
                                  DataCell(Text(
                                    DateFormat('h:mm a').format(weather.date!),
                                    style: TextStyle(fontSize: 14),
                                  )),
                                  DataCell(Text(
                                    _isFahrenheit
                                        ? '${weather.temperature?.fahrenheit?.toInt() ?? ''}°F'
                                        : '${weather.temperature?.celsius?.toInt() ?? ''}°C',
                                    style: TextStyle(fontSize: 14),
                                  )),
                                  DataCell(Text(
                                    weather.weatherDescription ?? '',
                                    style: TextStyle(fontSize: 14),
                                  )),
                                ],
                              ))
                          .toList(),
                    ),
                  ),
          ),
        ],
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
                  MaterialPageRoute(
                      builder: (context) => const MapPage(
                            title: 'Map Page',
                          )),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SecondPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
