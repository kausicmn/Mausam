import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';
import 'package:geolocator/geolocator.dart';
import 'map_page.dart';
import 'search_page.dart';
import 'settings_page.dart';

void main() {
  runApp(const MaterialApp(
    title: 'Navigation Basics',
    home: FirstRoute(),
  ));
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
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  WeatherFactory wf = WeatherFactory("c5ceceaa1d1369e8dc11555bfd199406");
  bool _isFahrt = false;
  Future<Position> _getcurrentlocation() async {
    final GeolocatorPlatform _locator = GeolocatorPlatform.instance;
    LocationPermission permission = await _getPermission();
    return await _locator.getCurrentPosition();
  }


  Future<Weather> _currentweather(Position position) async {
    return wf.currentWeatherByLocation(
        (await position).latitude, (await position).longitude);
  }

  Future<List<Weather>> _getForecast(Position position) async {
    return wf.fiveDayForecastByLocation(
        (await position).latitude, (await position).longitude);
  }

  Future<LocationPermission> _getPermission() async {
    final GeolocatorPlatform _locator = GeolocatorPlatform.instance;
    return _locator.requestPermission();
  }

  void _unitChanged(bool isFahrt){
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
          icon: Icon(Icons.settings),
          onPressed: () async {
            final isFahrt = await Navigator.push<bool>(
              context,
              MaterialPageRoute(builder: (context) => SettingsPage(onTemperatureUnitChanged: _unitChanged,isFahrt: _isFahrt)),
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
            return Center(
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
                        return CircularProgressIndicator();
                      }


                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            snapshot.data!.areaName ?? '',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                          _isFahrt?'${snapshot.data!.temperature?.fahrenheit?.toInt() ?? ''}°F'
                            :'${snapshot.data!.temperature?.celsius?.toInt() ?? ''}°C',
                            style: TextStyle(
                              fontSize: 64,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            snapshot.data!.weatherDescription ?? '',
                            style: TextStyle(fontSize: 24),
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
                      return CircularProgressIndicator();
                    }

                    return Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: DataTable(
                          columnSpacing: 20.0,
                          columns: [
                            DataColumn(label: Text('Date')),
                            DataColumn(label: Text('Time')),
                            DataColumn(label: Text('Temperature')),
                            DataColumn(label: Text('Description')),
                          ],
                          rows: snapshot.data!.map((weather) => DataRow(
                            cells: [
                              DataCell(Text(
                                DateFormat('MM/dd/yyyy').format(weather.date!),
                                style: TextStyle(fontSize: 16),
                              )),
                              DataCell(Text(
                                DateFormat('h:mm a').format(weather.date!),
                                style: TextStyle(fontSize: 16),
                              )),
                              DataCell(Text(
                                _isFahrt ? '${weather.temperature?.fahrenheit?.toInt() ?? ''}°F' : '${weather.temperature?.celsius?.toInt() ?? ''}°C',
                                style: TextStyle(fontSize: 16),
                              )),
                              DataCell(Text(
                                weather.weatherDescription ?? '',
                                style: TextStyle(fontSize: 16),
                              )),
                            ],
                          )).toList(),
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
                  MaterialPageRoute(builder: (context) => const MapPage()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

}
