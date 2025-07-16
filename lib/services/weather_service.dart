// services/weather_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/financial_models.dart';

class WeatherService {
  static const String baseUrl =
      'http://localhost:3001'; // Use LAN IP for real device

  Future<WeatherInfo?> getLatestWeather(String location) async {
    final response =
        await http.get(Uri.parse('$baseUrl/weather?location=$location'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data != null && data.isNotEmpty) {
        return WeatherInfo.fromJson(data);
      }
    }
    return null;
  }
}
