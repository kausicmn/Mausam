class Weather {
  final DateTime? date;
  final String? weatherDescription;
  final double? temperature;
  final double? minTemperature;
  final double? maxTemperature;

  Weather({
    this.date,
    this.weatherDescription,
    this.temperature,
    this.minTemperature,
    this.maxTemperature,
  });

  double? get celsius => temperature;

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      date: json['dt'] != null ? DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000) : null,
      weatherDescription: json['weather'] != null && json['weather'].isNotEmpty
          ? json['weather'][0]['description']
          : null,
      temperature: json['main'] != null ? json['main']['temp']?.toDouble() : null,
      minTemperature: json['main'] != null ? json['main']['temp_min']?.toDouble() : null,
      maxTemperature: json['main'] != null ? json['main']['temp_max']?.toDouble() : null,
    );
  }
}
