import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:tesis_v2/algoritm/algoritm.dart';
import 'package:tesis_v2/models/opening_period_model.dart';
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

  void updateScreen() {
    setState(() {
      places = PreferencesProvider.instance.getPlaces()!;
    });
  }

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
                  flex: 4,
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
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Lugares disponibles: ${places.length}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: places.length,
                          itemBuilder: (context, index) {
                            final place = places[index];
                            Map<String, dynamic> placeDetails =
                                getPlaceDetails(place.type);
                            return Card(
                              elevation: 3,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: CircleAvatar(
                                  radius: 25,
                                  backgroundColor: placeDetails['color'],
                                  child: Icon(
                                    placeDetails[
                                        "icon"], // Icono basado en el tipo de lugar
                                    color:
                                        Colors.white, // Color basado en el tipo
                                    size: 30,
                                  ),
                                ),
                                trailing: IconButton(
                                  onPressed: () {
                                    // Verifica si el sitio es obligatorio
                                    if (place.isMandatory) {
                                      // Muestra el diálogo de alerta
                                      showDIalogRemoveMandatoryPlace(
                                          context, place);
                                    } else {
                                      // Si el lugar no es obligatorio, lo elimina directamente
                                      setState(() {
                                        places.removeWhere((placeRemove) =>
                                            placeRemove.id == place.id);
                                        markers.removeWhere(
                                          (marker) =>
                                              marker.markerId.value ==
                                              place.name,
                                        );
                                      });
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.cancel,
                                    color: Colors.red,
                                    size: 35,
                                  ),
                                ),
                                title: Text(
                                  place.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.star,
                                            color: Colors.amber, size: 18),
                                        const SizedBox(width: 5),
                                        Text(
                                          'Rating: ${place.rating}',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Tipo: ${placeDetails["name"]}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        place.isOutdoor
                                            ? const Icon(Icons.park,
                                                size: 18, color: Colors.teal)
                                            : const Icon(Icons.house,
                                                size: 18, color: Colors.blue),
                                        const SizedBox(width: 5),
                                        Text(
                                          place.isOutdoor
                                              ? 'Al aire libre'
                                              : 'Cubierto',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    //Text(place.weekdayDescriptions.toString()),
                                  ],
                                ),
                                onTap: () {
                                  print(place.toJson());
                                },
                              ),
                            );
                          },
                        ),
                      ),

                      Row(
                        children: [
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
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  NavigationService.instance
                                      .navigatePushName(Algoritm.routeName);
                                  //runAlgoritm();
/*                                   print(initialLocation.latitude);

                                  print(initialLocation.longitude);
                                  print(radius);
                                  DateTime prueba = DateTime(2024, 10, 27);
                                  print((prueba.weekday - 1)); */
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.purple,
                                ),
                                child: const Text('Generar itinerario'),
                              ),
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

  Future<dynamic> showDIalogRemoveMandatoryPlace(
      BuildContext context, PlaceData place) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Eliminar lugar obligatorio"),
          content: const Text(
              "Este lugar fue marcado como obligatorio. ¿Estás seguro que quieres eliminarlo?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
            ),
            TextButton(
              child: const Text("Eliminar"),
              onPressed: () {
                // Elimina el lugar después de confirmar
                setState(() {
                  places
                      .removeWhere((placeRemove) => placeRemove.id == place.id);
                  markers.removeWhere(
                    (marker) => marker.markerId.value == place.name,
                  );
                });
                Navigator.of(context).pop(); // Cierra el diálogo
              },
            ),
          ],
        );
      },
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

              if (place.name == 'Museo del Louvre' &&
                  !addedPlaceNames.contains('Louvre Museum')) {
                addedPlaceNames.add('Louvre Museum');
              }
              if (place.name == 'Louvre Museum' &&
                  !addedPlaceNames.contains('Museo del Louvre')) {
                addedPlaceNames.add('Museo del Louvre');
              }
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
              'places.displayName,places.location,places.rating,places.id,places.regularOpeningHours,places.googleMapsUri'
        };
        final response = await http.post(
          Uri.parse(url),
          headers: headers,
          body: body,
        );
/* 
        debugPrint(response.statusCode.toString());
        debugPrint(response.body);
        print(response.body.isEmpty); */
        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          // Verifica que 'places' no sea null y no esté vacío
          if (data['places'] != null && data['places'].isNotEmpty) {
            final List places = data['places'];

            allMarkers.addAll(places.map((place) {
              final lat = place['location']['latitude'];
              final lng = place['location']['longitude'];
              final name = place['displayName']['text'];
              final googleMapsUri = place['googleMapsUri'] ?? '';
              // Verifica si regularOpeningHours es null
              final regularOpeningHours = place['regularOpeningHours'];
              final weekdayDescriptions = regularOpeningHours != null
                  ? List<String>.from(
                      (regularOpeningHours['weekdayDescriptions']
                                  as List<dynamic>?)
                              ?.map((e) => e.toString()) ??
                          [])
                  : <String>[];

              final List<OpeningPeriod> openingPeriods = (regularOpeningHours?[
                          'periods'] as List<dynamic>?)
                      ?.map((period) {
                        final open = period['open'];
                        final close = period['close'];

                        // Verificar que 'open' y 'close' no sean nulos antes de crear el objeto OpeningPeriod
                        if (open != null && close != null) {
                          return OpeningPeriod(
                            openDay: open['day'] ??
                                0, // Usa un valor por defecto en caso de que 'day' sea null
                            openHour: open['hour'] ?? 0,
                            openMinute: open['minute'] ?? 0,
                            closeDay: close['day'] ?? 0,
                            closeHour: close['hour'] ?? 0,
                            closeMinute: close['minute'] ?? 0,
                          );
                        } else {
                          // Si no hay datos de apertura/cierre, retorna null
                          return null;
                        }
                      })
                      .where((period) =>
                          period != null) // Filtra los elementos nulos
                      .cast<
                          OpeningPeriod>() // Convierte el Iterable a List<OpeningPeriod>
                      .toList() ??
                  [];

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
                  googleMapsUri: googleMapsUri,
                  openingPeriods: openingPeriods,
                );

                //Agregar a la lista de lugares y al conjunto de nombres
                allPLaces.add(newPlace);
                addedPlaceNames.add(name);

                if (name == 'Museo del Louvre' &&
                    !addedPlaceNames.contains('Louvre Museum')) {
                  addedPlaceNames.add('Louvre Museum');
                }
                if (name == 'Louvre Museum' &&
                    !addedPlaceNames.contains('Museo del Louvre')) {
                  addedPlaceNames.add('Museo del Louvre');
                }
              }

              return Marker(
                markerId: MarkerId(name),
                position: LatLng(lat, lng),
                infoWindow: InfoWindow(title: name),
              );
            }).toList());
            //Agregar la respuesta JSON al acumulador
            allJsonResponse += '${response.body}\n\n';
          }
        } else {
          throw Exception('Failed to load places');
        }
        await Future.delayed(const Duration(seconds: 2));
      }
/*       if (PreferencesProvider.instance.getSpecificPoiPreferences() != null) {
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
      } */

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
