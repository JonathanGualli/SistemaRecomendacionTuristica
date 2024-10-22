import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Importa la clase LatLng de la biblioteca de mapas adecuada
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tesis_v2/providers/preferences_provider.dart';
import 'package:tesis_v2/services/climate_service.dart';
import 'package:tesis_v2/utils/climate_codes.dart';

class ClimateInformationScreen extends StatefulWidget {
  const ClimateInformationScreen({Key? key}) : super(key: key);

  static const routeName = "/climate";

  @override
  _ClimateInformationScreenState createState() =>
      _ClimateInformationScreenState();
}

class _ClimateInformationScreenState extends State<ClimateInformationScreen> {
  /* // Variables para los parámetros de la API
  static const String baseUrl = 'https://api.tomorrow.io/v4/timelines';
  static const String apiKey = 'BscDaxFAClp2E1BUuukcBE3Irw2M1km4';
  static const String fields =
      'precipitationIntensity,precipitationProbability,temperature,windSpeed,humidity,precipitationType,weatherCode';
  static const String startTime = '2024-10-17T08:00:00Z';
  static const String endTime = '2024-10-17T20:00:00Z';
  static const String units = 'metric';

  // Coordenadas de latitud y longitud (ejemplo: Quito, Ecuador)
  LatLng locationLatLng = PreferencesProvider.instance
      .getInitialLocation()!; // Cambia estas coordenadas según tu ubicación

  // URL completa de la API utilizando las coordenadas de latitud y longitud
  late String apiUrl;

  // Variable para almacenar los datos del clima
  List<dynamic>? climateDataList;

  // Método para construir la URL de la API basada en las coordenadas LatLng
  String buildApiUrl() {
    // ignore: prefer_interpolation_to_compose_strings
    apiUrl =
        '$baseUrl?location=${locationLatLng.latitude},${locationLatLng.longitude}'
        '&fields=$fields'
        '&timesteps=30m'
        //'&timesteps=1h' +
        '&startTime=$startTime'
        '&endTime=$endTime'
        '&units=$units'
        '&apikey=$apiKey';
    return apiUrl;
  }

  // Método para obtener los datos del clima desde la APID
  Future<void> fetchClimateData() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Si la solicitud es exitosa, decodificar el JSON
        print(response.body);
        setState(() {
          climateDataList =
              json.decode(response.body)['data']['timelines'][0]['intervals'];
        });
      } else {
        throw Exception('Failed to load climate data');
      }
    } catch (error) {
      print('Error fetching climate data: $error');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content:
                Text('Failed to fetch climate data. Please try again later.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
 */

  List<dynamic>? climateDataList;
  final ClimateService _climateService = ClimateService();
  LatLng locationLatLng = PreferencesProvider.instance.getInitialLocation()!;
  String dateStart = PreferencesProvider.instance.getStartTIme()!;
  String dateEnd = PreferencesProvider.instance.getEndTime()!;

  Future<void> fetchClimateData() async {
    climateDataList = await _climateService.fetchClimateData(
      locationLatLng,
      dateStart,
      dateEnd,
    );
    setState(() {}); // Actualiza la UI con los nuevos datos
  }

  @override
  void initState() {
    super.initState();
    //buildApiUrl(); // Construye la URL de la API al iniciar la pantalla
    fetchClimateData(); // Obtiene los datos del clima al iniciar la pantalla
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Climate Information'),
      ),
      body: climateDataList == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16.0),
              itemCount: climateDataList!.length,
              itemBuilder: (BuildContext context, int index) {
                var climateData = climateDataList![index]['values'];
/*                 var forecastTime =
                    DateTime.parse(climateDataList![index]['startTime'])
                        .toLocal(); */

                return Card(
                  elevation: 4.0,
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          //'Forecast Time: ${_formatDateTime(forecastTime)}',
                          'Tiempo: ${climateDataList![index]['startTime']}',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        _buildClimateInfoRow(
                            'Temperature', '${climateData['temperature']} °C'),
                        _buildClimateInfoRow('Precipitation Probability',
                            '${climateData['precipitationProbability']} %'),
                        _buildClimateInfoRow(
                            'Wind Speed', '${climateData['windSpeed']} m/s'),
                        _buildClimateInfoRow(
                            'humidity', '${climateData['humidity']}'),
                        _buildClimateInfoRow('precipitationType',
                            '${climateData['precipitationType']}'),
                        _buildClimateInfoRow(
                            'Weather Code', '${climateData['weatherCode']}'),
                        climateData['weatherCode'] == '4200'
                            ? Image.network(
                                _getWeatherIconUrl(
                                  climateData['weatherCode'].toString(),
                                ),
                              )
                            : SvgPicture.network(
                                _getWeatherIconUrl(
                                  climateData['weatherCode'].toString(),
                                ),
                              ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildClimateInfoRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.0,
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }

  // Método para obtener la URL del icono basado en el código del clima
  String _getWeatherIconUrl(String weatherCode) {
    // Verifica si el código de clima está en el mapa
    if (weatherCodes.containsKey(weatherCode)) {
      //print(weatherCodes[weatherCode]!["icon"]);
      return weatherCodes[weatherCode]!["icon"] ?? '';
    }

    // Devuelve una URL vacía si el código no se encuentra
    return '';
  }
}
