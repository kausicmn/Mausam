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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
      home: const MyHomePage(title: 'MAUSAM'
          // storage: PhotoStorage(),
          ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;
  // final PhotoStorage storage;

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

  @override
  void initState() {
    super.initState();
    _loadTemperatureUnit();
    _fetchWeatherData();
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
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 15),
                        Text(
                          _isFahrenheit
                              ? '${_currentWeather!.temperature?.fahrenheit?.toInt() ?? ''}°F'
                              : '${_currentWeather!.temperature?.celsius?.toInt() ?? ''}°C',
                          style: TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 15),
                        Text(
                          _currentWeather!.weatherDescription ?? '',
                          style: TextStyle(fontSize: 24),
                        ),
                      ],
                    ),
            ),
          ),
          Expanded(
            child: _forecast == null
                ? CircularProgressIndicator()
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
