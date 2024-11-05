import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:tesis_v2/models/place_model.dart';
import 'package:tesis_v2/providers/preferences_provider.dart';
import 'package:http/http.dart' as http;
import 'package:tesis_v2/screens/climate_information_screen.dart';
import 'package:tesis_v2/services/navigation_service.dart';
import 'package:tesis_v2/utils/climate_codes.dart';
import 'dart:convert';

import 'package:tesis_v2/utils/places_list.dart';
import 'package:url_launcher/url_launcher.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  static const routeName = '/resultScreen';

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  LatLng initialLocation = PreferencesProvider.instance.getInitialLocation()!;
  List<Marker> markers = [];
  List<PlaceData> resultPlaces = PreferencesProvider.instance.getResultPlaces();
  List<Polyline> polylines = []; // Lista para almacenar las líneas de ruta
  double radius = PreferencesProvider.instance.getRadius();
  List<Map<String, dynamic>> groupedData =
      PreferencesProvider.instance.groupedData;

  BitmapDescriptor?
      customStartIcon; // Ícono personalizado para el punto de partida
  late GoogleMapController mapController; // Controlador del mapa

  @override
  void initState() {
    super.initState();
    _fetchInfoPlaces();
    _createMarkers();
    _createRoute(); // Crear la ruta entre los lugares
    _loadCustomStartIcon(); // Cargar el ícono personalizado
  }

  @override
  void dispose() {
    resultPlaces = [];
    markers = [];
    polylines = [];
    mapController.dispose();
    debugPrint('Disposed');
    super.dispose();
  }

  // Cargar el ícono personalizado
  void _loadCustomStartIcon() async {
    // ignore: deprecated_member_use
    customStartIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/mapsIcons/house.png',
    );
    setState(() {});
  }

  // Crear marcadores para cada lugar
  void _createMarkers() {
    // Marcador para el punto de partida (initialLocation)
    markers.add(
      Marker(
        markerId: const MarkerId('initialLocation'),
        position: initialLocation,
        icon: customStartIcon ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(
          title: 'Punto de Partida',
          snippet: 'Este es el punto de inicio de tu ruta',
        ),
      ),
    );

    int i = 1;

    for (var place in resultPlaces) {
      Marker marker = Marker(
        markerId: MarkerId(place.name),
        position: place.coordinates,
        infoWindow: InfoWindow(
          title: place.name,
        ),
      );
      markers.add(marker);
      i++;
    }
  }

  void _createRoute() {
    List<LatLng> routeCoordinates =
        resultPlaces.map((place) => place.coordinates).toList();

    routeCoordinates.insert(0, initialLocation);
    //routeCoordinates.add(initialLocation);

    Polyline route = Polyline(
      polylineId: const PolylineId('route'),
      points: routeCoordinates,
      color: Colors.blue,
      width: 5,
    );

    polylines.add(route);
  }

  void _moveCameraToPlace(PlaceData place) async {
    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(place.coordinates, 15.0),
    );
    mapController.showMarkerInfoWindow(MarkerId(place.name));

    try {} catch (e) {
      debugPrint('Error fetching place details: $e');
    }
  }

  void _fetchInfoPlaces() async {
    for (var place in resultPlaces) {
      if (place.urlImages.isEmpty) {
        final details = await fetchPlaceDetails(place.id);
        setState(() {
          place.urlImages.addAll(getPhotoUrls(details));
          //print(details['googleMapsUri']);
          //place.googleMapsUri = details['googleMapsUri'];
          //place.setGoogleMapsUri(details['googleMapsUri']);
          //place.setImages();
        });
      }
    }
  }

  Future<Map<String, dynamic>> fetchPlaceDetails(String placeId) async {
    //await Future.delayed(const Duration(seconds: 1));
    const apiKey = 'AIzaSyBlS_zZbl-suYNlnxpUHJKR2jqJ49Quspo';
    final url = 'https://places.googleapis.com/v1/places/$placeId';

    final headers = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': apiKey,
      'X-Goog-FieldMask': 'id,displayName,photos,googleMapsUri'
    };

    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );
    //print(response.body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load place details');
    }
  }

  String getPhotoUrl(Map<String, dynamic> details) {
    if (details['photos'] != null && details['photos'].isNotEmpty) {
      String photoReference = details['photos'][0]['name'];
      String photoReferenceExtracted = photoReference.split('/').last;
      return 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoReferenceExtracted&key=AIzaSyBlS_zZbl-suYNlnxpUHJKR2jqJ49Quspo'; // Reemplaza con tu API Key
    }
    return '';
  }

  List<String> getPhotoUrls(Map<String, dynamic> details) {
    if (details['photos'] != null && details['photos'].isNotEmpty) {
      List<String> photoUrls = [];

      for (var photo in details['photos']) {
        String photoReference = photo['name'];
        String photoReferenceExtracted = photoReference.split('/').last;
        String photoUrl =
            'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoReferenceExtracted&key=AIzaSyBlS_zZbl-suYNlnxpUHJKR2jqJ49Quspo'; // Reemplaza con tu API Key
        photoUrls.add(photoUrl);
      }

      return photoUrls;
    }

    return List.empty(growable: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Itinerario',
          style: TextStyle(
              fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    mapController = controller;
                  },
                  markers: Set.from(markers),
                  polylines: Set.from(polylines),
                  initialCameraPosition: CameraPosition(
                    target: initialLocation,
                    zoom: 14.0,
                  ),
                  zoomControlsEnabled: false,
                  compassEnabled: true,
                  circles: {
                    Circle(
                      circleId: const CircleId("radius"),
                      center: initialLocation,
                      radius: radius,
                      fillColor: Colors.blue.withOpacity(0.3),
                      strokeColor: Colors.blueAccent,
                      strokeWidth: 2,
                    )
                  },
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: FloatingActionButton(
                    onPressed: () {
                      mapController.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(target: initialLocation, zoom: 14.0),
                        ),
                      );
                    },
                    backgroundColor: Colors.blueAccent,
                    child: const Icon(Icons.my_location),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 6,
            child: Column(
              children: [
                const Spacer(
                  flex: 1,
                ),
                Expanded(
                  flex: 8,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: resultPlaces.length,
                    itemBuilder: (context, index) {
                      final place = resultPlaces[index];
                      Map<String, dynamic> placeDetails =
                          getPlaceDetails(place.type);
                      return Column(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Center(
                              child: Column(
                                children: [
                                  Text(
                                    formatStartEndTime(
                                      groupedData[index]['startTime'],
                                      groupedData[index]['endTime'],
                                    ),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      NavigationService.instance
                                          .navigatePushName(
                                              ClimateInformationScreen
                                                  .routeName);
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Clima: ',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black54),
                                        ),
                                        groupedData[index]['code'] == 4200
                                            ? Image.network(
                                                _getWeatherIconUrl(
                                                  groupedData[index]['code']
                                                      .toString(),
                                                ),
                                                height: 30,
                                              )
                                            : SvgPicture.network(
                                                _getWeatherIconUrl(
                                                  groupedData[index]['code']
                                                      .toString(),
                                                ),
                                                height: 30,
                                              ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${groupedData[index]["maxPrecipitationProbability"]}%',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: groupedData[index][
                                                        "maxPrecipitationProbability"] >
                                                    25
                                                ? Colors.red
                                                : Colors
                                                    .blue, // Color del porcentaje
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  //Text('Prob')
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 10,
                            child: GestureDetector(
                              onTap: () {
                                _moveCameraToPlace(place);
                                print(place.id);
                                print(place.googleMapsUri);
                                print(place.isMandatory);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 6,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                  image: place.urlImages.isNotEmpty
                                      ? DecorationImage(
                                          image: NetworkImage(
                                              place.urlImages.first),
                                          fit: BoxFit.cover,
                                        )
                                      : const DecorationImage(
                                          image: AssetImage(
                                              'assets/colorImage.jpg'),
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                width: 160,
                                child: Stack(
                                  children: [
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.only(
                                            bottomLeft: Radius.circular(15),
                                            bottomRight: Radius.circular(15),
                                          ),
                                          color: Colors.black.withOpacity(0.7),
                                        ),
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              place.name,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 5),
                                            Row(
                                              children: [
                                                const Icon(Icons.star,
                                                    color: Colors.yellowAccent,
                                                    size: 16),
                                                Text(
                                                  place.rating == 'null'
                                                      ? ' Sin información'
                                                      : ' ${place.rating}',
                                                  style: const TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 12),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Icon(
                                                  placeDetails[
                                                      "icon"], // Icono basado en el tipo de lugar
                                                  color: placeDetails[
                                                      "color"], // Color basado en el tipo
                                                  size: 16,
                                                ),
                                                const SizedBox(width: 5),
                                                Text(
                                                  placeDetails[
                                                      "name"], // Nombre personalizado del lugar
                                                  style: const TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 12),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Icon(
                                                  place.isOutdoor
                                                      ? Icons.wb_sunny
                                                      : Icons.home,
                                                  color: Colors.white70,
                                                  size: 16,
                                                ),
                                                Text(
                                                  place.isOutdoor
                                                      ? ' Al aire libre'
                                                      : ' Cubierto',
                                                  style: const TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 12),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      child: IconButton(
                                        onPressed: () {
                                          dialogImages(context, place);
                                        },
                                        icon: const Icon(
                                          Icons.photo_library,
                                          color: Colors.pinkAccent,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 0,
                                      child: IconButton(
                                        onPressed: () async {
                                          final Uri googleMapsUri =
                                              Uri.parse(place.googleMapsUri);
                                          if (await canLaunchUrl(
                                              googleMapsUri)) {
                                            await launchUrl(googleMapsUri);
                                          } else {
                                            print(
                                                'No se pudo abrir el enlace a Google Maps');
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.location_on,
                                          color: Colors.pinkAccent,
                                          size: 30,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Spacer(
                            flex: 1,
                          )
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<dynamic> dialogImages(BuildContext context, PlaceData place) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(
                0.7,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Imágenes de ${place.name} (${place.urlImages.length})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 300,
                  child: place.urlImages.isNotEmpty
                      ? Stack(
                          children: [
                            PageView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: place.urlImages.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.network(
                                      place.urlImages[index],
                                      fit: BoxFit.cover,
                                      loadingBuilder: (BuildContext context,
                                          Widget child,
                                          ImageChunkEvent? loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        } else {
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      (loadingProgress
                                                              .expectedTotalBytes ??
                                                          1)
                                                  : null,
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                          ],
                        )
                      : const Center(
                          child: Text(
                            'No hay imágenes disponibles',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                ),
                const SizedBox(height: 10),
                // Botones de navegación izquierda y derecha
                /* Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ), */
              ],
            ),
          ),
        );
      },
    );
  }

  String formatStartEndTime(String startTime, String endTime) {
    // Convertir las cadenas ISO 8601 a DateTime
    DateTime startDateTime = DateTime.parse(startTime);
    DateTime endDateTime = DateTime.parse(endTime);

    // Formatear la hora
    String startFormatted = DateFormat.jm().format(startDateTime);
    String endFormatted = DateFormat.jm().format(endDateTime);

    return '$startFormatted - $endFormatted';
  }

  String _getWeatherIconUrl(String weatherCode) {
    if (weatherCodes.containsKey(weatherCode)) {
      return weatherCodes[weatherCode]!["icon"] ?? '';
    }

    return '';
  }
}
