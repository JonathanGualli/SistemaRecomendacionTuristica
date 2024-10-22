import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:tesis_v2/models/place_model.dart';
import 'package:tesis_v2/providers/auth_provider.dart';
import 'package:tesis_v2/providers/preferences_provider.dart';
import 'package:tesis_v2/screens/pois_information_screen.dart';
import 'package:tesis_v2/screens/profile_screen.dart';
import 'package:tesis_v2/services/navigation_service.dart';
import 'package:tesis_v2/services/snackbar_service.dart';
import 'package:tesis_v2/utils/dimensions.dart';
import 'package:tesis_v2/utils/place_type_classifier.dart';
import 'package:uuid/uuid.dart';

class SpecificPoiSelectionScreen extends StatefulWidget {
  const SpecificPoiSelectionScreen({super.key});

  static const routeName = "/specificPoiSelection";

  @override
  State<SpecificPoiSelectionScreen> createState() =>
      _SpecificPoiSelectionScreenState();
}

class _SpecificPoiSelectionScreenState
    extends State<SpecificPoiSelectionScreen> {
  final TextEditingController _addressController = TextEditingController();
  AuthProvider? _auth;
  List<dynamic> listForPlaces = [];
  List<PlaceData> places = [];
  String tokenForSession = '123';
  var uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    tokenForSession = uuid.v4();
    _addressController.addListener(() {
      onModify();
    });
  }

  @override
  Widget build(BuildContext context) {
    _auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: Dimensions.screenHeight * 0.4,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.purple,
              ),
              child: Column(
                children: [
                  AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: Padding(
                      padding: const EdgeInsets.only(left: 25),
                      child: GestureDetector(
                        child: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 30,
                        ),
                        onTap: () {
                          NavigationService.instance.goBack();
                        },
                      ),
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: GestureDetector(
                          child: CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.white,
                            child: ClipOval(
                              child: Image(
                                image: NetworkImage(_auth!.user!.photoURL!),
                                fit: BoxFit.cover,
                                //height: 80,
                                //width: 80,
                              ),
                            ),
                          ),
                          onTap: () {
                            NavigationService.instance
                                .navigatePushName(ProfileScreen.routeName);
                          },
                        ),
                      )
                    ],
                  ),
                  const Spacer(
                    flex: 1,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Ya casi terminamos!',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Antes de continuar, ¿Hay algun lugar en específico que quieras visitar?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(
                    flex: 2,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: (Dimensions.screenHeight * 0.4) * 0.80,
            left: 0,
            right: 0,
            child: Container(
              height: Dimensions.screenHeight,
              decoration: BoxDecoration(
                color: Colors.grey[350],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    '¿Escoge un lugar u omitelo?',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: (Dimensions.screenHeight * 0.4) * 0.95,
            left: 0,
            right: 0,
            child: Container(
              height: Dimensions.screenHeight -
                  ((Dimensions.screenHeight * 0.4) * 0.95),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  left: Dimensions.screenWidth * 0.08,
                  right: Dimensions.screenWidth * 0.08,
                  top: Dimensions.screenHeight * 0.03,
                ),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _addressController,
                          decoration: InputDecoration(
                            labelText: 'Ingrese un lugar',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide:
                                  const BorderSide(color: Colors.purple),
                            ),
                            prefixIcon: const Icon(Icons.location_on,
                                color: Colors.purple),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: Dimensions.screenHeight * 0.03),
                          child: const Text(
                            "Tus lugares específicos:",
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        places.isNotEmpty
                            ? Expanded(
                                child: ListView.builder(
                                  itemCount: places.length,
                                  itemBuilder: (context, index) {
                                    var place = places[index];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              //color: lugar['color'],
                                              color: Colors.cyan,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: const Icon(
                                              //lugar['icon'],
                                              Icons.place_sharp,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          Expanded(
                                            flex: 10,
                                            child: Text(
                                              place.name,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  places.removeWhere(
                                                    (placeToRemove) =>
                                                        placeToRemove.id ==
                                                        place.id,
                                                  );
                                                });
                                              },
                                              icon: const Icon(
                                                Icons.cancel,
                                                color: Colors.red,
                                                size: 35,
                                              ))
                                          //const Spacer(),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              )
                            : Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12.0),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.info_outlined,
                                          color: Colors.cyan,
                                          size: 50,
                                        ),
                                        SizedBox(width: 10.0),
                                        Expanded(
                                          child: Text(
                                            "Elige tus destinos obligatorios o déjate guiar por nuestras recomendaciones",
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black54,
                                            ),
                                            overflow: TextOverflow.fade,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Center(
                            child: SizedBox(
                              width: Dimensions.screenWidth * 0.75,
                              child: ElevatedButton(
                                onPressed: () async {
                                  //print("paso por aqui");
                                  if (places.isNotEmpty) {
                                    PreferencesProvider.instance
                                        .setSpecificPoiPreferences(places);
                                  }
                                  NavigationService.instance.navigatePushName(
                                      PoisInformation.routeName);
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.purple,
                                ),
                                child: places.isNotEmpty
                                    ? const Text('Continuar')
                                    : const Text("Omitir"),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      top: 55,
                      left: 15,
                      right: 15,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.purple[100],
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(0),
                          itemCount: listForPlaces.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              onTap: () async {
                                setState(() {
                                  if (places.any((place) =>
                                      place.id == listForPlaces[index]['id'])) {
                                    SnackBarService.instance.showSnackBar(
                                        "Lugar ya seleccionado", false);
                                  } else {
                                    final regularOpeningHours =
                                        listForPlaces[index]
                                            ['regularOpeningHours'];
                                    final weekdayDescriptions =
                                        regularOpeningHours != null
                                            ? List<
                                                String>.from((regularOpeningHours[
                                                            'weekdayDescriptions']
                                                        as List<dynamic>?)
                                                    ?.map(
                                                        (e) => e.toString()) ??
                                                [])
                                            : <String>[];
                                    final type =
                                        listForPlaces[index]['primaryType'];
                                    places.add(
                                      PlaceData(
                                        id: listForPlaces[index]['id'],
                                        name: listForPlaces[index]
                                            ['displayName']['text'],
                                        coordinates: LatLng(
                                            listForPlaces[index]['location']
                                                ['latitude'],
                                            listForPlaces[index]['location']
                                                ['longitude']),
                                        rating: listForPlaces[index]['rating']
                                            .toString(),
                                        type: type,
                                        weekdayDescriptions:
                                            weekdayDescriptions,
                                        isOutdoor:
                                            PlaceTypeClassifier.isOutdoor(type),
                                        isMandatory: true,
                                        urlImages: List.empty(growable: true),
                                        googleMapsUri: '',
                                      ),
                                    );
                                  }

                                  listForPlaces.clear();
                                  _addressController.clear();
                                  //places.add(PlaceData(id: , name: name, coordinates: coordinates, rating: rating, type: type))
                                });
                              },
                              title: Text(
                                  listForPlaces[index]['displayName']['text']),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void makeSuggestion(String input) async {
    String googlePlacesApiKey = 'AIzaSyBlS_zZbl-suYNlnxpUHJKR2jqJ49Quspo';
    String url = 'https://places.googleapis.com/v1/places:searchText';

    double latitude = 0;
    double longitude = 0;
    double radius = 0;

    if (PreferencesProvider.instance.getSelectedCity() == 'París') {
      latitude = 48.8566;
      longitude = 2.3522;
      radius = 9000.0;
    } else {
      latitude = 51.5074;
      longitude = -0.1278;
      radius = 20000.0;
    }
    var responseResult = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': googlePlacesApiKey,
        'X-Goog-FieldMask':
            'places.displayName,places.formattedAddress,places.id,places.location,places.rating,places.primaryType,places.regularOpeningHours'
      },
      body: json.encode({
        'textQuery': input,
        'pageSize': 6,
        'languageCode': 'es',
        'locationBias': {
          'circle': {
            'center': {
              'latitude': latitude, // Centro de París
              'longitude': longitude, // Centro de París
            },
            'radius': radius, // Radio en metros (10 km)
          },
        },
      }),
    );

    //print(responseResult.body);

    if (responseResult.statusCode == 200) {
      setState(() {
        listForPlaces = jsonDecode(responseResult.body.toString())['places'];
      });
    } else {
      throw Exception('Algo salió mal, inténtalo de nuevo');
    }
  }

  void onModify() {
    makeSuggestion(_addressController.text);
  }
}
