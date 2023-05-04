import 'package:flutter/material.dart';
import 'package:my_app/weather.dart';
import 'package:my_app/weather_service.dart';

class CurrentWeather extends StatelessWidget {
  final WeatherService weatherService;
  final bool useFahrenheit;

  CurrentWeather({
    Key? key,
    required this.weatherService,
    required this.useFahrenheit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var temperature = weatherService.currentWeather?.temperature ?? 0;
    if (useFahrenheit) {
      temperature = (temperature * 9 / 5) + 32;
    }

    return Column(
      children: [
        if (weatherService.isLoading)
          const CircularProgressIndicator()
        else if (weatherService.errorMessage != null)
          Text(
            weatherService.errorMessage!,
            style: const TextStyle(fontSize: 18),
          )
        else
          Column(
            children: [
              Text(
                weatherService.cityName ?? '',
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 16),
              Text(
                '${temperature.toStringAsFixed(1)}°',
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(height: 16),
              Text(
                weatherService.currentWeather?.weatherDescription ?? '',
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
      ],
    );
  }
}
