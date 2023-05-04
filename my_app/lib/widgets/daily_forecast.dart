import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/weather.dart';
import 'package:my_app/weather_service.dart';

class DailyForecast extends StatelessWidget {
  final WeatherService weatherService;

  const DailyForecast({Key? key, required this.weatherService})
      : super(key: key);
  // Future<void> _loadDailyForecast() async {
  //   List<Weather>? forecast = await _weatherService.getDailyForecast();
  //   setState(() {
  //     _dailyForecast = forecast;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final _dateFormat = DateFormat('EEE, MMM d');

    return FutureBuilder<List<Weather>>(
      future: weatherService.getDailyForecast(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasData) {
          final dailyForecast = snapshot.data!;

          return Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: dailyForecast.length,
              itemBuilder: (context, index) {
                final forecast = dailyForecast[index];
                final date = _dateFormat.format(forecast.date!);
                final minTemp =
                    forecast.minTemperature?.toStringAsFixed(0) ?? "-";
                final maxTemp =
                    forecast.maxTemperature?.toStringAsFixed(0) ?? "-";
                final iconCode =
                    forecast.weatherDescription?.toLowerCase() ?? "clear";

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          date,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                        Image.asset(
                          "assets/images/$iconCode.png",
                          height: 60.0,
                          width: 60.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "$maxTemp°",
                              style: const TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              width: 8.0,
                            ),
                            Text(
                              "$minTemp°",
                              style: const TextStyle(
                                fontSize: 16.0,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
