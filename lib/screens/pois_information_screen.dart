import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:tesis_v2/algoritm/algoritm.dart';
import 'package:tesis_v2/models/place_model.dart';
import 'package:tesis_v2/providers/preferences_provider.dart';
import 'package:tesis_v2/screens/climate_information_screen.dart';
import 'package:tesis_v2/services/navigation_service.dart';
import 'package:tesis_v2/utils/place_type_classifier.dart';
import 'package:tesis_v2/utils/places_list.dart';

class PoisInformation extends StatefulWidget {
  const PoisInformation({super.key});
  static const routeName = "/Pois";

  @override
  State<PoisInformation> createState() => _PoisInformationState();
}

class _PoisInformationState extends State<PoisInformation> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController ratingController = TextEditingController();

  String city = PreferencesProvider.instance.getSelectedCity()!;
  LatLng initialLocation = PreferencesProvider.instance
      .getInitialLocation()!; // Punto inicial dentro de París
  double radius =
      PreferencesProvider.instance.getRadius(); // Radio en metros (3 km)
  late List<String> types = PreferencesProvider.instance.getPreferences()!;

  List<Marker> markers = [];
  List<PlaceData> places = []; //Lista de lugares
  bool isLoading = true; // Variable para indicar si se está cargando
  String currentType =
      "art_gallery"; // no importa, no afecta se actualiara luego a los tipos de la lista types.

  String jsonResponse = '';

  @override
  void initState() {
    super.initState();

    fetchNearbyPlaces();
  }

  @override
  Widget build(BuildContext context) {
    final placeDetails = getPlaceDetails(currentType);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          city == 'Paris' ? 'París' : 'Londres',
          style: const TextStyle(
              fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: GestureDetector(
              child: const Icon(Icons.sunny),
              onTap: () {
                NavigationService.instance
                    .navigatePushName(ClimateInformationScreen.routeName);
              },
            ),
          )
        ],
      ),
      body: isLoading
          ? visualIndicator(placeDetails)
          : Column(
              children: [
                Expanded(
                  child: GoogleMap(
                    markers: Set.from(
                        markers), //Se markan visualmente los puntos de interes en el mapa
                    initialCameraPosition: CameraPosition(
                      target: initialLocation, //Definida por el turista
                      zoom: 14.0,
                    ),
                    onMapCreated: (GoogleMapController controller) {},
                    zoomControlsEnabled: true,
                    compassEnabled: true,
                    circles: {
                      Circle(
                        //Se traza visualmente un circulo en el mapa
                        circleId: const CircleId("radius"),
                        //center: LatLng(51.5074, -0.1278),
                        center:
                            initialLocation, //El turista define el punto de partida
                        radius: radius,
                        fillColor: Colors.blue.withOpacity(0.3),
                        strokeColor: Colors.blue,
                        strokeWidth: 1,
                      )
                    },
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Lista de Lugares, total lugares: ${places.length}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: places.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(places[index].name),
                              subtitle: Text(
                                  'Rating: ${places[index].rating.toString()} Type: ${places[index].type.toString()} IsOutdoor: ${places[index].isOutdoor}'),
                              onTap: () {
                                // Implementa lo que quieras hacer al hacer tap en un lugar de la lista
                              },
                            );
                          },
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                /* if (ratingController.text.isEmpty) {
                                  SnackBarService.instance
                                      .showSnackBar("Ingresa un valor", false);
                                } else {
                                  setState(() {
                                    double inputRating =
                                        double.parse(ratingController.text);
                                    places = places.where((place) {
                                      // ignore: unnecessary_null_comparison
                                      if (place.rating == null) {
                                        return false;
                                      }
                                      double? placeRating =
                                          double.tryParse(place.rating);
                                      if (placeRating == null) {
                                        return false;
                                      }
                                      return placeRating >= inputRating;
                                    }).toList();
                                  });
                                } */
                                print("prueba de datos:");
                                print(PreferencesProvider.instance
                                    .getInitialLocation());
                                print(PreferencesProvider.instance.getDate());
                                print(
                                    PreferencesProvider.instance.getEndTime());
                                print(PreferencesProvider.instance
                                    .getPreferences());
                                print(PreferencesProvider.instance.getRadius());
                                print(PreferencesProvider.instance
                                    .getSelectedCity());

                                print(PreferencesProvider.instance
                                    .getStartTIme());
                                printPlaceData(
                                    PreferencesProvider.instance.getPlaces()!);
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.purple,
                              ),
                              child: const Text('Comprobar datos'),
                            ),
                          ),
                          /*  Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Form(
                                key: formKey,
                                onChanged: () {
                                  formKey.currentState!.save();
                                },
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  controller: ratingController,
                                ),
                              ),
                            ),
                          ) */
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                NavigationService.instance
                                    .navigatePushName(Algoritm.routeName);
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.purple,
                              ),
                              child: const Text('Generar itinerario'),
                            ),
                          ),
                        ],
                      ),
                      //jsonResponseWidget()
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Center visualIndicator(Map<String, dynamic> placeDetails) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        placeDetails["color"].withOpacity(0.6),
                        placeDetails["color"]
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: placeDetails["color"].withOpacity(0.6),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    placeDetails["icon"],
                    color: Colors.white,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Cargando puntos de interés de: ${placeDetails["name"]}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(placeDetails["color"]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Expanded jsonResponseWidget() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const Text(
            'Respuesta JSON:',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  jsonResponse,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> fetchNearbyPlaces() async {
    const apiKey = "AIzaSyBlS_zZbl-suYNlnxpUHJKR2jqJ49Quspo";
    const url = 'https://places.googleapis.com/v1/places:searchNearby';

    List<Marker> allMarkers = [];
    List<PlaceData> allPLaces = []; //Lista de lugares recividos
    String allJsonResponse = '';

    Set<String> addedPlaceNames =
        // ignore: prefer_collection_literals
        Set(); //Conjunto para almacenar nombres de lugares únicos

    Future<void> fetchTypes(List<String> types) async {
      for (String type in types) {
        setState(() {
          currentType = type;
        });

        final body = jsonEncode({
          "includedPrimaryTypes": [type],
          "maxResultCount": 10,
          "locationRestriction": {
            "circle": {
              "center": {
                "latitude": initialLocation.latitude,
                "longitude": initialLocation.longitude
              },
              "radius": radius
            }
          }
        });

        final headers = {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': apiKey,
          'X-Goog-FieldMask':
              'places.displayName,places.location,places.rating,places.id,places.regularOpeningHours'
        };
        final response = await http.post(
          Uri.parse(url),
          headers: headers,
          body: body,
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          final List places = data['places'];

          allMarkers.addAll(places.map((place) {
            final lat = place['location']['latitude'];
            final lng = place['location']['longitude'];
            final name = place['displayName']['text'];
            // Verifica si regularOpeningHours es null
            final regularOpeningHours = place['regularOpeningHours'];
            final weekdayDescriptions = regularOpeningHours != null
                ? List<String>.from((regularOpeningHours['weekdayDescriptions']
                            as List<dynamic>?)
                        ?.map((e) => e.toString()) ??
                    [])
                : <String>[];
            //Verificamos si un lugar ya ha sido agregado
            if (!addedPlaceNames.contains(name)) {
              //Creaer un objeto place
              final newPlace = PlaceData(
                id: place['id'],
                name: name,
                coordinates: LatLng(lat, lng),
                rating: place['rating'].toString(),
                type: type,
                weekdayDescriptions: weekdayDescriptions,
                isOutdoor: PlaceTypeClassifier.isOutdoor(type),
                isMandatory: false,
                urlImages: List.empty(growable: true),
              );

              //Agregar a la lista de lugares y al conjunto de nombres
              allPLaces.add(newPlace);
              addedPlaceNames.add(name);
            }

            return Marker(
              markerId: MarkerId(name),
              position: LatLng(lat, lng),
              infoWindow: InfoWindow(title: name),
            );
          }).toList());
          //Agregar la respuesta JSON al acumulador
          allJsonResponse += '${response.body}\n\n';
        } else {
          throw Exception('Failed to load places');
        }
        await Future.delayed(const Duration(seconds: 2));
      }
      if (PreferencesProvider.instance.getSpecificPoiPreferences() != null) {
        List<PlaceData> specificPlaces =
            PreferencesProvider.instance.getSpecificPoiPreferences()!;
        allMarkers.addAll(
          specificPlaces.map(
            (place) {
              //Verificamos si un lugar ya ha sido agregado
              if (!addedPlaceNames.contains(place.name)) {
                //Agregar a la lista de lugares y al conjunto de nombres
                allPLaces.add(place);
                addedPlaceNames.add(place.name);
              }
              return Marker(
                markerId: MarkerId(place.name),
                position: place.coordinates,
                infoWindow: InfoWindow(
                  title: place.name,
                  snippet: 'Rating: ${place.rating}',
                ),
              );
            },
          ),
        );
      }

      setState(() {
        markers = allMarkers;
        markers.add(Marker(
          markerId: MarkerId("Punto de partida"),
          position: initialLocation,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: 'Punto de Partida',
            snippet: 'Este es el punto de inicio de tu ruta',
          ),
        ));
        jsonResponse = allJsonResponse;
        places = allPLaces;
        PreferencesProvider.instance.setPlaces(places);
        isLoading = false;
      });
    }

    await fetchTypes(types);
  }

  void printPlaceData(List<PlaceData> places) {
    for (var place in places) {
      print('ID: ${place.id}');
      print('Name: ${place.name}');
      print(
          'Coordinates: (${place.coordinates.latitude}, ${place.coordinates.longitude})');
      print('Rating: ${place.rating}');
      print('Type: ${place.type}');
      print('hours: ${place.weekdayDescriptions}');
      print('isOutdoor: ${place.isOutdoor}');
      print('isMandatory: ${place.isMandatory}');
      print('-------------------');
    }
  }
}
