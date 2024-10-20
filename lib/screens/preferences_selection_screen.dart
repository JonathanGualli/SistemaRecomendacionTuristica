import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tesis_v2/providers/auth_provider.dart';
import 'package:tesis_v2/providers/preferences_provider.dart';
import 'package:tesis_v2/screens/profile_screen.dart';
import 'package:tesis_v2/screens/schedule_selection_screen.dart';
import 'package:tesis_v2/services/db_service.dart';
import 'package:tesis_v2/services/navigation_service.dart';
import 'package:tesis_v2/services/snackbar_service.dart';
import 'package:tesis_v2/utils/dimensions.dart';
import 'package:tesis_v2/utils/places_list.dart';

class PreferencesSelectionScreen extends StatefulWidget {
  const PreferencesSelectionScreen({super.key});

  static const routeName = "/preferencesSelection";

  @override
  State<PreferencesSelectionScreen> createState() =>
      _PreferencesSelectionScreenState();
}

class _PreferencesSelectionScreenState
    extends State<PreferencesSelectionScreen> {
  AuthProvider? _auth;

  // Estado de los checkboxes
  final Map<String, bool> _lugaresSeleccionados = {};

  //Para la animacion de desplazamiento
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Inicializar todos los valores de los lugares en false
    for (var lugar in PlacesList().lugares) {
      _lugaresSeleccionados[lugar['type']] = false;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animateScroll();
    });
  }

  void _animateScroll() async {
    //Desplazamiento hacia abajo
    await _scrollController.animateTo(50.0,
        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    // Desplazamiento hacia arriba
    await _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '¿Qué tal, ${_auth!.user!.displayName!.split(" ")[0]}?',
                        style: const TextStyle(
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
                        'Vamos a personalizar aún más tu experiencia',
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
                    '¿Qué te gustaría visitar?',
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
              child: Column(
                children: [
                  Expanded(
                    flex: 5,
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(20.0),
                      itemCount: PlacesList().lugares.length,
                      itemBuilder: (context, index) {
                        var lugar = PlacesList().lugares[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 30),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: lugar['color'],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  lugar['icon'],
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
                                  lugar['name'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Checkbox(
                                value: _lugaresSeleccionados[lugar['type']],
                                onChanged: (bool? value) {
                                  setState(() {
                                    _lugaresSeleccionados[lugar['type']] =
                                        value!;
                                    //imprimirSeleccionados();
                                  });
                                },
                                activeColor: Colors.purple,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: SizedBox(
                        width: Dimensions.screenWidth * 0.75,
                        child: ElevatedButton(
                          onPressed: () {
                            final seleccionados = _lugaresSeleccionados.entries
                                .where((entry) => entry.value)
                                .map((entry) => entry.key)
                                .toList();

                            if (seleccionados.isNotEmpty) {
                              //_showBottomSheet();
                              DBService.instance
                                  .updatePreferencesInDB(seleccionados)
                                  .then(
                                (value) {
                                  SnackBarService.instance
                                      .showSnackBar("guardado existoso", true);
                                  PreferencesProvider.instance
                                      .setPreferences(seleccionados);
                                  // ignore: avoid_print
                                  print(seleccionados.toString());

                                  /* NavigationService.instance.navigatePushName(
                                      PoisInformation.routeName); */
                                  NavigationService.instance.navigatePushName(
                                      ScheduleSelectionScreen.routeName);
                                },
                              );
                            } else {
                              SnackBarService.instance.showSnackBar(
                                  "Por favor, selecciona al menos un lugar",
                                  false);
                            }
                            print(PreferencesProvider.instance.initialLocation);
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.purple,
                          ),
                          child: const Text('Confirmar'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void imprimirSeleccionados() {
    // Obtener los nombres de los lugares seleccionados
    final seleccionados = _lugaresSeleccionados.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    // Imprimir los nombres seleccionados
    // ignore: avoid_print
    print("Lugares seleccionados: $seleccionados");
  }

  /* void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.0),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '¿Encontraste lo que buscabas?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Si no encuentras tu lugar preferido, por favor déjanos una sugerencia.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
             const  SizedBox(height: 20),
              TextField(
                //controller: _textController,
                decoration: InputDecoration(
                  hintText: "Ingrese su sugerencia aquí",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                 child: Text('Enviar'),
                onPressed: () {
                  /* if (_textController.text.isNotEmpty) {
                    print('Sugerencia: ${_textController.text}');
                    _textController.clear();
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Por favor ingrese una sugerencia.')),
                    );
                  } */
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  textStyle:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  } */
}
