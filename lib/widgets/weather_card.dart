// widgets/weather_card.dart
import 'package:flutter/material.dart';
import '../models/financial_models.dart';

class WeatherCard extends StatelessWidget {
  final WeatherInfo? weather;
  final VoidCallback onRefresh;

  const WeatherCard({super.key, this.weather, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Weather',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: onRefresh,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (weather != null) ...[
              Row(
                children: [
                  Icon(
                    _getWeatherIcon(weather!.condition),
                    size: 48,
                    color: Colors.blue[600],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          weather!.condition,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${weather!.temperature.toStringAsFixed(1)}°C',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Humidity: ${weather!.humidity.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (weather!.rainfall != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.water_drop, size: 16, color: Colors.blue[400]),
                    const SizedBox(width: 4),
                    Text(
                      'Rainfall: ${weather!.rainfall!.toStringAsFixed(1)}mm',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ] else ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Weather data not available',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
      case 'clear':
        return Icons.wb_sunny;
      case 'cloudy':
      case 'overcast':
        return Icons.cloud;
      case 'rainy':
      case 'rain':
        return Icons.grain;
      case 'stormy':
      case 'thunderstorm':
        return Icons.thunderstorm;
      default:
        return Icons.cloud;
    }
  }
}
