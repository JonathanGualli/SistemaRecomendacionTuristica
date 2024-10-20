import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:geocoding/geocoding.dart';
import 'package:tesis_v2/controllers/maps_controller.dart';
import 'package:tesis_v2/providers/preferences_provider.dart';
import 'package:tesis_v2/screens/preferences_selection_screen.dart';
import 'package:tesis_v2/services/navigation_service.dart';
import 'package:tesis_v2/services/snackbar_service.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class SelectInitialPointScreen extends StatefulWidget {
  const SelectInitialPointScreen({super.key});

  static const routeName = "/home";

  @override
  State<SelectInitialPointScreen> createState() =>
      _SelectInitialPointScreenState();
}

class _SelectInitialPointScreenState extends State<SelectInitialPointScreen> {
  late String city;
  final TextEditingController _addressController = TextEditingController();
  LatLng? latLngIngresada;
  String tokenForSession = '123';
  var uuid = const Uuid();
  List<dynamic> listForPlaces = [];

  @override
  void initState() {
    super.initState();
    tokenForSession = uuid.v4();
    _addressController.addListener(() {
      onModify();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as String;
    city = args;
    //print(city);
  }

  @override
  Widget build(BuildContext context) {
    SnackBarService.instance.buildContext = context;
    return ChangeNotifierProvider<MapsController>(
      create: (_) => MapsController(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            city == 'Paris' ? 'París' : 'Londres',
            style: const TextStyle(
                fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
        ),
        body: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 15),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _addressController,
                            decoration: const InputDecoration(
                              labelText: 'Ingrese la dirección',
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.purple),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            // Lógica para confirmar el punto de partida
                            // ignore: avoid_print
                            print(
                                'Dirección ingresada: ${_addressController.text}');
                            //print('latlng: ${latLngIngresada}');
                            if (_addressController.text != '') {
                              PreferencesProvider.instance
                                  .setSelectedCity(city);
                              PreferencesProvider.instance
                                  .setInitialLocation(latLngIngresada!);
                              NavigationService.instance.navigatePushName(
                                  PreferencesSelectionScreen.routeName);
                            } else {
                              SnackBarService.instance.showSnackBar(
                                  "Por favor, ingresa un punto de partida",
                                  false);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.purple,
                          ),
                          child: const Text('Confirmar'),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Consumer<MapsController>(
                    builder: (_, controller, __) => GoogleMap(
                      markers: controller.markers,
                      initialCameraPosition: city == "Paris"
                          ? controller.initialCameraPositionParis
                          : controller.initialCameraPositionLondres,
                      onTap: city == "Paris"
                          ? (position) async {
                              String direction;
                              direction = await controller.onTapParis(position);
                              if (direction != '') {
                                setState(() {
                                  _addressController.text = direction;
                                  latLngIngresada = position;
                                  listForPlaces.clear();
                                });
                              }
                            }
                          : (position) async {
                              String direction;
                              direction =
                                  await controller.onTapLondon(position);
                              if (direction != '') {
                                setState(() {
                                  _addressController.text = direction;
                                  latLngIngresada = position;
                                  listForPlaces.clear();
                                });
                              }
                            },
                      onMapCreated: controller.onMapCreated,
                      zoomControlsEnabled: true,
                      compassEnabled: true,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.blue[50],
                  child: Row(
                    children: [
                      Icon(
                        Icons.info,
                        color: Colors.blue[700],
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Seleccione un punto de partida en el mapa o ingrese la dirección:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (listForPlaces.isNotEmpty)
              Consumer<MapsController>(
                builder: (_, controller, __) => Positioned(
                  top: 80, // Ajusta este valor según tu diseño
                  left: 15,
                  right: 15,
                  child: Container(
                    color: Colors.white,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: listForPlaces.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          onTap: () async {
                            String selectedAddress =
                                listForPlaces[index]['description'];
                            _addressController.text = selectedAddress;
                            List<Location> locations =
                                await locationFromAddress(selectedAddress);
                            if (locations.isNotEmpty) {
                              if (city == "Paris") {
                                controller.onTapParis(LatLng(
                                    locations.first.latitude,
                                    locations.first.longitude));
                                listForPlaces.clear();
                              } else {
                                controller.onTapLondon(LatLng(
                                    locations.first.latitude,
                                    locations.first.longitude));
                                listForPlaces.clear();
                              }
                            }
                          },
                          title: Text(listForPlaces[index]['description']),
                        );
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void makeSuggestion(String input) async {
    String googlePlacesApiKey = 'AIzaSyBlS_zZbl-suYNlnxpUHJKR2jqJ49Quspo';
    String groundURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request =
        '$groundURL?input=$input&key=$googlePlacesApiKey&sessiontoken=$tokenForSession';

    var responseResult = await http.get(Uri.parse(request));

    //var resultdata = responseResult.body.toString();

    // ignore: avoid_print
    //print('Reuslt Data');
    // ignore: avoid_print
    //print(resultdata);

    if (responseResult.statusCode == 200) {
      setState(() {
        https: //maps.googleapis.com/maps/api/place/autocomplete/json?
        listForPlaces =
            jsonDecode(responseResult.body.toString())['predictions'];
      });
    } else {
      throw Exception('Algo salió mal, intentalo denuevo');
    }
  }

  void onModify() {
    makeSuggestion(_addressController.text);
  }
}
