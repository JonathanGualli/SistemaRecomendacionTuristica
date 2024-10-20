import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ClimateService {
  static const String baseUrl = 'https://api.tomorrow.io/v4/timelines';
  static const String apiKey = 'BscDaxFAClp2E1BUuukcBE3Irw2M1km4';
  static const String fields =
      'precipitationIntensity,precipitationProbability,temperature,windSpeed,humidity,precipitationType,weatherCode';
  //static const String startTime = '2024-10-16T08:00:00Z';
  //static const String endTime = '2024-10-16T23:59:59Z';
  static const String units = 'metric';

  // Método para construir la URL de la API basada en las coordenadas LatLng
  String buildApiUrl(
    LatLng location,
    String startTime,
    String endTime,
  ) {
    return '$baseUrl?location=${location.latitude},${location.longitude}'
        '&fields=$fields'
        '&timesteps=30m'
        '&startTime=$startTime'
        '&endTime=$endTime'
        '&units=$units'
        '&apikey=$apiKey';
  }

  // Método para obtener los datos del clima
  Future<List<dynamic>?> fetchClimateData(
      LatLng location, String startTime, String endTime) async {
    String apiUrl = buildApiUrl(location, startTime, endTime);
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        return json.decode(response.body)['data']['timelines'][0]['intervals'];
      } else {
        throw Exception('Failed to load climate data');
      }
    } catch (error) {
      print('Error fetching climate data: $error');
      return null; // Retorna null si hay un error
    }
  }
}
/* [{startTime: 2024-10-17T18:30:00Z, values: {humidity: 91.94, precipitationIntensity: 0.05, precipitationProbability: 30, precipitationType: 1, temperature: 15.96, weatherCode: 1001, windSpeed: 4.16}}, 
{startTime: 2024-10-17T19:00:00Z, values: {humidity: 91.39, precipitationIntensity: 0.05, precipitationProbability: 30, precipitationType: 1, temperature: 15.81, weatherCode: 1001, windSpeed: 4.18}}, 
{startTime: 2024-10-17T19:30:00Z, values: {humidity: 91.11, precipitationIntensity: 0.12, precipitationProbability: 30, precipitationType: 1, temperature: 15.63, weatherCode: 1001, windSpeed: 4.08}}]*/