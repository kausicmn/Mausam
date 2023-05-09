import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/position.dart';
import 'package:weather/weather.dart';
import 'package:geolocator/geolocator.dart';
import 'map_page.dart';
import 'SecondRoute.dart';
import 'settings_page.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

//"Hi Kausic"
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
      home: const MyHomePage(title: 'Flutter Demo Home Page'
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
  bool _isFahrt = false;
  Future<Position> _getcurrentlocation() {
    return PositionHelper().determinePosition();
  }

  Future<Weather> _currentweather(Position position) {
    return wf.currentWeatherByLocation(
        (position).latitude, (position).longitude);
  }

  Future<List<Weather>> _getForecast(Position position) {
    return wf.fiveDayForecastByLocation(
        (position).latitude, (position).longitude);
  }

  void _unitChanged(bool isFahrt) {
    setState(() {
      _isFahrt = isFahrt;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              final isFahrt = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                    builder: (context) => SettingsPage(
                        onTemperatureUnitChanged: _unitChanged,
                        isFahrt: _isFahrt)),
              );
              if (isFahrt != null) {
                setState(() {
                  _isFahrt = isFahrt;
                });
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<Position>(
        future: _getcurrentlocation(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Column(
            children: [
              Expanded(
                child: Center(
                  child: FutureBuilder<Weather>(
                    future: _currentweather(snapshot.data!),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }

                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            snapshot.data!.areaName ?? '',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _isFahrt
                                ? '${snapshot.data!.temperature?.fahrenheit?.toInt() ?? ''}°F'
                                : '${snapshot.data!.temperature?.celsius?.toInt() ?? ''}°C',
                            style: const TextStyle(
                              fontSize: 64,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            snapshot.data!.weatherDescription ?? '',
                            style: const TextStyle(fontSize: 24),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Weather>>(
                  future: _getForecast(snapshot.data!),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }

                    return Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: DataTable(
                          columnSpacing: 20.0,
                          columns: const [
                            DataColumn(label: Text('Date')),
                            DataColumn(label: Text('Time')),
                            DataColumn(label: Text('Temperature')),
                            DataColumn(label: Text('Description')),
                          ],
                          rows: snapshot.data!
                              .map((weather) => DataRow(
                                    cells: [
                                      DataCell(Text(
                                        DateFormat('MM/dd/yyyy')
                                            .format(weather.date!),
                                        style: const TextStyle(fontSize: 16),
                                      )),
                                      DataCell(Text(
                                        DateFormat('h:mm a')
                                            .format(weather.date!),
                                        style: const TextStyle(fontSize: 16),
                                      )),
                                      DataCell(Text(
                                        _isFahrt
                                            ? '${weather.temperature?.fahrenheit?.toInt() ?? ''}°F'
                                            : '${weather.temperature?.celsius?.toInt() ?? ''}°C',
                                        style: const TextStyle(fontSize: 16),
                                      )),
                                      DataCell(Text(
                                        weather.weatherDescription ?? '',
                                        style: const TextStyle(fontSize: 16),
                                      )),
                                    ],
                                  ))
                              .toList(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
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
