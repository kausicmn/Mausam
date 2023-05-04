import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:project/weather.dart';

class WeatherService {
  late String _apiKey;
  Weather? _currentWeather;
  List<Weather>? _dailyForecast;
  String? _errorMessage;
  bool _isLoading = true;
  String? _cityName;

  WeatherService(String apiKey) {
    _apiKey = apiKey;
  }

  Weather? get currentWeather => _currentWeather;
  List<Weather>? get dailyForecast => _dailyForecast;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  String? get cityName => _cityName;

  Future<void> getCurrentWeather() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      String apiUrl = "https://api.openweathermap.org/data/2.5/weather?lat=" +
          position.latitude.toString() +
          "&lon=" +
          position.longitude.toString() +
          "&appid=" +
          _apiKey +
          "&units=metric";

      http.Response response = await http.get(Uri.parse(apiUrl));
      var result = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _currentWeather = Weather.fromJson(result);
        _cityName = await _getCityNameFromLocation(position);
        _errorMessage = null;
      } else {
        _errorMessage = "Unable to fetch weather data";
      }
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
  }

  Future<String> _getCityNameFromLocation(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);
      Placemark place = placemarks.first;
      return "${place.locality}, ${place.administrativeArea}, ${place.country}";
    } catch (e) {
      return "Unknown";
    }
  }

  Future<List<Weather>> getDailyForecast() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      String apiUrl = "https://api.openweathermap.org/data/2.5/onecall?lat=" +
          position.latitude.toString() +
          "&lon=" +
          position.longitude.toString() +
          "&exclude=current,minutely,hourly,alerts&appid=" +
          _apiKey +
          "&units=metric";

      http.Response response = await http.get(Uri.parse(apiUrl));
      var result = jsonDecode(response.body);

      if (response.statusCode == 200) {
        List<dynamic> list = result["daily"];
        List<Weather> forecast = list.map((item) => Weather.fromJson(item)).toList();
        _errorMessage = null;
        return forecast;
      } else {
        _errorMessage = "Unable to fetch weather data";
      }
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    return [];
  }

}
