import 'package:flutter/material.dart';
import 'package:weather/weather.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'MAUSAM'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;
  // final String key ='db03fae9679641cde35e0f9ba462dce9';
  // final WeatherFactory wf = new WeatherFactory(key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
//
// final String key ='db03fae9679641cde35e0f9ba462dce9';
// final WeatherFactory wf = new WeatherFactory(key);
  late String key;
  late WeatherFactory wf;
  Weather? wth;

  Future<void> getCurrentWeather() async {
    Position loc = await Geolocator.getCurrentPosition();
    // setState(()  async{
    wth = await wf.currentWeatherByLocation(loc.latitude, loc.longitude);
    //
    // Weather w = await wf.currentWeatherByLocation(loc.latitude, loc.longitude);
    // wth = w;
    // Text(" Temperature in celsius: ${w.temperature?.celsius} C");
  }

  void initState() {
    super.initState();
    key = 'db03fae9679641cde35e0f9ba462dce9';
    wf = new WeatherFactory(key);
    getCurrentWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {},
          )
        ],
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(" Temperature in celsius: ${wth?.temperature?.celsius} C"),
          ],
        ),
      ),

      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.map),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {},
            )
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
