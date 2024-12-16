// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:tesis_v2/models/opening_period_model.dart';
import 'package:tesis_v2/models/place_model.dart';
import 'package:tesis_v2/providers/preferences_provider.dart';
import 'package:tesis_v2/screens/result_screen.dart';
import 'package:tesis_v2/services/climate_service.dart';
import 'package:tesis_v2/services/navigation_service.dart';

class Algoritm extends StatefulWidget {
  const Algoritm({super.key});

  static const routeName = '/algoritm';

  @override
  State<Algoritm> createState() => _AlgoritmState();
}

class _AlgoritmState extends State<Algoritm> {
  LatLng startPoint = PreferencesProvider.instance.getInitialLocation()!;
  List<PlaceData> places = [];
  List<PlaceData> resultPlaces = List.empty(growable: true);
  Map<String, int> nameToIndex = {};
  List<dynamic>? climateDataList;
  final ClimateService _climateService = ClimateService();
  LatLng locationLatLng = PreferencesProvider.instance.getInitialLocation()!;
  List<bool> isOutdoorIntervals = [];
  String dateStart = PreferencesProvider.instance.getStartTIme()!;
  String dateEnd = PreferencesProvider.instance.getEndTime()!;
  List<Map<String, dynamic>> groupedData = [];
  List<List<String>> population = [];
  // Velocidad promedio en m/s es decir 18 km/h
  double averageSpeedMetersPerSecond = 4;
  List<String> openingsPeriods = [];

  Map<String, dynamic> bestRouteAll = {
    'route': [],
    'fitness': double.infinity, //double.infinite? porque lo puse asi? ,,, nose.
    'timeRoute': [],
  };

  Map<String, int> timeLimit = {
    'limit': 0, // limite de lugares a visitar.
    'extraTime': 0, // en segundos.
  };

  Future<void> fetchClimateData() async {
    climateDataList = await _climateService.fetchClimateData(
      locationLatLng,
      dateStart,
      dateEnd,
    );
    setState(() {}); // Actualiza la UI con los nuevos datos
  }

  // DATOS GUARDADOS:
  /*
  I/flutter ( 9907): Hora fin TimeOfDay(23:58)
  I/flutter ( 9907): Hora inicio TimeOfDay(07:00)
  I/flutter ( 9907): Fecha recorrido 2024-10-21 00:00:00.000
  */

  @override
  void dispose() {
    places.removeWhere(
      (place) => place.name == 'startingPoint',
    );
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchClimateData();
    places = PreferencesProvider.instance.getPlaces()!;
    print(places.length);

    // Crea una lista temporal para acumular los lugares que deseas eliminar
    List<PlaceData> placesToRemove = [];

    for (var place in places) {
      if (!place.isMandatory) {
        if (place.rating != 'null') {
          if (double.parse(place.rating) <= 3.5) {
            // Agrega el lugar a la lista de elementos a eliminar
            if (place.isMandatory != true) {
              placesToRemove.add(place);
            }
          }
        } else {
          placesToRemove.add(place);
        }
      }
    }

    if ((places.length - placesToRemove.length) > 10) {
      // Después del bucle, elimina los elementos acumulados
      places.removeWhere((element) => placesToRemove.contains(element));
    }

    print(places.length);

    places.removeWhere(
      (element) => element.name == 'startingPoint',
    );

    places.insert(
      0,
      PlaceData(
        id: "startingPoint",
        name: "startingPoint",
        coordinates: PreferencesProvider.instance.getInitialLocation()!,
        rating: "5",
        type: "startingPoint",
        weekdayDescriptions: List.empty(),
        isOutdoor: false,
        isMandatory: false,
        urlImages: List.empty(growable: true),
        googleMapsUri: '',
        openingPeriods: List.empty(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //startPoint = PreferencesProvider.instance.getInitialLocation()!;
    //runAutomaticAlgoritm();
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Text("Haciendo la magia"),
              ),
              SizedBox(
                width: 20,
              ),
              CircularProgressIndicator()
            ],
          ),
          const SizedBox(
            height: 30,
          ),
          ElevatedButton(
            onPressed: () {
              startFunction();

              //PROBANDO EL METODO
              //generateInitialPopulationMain(5, getNamesOfPlaces(places));
            },
            child: const Text("Empezar"),
          ),
          ElevatedButton(
            onPressed: () {
              print(PreferencesProvider.instance.getInitialLocation());
            },
            child: const Text("mostrar punto de partida"),
          ),
          ElevatedButton(
            onPressed: () {
              showClimaFunction();
            },
            child: const Text("mostrar clima"),
          ),
          ElevatedButton(
            onPressed: () {
              printPlaceData(places);
            },
            child: Text('mostrar sitios'),
          ),
          ElevatedButton(
            onPressed: () {
              showResultFunction();
            },
            child: Text("Ver resultado final "),
          ),
          ElevatedButton(
            onPressed: () {
              /* climateDataList!.forEach(
                (element) {
                  print(element);
                },
              );
              print(climateDataList!.length); */
              //String dateStart = '2024-11-12T08:00:00.000Z';

              //String dateEnd = '2024-11-12T10:30:00.000Z';

              //print(calculateTotalHours(dateStart, dateEnd));
              //print(climateDataList!.length);

              //int limit = 0;

              /*  List<int> climateDataList = [
                1,
                2,
                3,
                4,
                5,
                6,
                7,
                8,
                9,
                10,
                11,
                12,
                13,
                14,
                15,
                16,
                17,
                18,
                19,
                20,
                21,
                22,
                23,
              ];

              print((climateDataList.length - 1) % 3);

              if ((climateDataList!.length - 1) % 3 == 0) {
                timeLimit['limit'] = ((climateDataList!.length - 1) ~/ 3) - 1;
                timeLimit['extraTime'] = 90;
              } else {
                timeLimit['limit'] = (climateDataList!.length - 1) ~/ 3;
                if ((climateDataList.length - 1) % 3 == 1) {
                  timeLimit['extraTime'] = 30;
                } else {
                  timeLimit['extraTime'] = 60;
                }
              }

              print(timeLimit); */
              print(climateDataList);
            },
            child: Text("MOSTRAR COSAS"),
          ),
          ElevatedButton(
            onPressed: () {
              int limit = 0;
              if ((climateDataList!.length - 1) % 3 == 0) {
                limit = ((climateDataList!.length - 1) ~/ 3) - 1;
              } else {
                limit = (climateDataList!.length - 1) ~/ 3;
              }
              List<String> names = getNamesOfPlaces(places);
              List<List<String>> population =
                  generateInitialPopulationMain(5, names, limit);
              population.forEach(
                (element) {
                  print("longitud ${element.length}");
                  print(element);
                },
              );
            },
            child: Text("Poblacion inicial"),
          ),
          ElevatedButton(
            onPressed: () {
              for (PlaceData place in places) {
                if (place.name != 'startingPoint') {
                  print(place.name);
                  print(place.openingPeriods.toString());
                  print(place.weekdayDescriptions);
                  print(place.openingPeriods[2].isOpenAt(DateTime.now()));
                  print('---------------------------------------------');
                }
              }
            },
            child: Text("Horarios de apertura"),
          ),
        ],
      ),
    );
  }

  Future<void> showResultFunction() async {
    print(bestRouteAll);

    resultPlaces = [];
    //Lista de tiempos...
    List<double> timeList = [];
    //Variable para tiempo adicional.
    double additionalTime = 0;

    for (String placeName in bestRouteAll['route']) {
      if (placeName != 'startingPoint') {
        // Acceder al índice utilizando el mapa nameToIndex
        //print(placeName);
        int index = nameToIndex[placeName]!;
        PlaceData placeData =
            places[index]; // Acceder a la instancia de PlaceData

        // Ahora puedes acceder a los atributos de placeData
        /*                   print('Nombre: ${placeData.name}');
        print('¿Es al aire libre?: ${placeData.isOutdoor}'); */

        resultPlaces.add(placeData);
        //print("HOla, ${placeData.name}");

        // Agrega más atributos según sea necesario
      }
    }

    for (int i = 1; i < bestRouteAll['timeRoute'].length; i += 2) {
      // Asegurarse de que el índice no exceda el rango de la lista
      if (i < bestRouteAll['timeRoute'].length) {
        timeList.add(double.parse(bestRouteAll['timeRoute']
            [i])); // Convertir a double y agregar a la lista de tiempos
      }
    }

    //Obtener el tiempo adicional que se aumentara en la horas de visita.
    String numberPart = bestRouteAll['timeRoute'][0].toString().split('-').last;
    additionalTime = double.parse(numberPart);

    PreferencesProvider.instance.setResultPlaces(resultPlaces);
    PreferencesProvider.instance.setTimeResultPlaces(timeList);
    PreferencesProvider.instance.setAdditionalTime(additionalTime);

    resultPlaces.forEach(
      (element) {
        print(
            "Nombre: ${element.name}\nRating${element.rating}\nCordenadas ${element.coordinates}\n-------------------");
      },
    );
    NavigationService.instance.navigatePushName(ResultScreen.routeName);
  }

  Future<void> startFunction() async {
    print(places.length);

    //List<PlaceData> limitPlaces = filterAndOrderPlaces(places, 8);
    //print("LImitplaces = ${limitPlaces.length}");

    List<List<double>> distanceMatrix = generateDistanceMatrix(places);
    List<List<double>> timeMatrix = generateTimeMatrix(distanceMatrix);

/*     double hola = calculateAverageDistance(distanceMatrix);
    print(hola);
 */
    print("Matriz de distancias");
    for (int i = 0; i < places.length; i++) {
      nameToIndex[places[i].name] = i; // Asociar cada nombre con su índice
    }
    print(nameToIndex);
    for (int i = 0; i < distanceMatrix.length; i++) {
      String row = '';
      for (int j = 0; j < distanceMatrix[i].length; j++) {
        row +=
            '${distanceMatrix[i][j].toStringAsFixed(2)}\t'; // Ajusta la precisión como prefieras
      }
      debugPrint(row);
    }

    print("Matriz de tiempos");
    for (int i = 0; i < places.length; i++) {
      nameToIndex[places[i].name] = i; // Asociar cada nombre con su índice
    }
    print(nameToIndex);
    for (int i = 0; i < timeMatrix.length; i++) {
      String row = '';
      for (int j = 0; j < timeMatrix[i].length; j++) {
        row +=
            '${timeMatrix[i][j].toStringAsFixed(2)}\t'; // Ajusta la precisión como prefieras
      }
      debugPrint(row);
    }

    //places.forEach((element) => print(element.name));
    runGeneticAlgorithm(
        550, 300, distanceMatrix, timeMatrix, places, nameToIndex);
/* 
    runGeneticAlgorithm(
        50, 50, distanceMatrix, timeMatrix, places, nameToIndex); */
    //PROBANDO EL METODO
    //generateInitialPopulationMain(5, getNamesOfPlaces(places));
  }

/*   // Función para calcular el promedio de las distancias
  double calculateAverageDistance(List<List<double>> distanceMatrix) {
    double totalDistance = 0.0;
    int count = 0;

    // Recorremos la matriz para sumar las distancias
    for (var row in distanceMatrix) {
      for (var distance in row) {
        if (distance > 0) {
          // Ignoramos las distancias de 0 (en la diagonal)
          totalDistance += distance;
          count++;
        }
      }
    }

    // Retornamos el promedio si hay distancias, de lo contrario 0
    return count > 0 ? totalDistance / count : 0.0;
  }
 */
  Future<void> showClimaFunction() async {
    isOutdoorIntervals = [];
    groupedData = [];
    int interval = 3; // Agrupar cada 3 elementos (1.5 horas)

    for (int i = 1; i < climateDataList!.length; i += 1) {
      //print(i);
      if ((i + interval) > climateDataList!.length)
        break; // Evita exceder la longitud

      // Obtener el subgrupo de datos y hacer el cast explícito
      List<Map<String, dynamic>> group = climateDataList!
          .sublist(i, i + interval + 1)
          .cast<Map<String, dynamic>>();
      print(group);
      // Calcular el valor máximo de precipitationProbability
      /*                int maxPrecipitationProbability = group
          .map((data) =>
              data['values']['precipitationProbability'] as int)
          .reduce((a, b) => a > b ? a : b);
     */
      int maxPrecipitationProbability = -1; // Inicializa la variable
      int weatherCode = 0;
      group.forEach((data) {
        int probability = data['values']['precipitationProbability'] as int;
        int code = data['values']['weatherCode'] as int;
        if (probability > maxPrecipitationProbability) {
          maxPrecipitationProbability = probability;
          weatherCode = code;
          print('debug code: $code');
        }
      });

      // Añadir al resultado agrupado
      groupedData.add({
        'startTime': group.first['startTime'],
        'endTime': group.last['startTime'],
        'maxPrecipitationProbability': maxPrecipitationProbability,
        'code': weatherCode,
      });

      // Agregar a isOutdoorIntervals según la probabilidad de precipitación
      isOutdoorIntervals.add(maxPrecipitationProbability <=
          30); // True si es 25 o menos, false si es más

      // Avanza al siguiente grupo
      i += 2; // Avanza para el siguiente bloque de 1.5 horas
    }

    // Imprimir el resultado
    groupedData.forEach((data) {
      print("Intervalo: ${data['startTime']} - ${data['endTime']}");
      print("Precipitación Máxima: ${data['maxPrecipitationProbability']}");
      print('COde ganador: ${data['code']}');
    });

    // Imprimir la lista de isOutdoorIntervals
    print("isOutdoorIntervals: $isOutdoorIntervals");
    print(groupedData.length);
    //print(groupedData.length);

    PreferencesProvider.instance.groupedData = groupedData;
  }

//FUNCION ANTES DEL PUNTO INICIAL
/*   List<List<String>> generateInitialPopulationMain(
      int populationSize, List<String> names) {
    List<List<String>> population = [];
    for (int i = 0; i < populationSize; i++) {
      List<String> newRoute = List.from(names);
      newRoute.shuffle(); 
      population.add(newRoute);
    }
    return population;
  }
 */

// FUNCION DESPUES DEL PUNTO INICIAL
/*   List<List<String>> generateInitialPopulationMain(
      int populationSize, List<String> names) {
    List<List<String>> population = [];

    for (int i = 0; i < populationSize; i++) {
      List<String> newRoute = List.from(names);
      
      newRoute.remove(
          'startingPoint'); // Remover el punto de inicio para no hacer shuffle en él.
      newRoute.shuffle(); // Mezclar el resto de los puntos.

      newRoute.insert(0,
          'startingPoint'); // Insertar el punto de inicio en la primera posición.
      population.add(newRoute);
      //print(newRoute);
    }

    return population;
  } */

  List<List<String>> generateInitialPopulationMain(
      int populationSize, List<String> names, int limit) {
    List<List<String>> population = [];

    // Remover 'startingPoint' de la lista de nombres
    List<String> availableNames = List.from(names);
    availableNames.remove('startingPoint');

    // Asegurarse de que limit no exceda el número de lugares disponibles
    limit = limit.clamp(0, availableNames.length);

    for (int i = 0; i < populationSize; i++) {
      // Seleccionar N lugares aleatorios
      List<String> selectedPlaces =
          (List.of(availableNames)..shuffle()).sublist(0, limit);

      // Crear una nueva ruta que incluye el startingPoint
      List<String> newRoute = List.from(selectedPlaces);

      newRoute.insert(0,
          'startingPoint'); // Insertar el punto de inicio en la primera posición.
      population.add(newRoute);
    }

    return population;
  }

/*   double calculateFitness(List<String> route, List<List<double>> distanceMatrix,
      List<PlaceData> places, List<bool> isOutdoorIntervals) {
    double totalDistance = 0.0;
    List<String> names = getNamesOfPlaces(places);
    for (int i = 0; i < route.length - 1; i++) {
      int position1 = names.indexOf(route[i]);
      int position2 = names.indexOf(route[i + 1]);
      totalDistance += distanceMatrix[position1][position2];
    }
    int position1 = names.indexOf(route.last);
    int position2 = names.indexOf(route.first);
    totalDistance +=
        distanceMatrix[position1][position2]; // Regresar al punto inicial

    return totalDistance;
  } */

/*   double calculateFitness2(
      List<String> route,
      List<List<double>> distanceMatrix,
      List<PlaceData> places,
      List<bool> isOutdoorIntervals) {
    double totalDistance = 0.0;
    double penalty =
        0.0; // Penalización por lugares al aire libre en intervalos no adecuados
    List<String> names = getNamesOfPlaces(places);

    for (int i = 0; i < route.length - 1; i++) {
      int position1 = names.indexOf(route[i]);
      int position2 = names.indexOf(route[i + 1]);
      totalDistance += distanceMatrix[position1][position2];

      // Penalización basada en el isOutdoorIntervals solo si no es el startingPoint
      if (i > 0) {
        // Ignorar el startingPoint
        bool isOutdoorPlace = places[names.indexOf(route[i])]
            .isOutdoor; // Asumiendo que tienes este atributo
        if (isOutdoorPlace && !isOutdoorIntervals[i - 1]) {
          penalty +=
              50.0; // Ajusta el valor de penalización según sea necesario
        }
      }
    }

    // Considera el regreso al punto inicial
    int position1 = names.indexOf(route.last);
    int position2 = names.indexOf(route.first);
    totalDistance += distanceMatrix[position1][position2];

    return totalDistance +
        penalty; // Retorna la distancia total con la penalización
  } */

  Map<String, dynamic> calculateFitness(
    List<String> route,
    List<List<double>> distanceMatrix,
    List<List<double>> timeMatrix,
    List<PlaceData> places,
    List<bool> isOutdoorIntervals,
    Map<String, int> nameToIndex,
    int populationIndex,
  ) {
    route = List.from(route);
    double totalDistance = 0.0;
    double totalTime = 0.0;
    double penalty =
        0.0; // Penalización por lugares al aire libre en intervalos no adecuados y mucho mas
    List<String> timeRoute = [];
    List<double> timeResultPlaces = [];
    List<String> visitsTimes = [];
    List<bool> intervals = [];
    openingsPeriods = [];

    //DEFINIR PENALIZACIONES
    const double LIGHT_PENALTY = 5;
    const double MODERATTE_PENALTY = 10;
    const double HEAVY_PENALTY = 15;
    const double VERY_HEAVY_PENALTY = 25;

    //DEFINIR PREMIOS
    const double LIGHT_REWARD = 2;
    const double MODERATE_REWARD = 5;
    const double HEAVY_REWARD = 8;

    List<String> names = nameToIndex.keys.toList();

    int localExtraTime = timeLimit['extraTime']!;

    const double metersToKilometers = 0.001;

    List<List<double>> distanceMatrixInKm = distanceMatrix
        .map((row) => row.map((value) => value * metersToKilometers).toList())
        .toList();

    //verificar si mi lista cointiene -1
    if (route.contains('-1') || route.length <= timeLimit['limit']!) {
      route.removeWhere((element) => element == '-1');
      population[populationIndex] = route;
      localExtraTime += 5400;
      //penalty += 12500.0;
      penalty += VERY_HEAVY_PENALTY + VERY_HEAVY_PENALTY;
    }

    //Primer recorrido para calcular el timepo total.
    for (int i = 0; i < route.length - 1; i++) {
      // Obtener los índices usando el mapa
      int position1 = nameToIndex[route[i]]!;
      int position2 = nameToIndex[route[i + 1]]!;
      double timeByPlace = timeMatrix[position1][position2];
      totalTime += timeByPlace;
      timeResultPlaces.add(timeByPlace);
    }

    if (localExtraTime < totalTime) {
      int randomIndex = Random().nextInt(route.length - 1) + 1;
      route.removeAt(randomIndex);
      population[populationIndex] = route;
      //penalty += 12500.0;
      penalty += VERY_HEAVY_PENALTY + VERY_HEAVY_PENALTY;
      localExtraTime += 5400;
    }

    //para calcular la duracion de cada visita.
    double timeVisit = localExtraTime - totalTime;

    //OBTENER EL TIEMPO DE CADA PUNTO VISITADO.
    DateTime startTimeLocal = DateTime.parse(dateStart);
    startTimeLocal =
        startTimeLocal.add(Duration(seconds: timeResultPlaces[0].round()));
    int visitDuration = 90 * 60; // 90 minutos en segundos

    // Distribuir el tiempo adicional equitativamente
    int extraTimePerSite = timeVisit ~/ route.length;
    DateTime
        endTimeLocal; //= startTimeLocal.add(Duration(seconds: visitDuration + extraTimePerSite));

    for (int i = 0; i < (route.length - 1); i++) {
      endTimeLocal = startTimeLocal
          .add(Duration(seconds: visitDuration + extraTimePerSite));
      /*  String formattedStartTime = DateFormat('h:mm a').format(startTimeLocal);
      String formattedEndTime = DateFormat('h:mm a').format(endTimeLocal); */
      //visitsTimes.add('$formattedStartTime - $formattedEndTime');
      visitsTimes.add(
          '${startTimeLocal.toIso8601String()}*${endTimeLocal.toIso8601String()}');
      startTimeLocal = endTimeLocal;
      if ((route.length - 1) != (i + 1)) {
        startTimeLocal = startTimeLocal
            .add(Duration(seconds: timeResultPlaces[i + 1].round()));
      }
    }

    intervals = findMaxPrecipitationProbabilityForEachVisit(
        climateDataList: climateDataList, visitsTimes: visitsTimes);

    for (int i = 0; i < route.length - 1; i++) {
      // Obtener los índices usando el mapa
      int position1 = nameToIndex[route[i]]!;
      int position2 = nameToIndex[route[i + 1]]!;
      totalDistance += distanceMatrixInKm[position1][position2];
      //totalTime += timeMatrix[position1][position2];

      if (i == 0) {
        timeRoute.add(names[position1]);
      }
      timeRoute.add("${timeMatrix[position1][position2]}");
      timeRoute.add(names[position2]);

      // Penalización basada en el isOutdoorIntervals solo si no es el startingPoint

      bool isOutdoorPlace = places[position2].isOutdoor;
/*         print(
            "${places[position1].name} con ${places[position1].isOutdoor} ademas intervalo que corresponde ${isOutdoorIntervals[i - 1]}"); */
      if (isOutdoorPlace != intervals[i]) {
        if (intervals[i] == true) {
          //print('penalizado leve');
          //antes estaba en 5
          //penalty += 500.0;
          penalty += LIGHT_PENALTY;
        } else {
          //print('penalizado grabe');
          //antes estaba en 25
          //penalty += 5000.0;
          penalty += HEAVY_PENALTY;
        }
      } else {
        penalty -= LIGHT_REWARD;
      }

      if (places[position2].isMandatory) {
        //antes 50
        //penalty += 10000;
        //print('Penalizacion muy grave');
        //penalty += VERY_HEAVY_PENALTY;
        penalty -= HEAVY_REWARD;
      }

      // Dividir el rango en inicio y fin
      final parts = visitsTimes[i].split('*');
      if (parts.length != 2) {
        throw ArgumentError(
            'El rango de tiempo debe tener el formato correcto: inicio*fin');
      }

      final startTime = DateTime.parse(parts[0]);
      bool isOpening = false;
      bool haveData = false;

      if (places[position2].openingPeriods.isEmpty) {
        haveData = false;
      } else {
        for (OpeningPeriod op in places[position2].openingPeriods) {
          if (op.isOpen24Hours) {
            isOpening = true;
            haveData = true;
            openingsPeriods.add(op.toString());
            break;
          }
          if (op.openDay == startTime.weekday) {
            isOpening = op.isOpenForEntireRange(visitsTimes[i]);
            openingsPeriods.add(op.toString());
            haveData = true;
            break;
          } else {
            isOpening = false;
            haveData = false;
          }
        }
      }

      if (!isOpening) {
        //Penalizaicion grave
        penalty += HEAVY_PENALTY;
        //penalty += 10000;
      } else {
        penalty -= LIGHT_REWARD;
      }

      if (!haveData) {
        openingsPeriods.add('ND');
      }
      //bool hola = places[position1].openingPeriods
      //print(hola);

      /*  bool prueba = places[position1]
            .openingPeriods[startTime.weekday]
            .isOpenForEntireRange(visitsTimes[i - 1]);
        print(prueba); */
    }

    // Considera el regreso al punto inicial
    int startPosition = nameToIndex[route.first]!;
    int endPosition = nameToIndex[route.last]!;
    totalDistance += distanceMatrixInKm[endPosition][startPosition];

    timeRoute[0] = '${timeRoute[0]}-$timeVisit';

    //verifica que tenga al menos un sitio de cada interes del usuario

    //print(timeRoute);
    //print(totalTime);

    //print(totalDistance);

/*     return totalDistance +
        penalty; // Retorna la distancia total con la penalización */

// IMPORTANTE: NO PONGO EL TIMEPO TOTAL EN EL FITNESS YA QUE VA RELACIONADO CON LA DISTANCIA TOTAL
// Y PONERLO SERÍA REDUNDANTES Y PERJUDICIAL PARA MIS PENALIDADES.
    return {
      'fitness': totalDistance + penalty,
      'timeRoute': timeRoute,
      'groupedData': groupedData,
      'openingsPeriods': openingsPeriods
    };
  }

  List<bool> findMaxPrecipitationProbabilityForEachVisit({
    required List<dynamic>? climateDataList,
    required List<String> visitsTimes,
  }) {
    //final Map<String, int> maxPrecipitations = {};
    List<bool> intervals = [];
    List<Map<String, dynamic>> groupedDataLocal = [];

    for (String visitTime in visitsTimes) {
      // Parsear el intervalo de visitas.
      final times = visitTime.split('*');
      final visitStart = DateTime.parse(times[0]);
      final visitEnd = DateTime.parse(times[1]);

      int maxPrecipitation = 0;
      int weatherCode = 0;

      // Buscar los datos de clima dentro del rango de la visita.
      for (var climateEntry in climateDataList!) {
        final startTime = DateTime.parse(climateEntry['startTime']);
        final values = climateEntry['values'] as Map<String, dynamic>;
        final precipitationProbability =
            values['precipitationProbability'] as int;

        // Verificar si este dato de clima está dentro del intervalo de visita.
        if (startTime.isAfter(visitStart) && startTime.isBefore(visitEnd)) {
          // Actualizar la mayor probabilidad encontrada.
          if (precipitationProbability >= maxPrecipitation) {
            maxPrecipitation = precipitationProbability;
            weatherCode = values['weatherCode'];
          }
        }
      }

      groupedDataLocal.add({
        'startTime': times[0],
        'endTime': times[1],
        'maxPrecipitationProbability': maxPrecipitation,
        'code': weatherCode,
      });

      groupedData = groupedDataLocal;

      intervals.add(maxPrecipitation <= 10); //30

      // Guardar el máximo para este intervalo.
      //maxPrecipitations[visitTime] = maxPrecipitation;
    }

    return intervals;
  }

/*   void getVisitsTimes() {
    DateTime startTimeLocal = DateTime.parse(dateStart);
    startTimeLocal =
        startTimeLocal.add(Duration(seconds: timeResultPlaces[0].round()));
    int visitDuration = 90 * 60; // 90 minutos en segundos

    // Distribuir el tiempo adicional equitativamente
    int extraTimePerSite = additionalTime ~/ resultPlaces.length;
    DateTime
        endTimeLocal; //= startTimeLocal.add(Duration(seconds: visitDuration + extraTimePerSite));

    for (int i = 0; i < resultPlaces.length; i++) {
      endTimeLocal = startTimeLocal
          .add(Duration(seconds: visitDuration + extraTimePerSite));
      String formattedStartTime = DateFormat('h:mm a').format(startTimeLocal);
      String formattedEndTime = DateFormat('h:mm a').format(endTimeLocal);
      visitsTimes.add('$formattedStartTime - $formattedEndTime');
      startTimeLocal = endTimeLocal;
      if (resultPlaces.length != (i + 1)) {
        startTimeLocal = startTimeLocal
            .add(Duration(seconds: timeResultPlaces[i + 1].round()));
      }
    }
    //currentTime = endTimeLocal.toIso8601String();
    //return '$formattedStartTime - $formattedEndTime';
  } */

  List<String> selection(
      List<List<String>> population, List<double> fitnessValues) {
    int tournamentSize = 3;
    List<int> selected = [];
    for (int i = 0; i < tournamentSize; i++) {
      int randomIndex = Random().nextInt(population.length);
      selected.add(randomIndex);
    }
    selected.sort((a, b) => fitnessValues[a].compareTo(fitnessValues[b]));
    return population[selected.first];
  }

/*   List<String> crossover(List<String> parent1, List<String> parent2) {
    //int start = Random().nextInt(parent1.length);
    int start = Random().nextInt(parent1.length - 2) +
        1; // Evita el primer y último índice
    int end = Random().nextInt(parent1.length - start) + start;
    List<String> offspring = List.filled(parent1.length, '-1');
    for (int i = start; i < end; i++) {
      offspring[i] = parent1[i];
    }
    int currentIndex = end % parent1.length;

    for (int i = 0; i < parent2.length; i++) {
      if (!offspring.contains(parent2[i])) {
        offspring[currentIndex] = parent2[i];
        currentIndex = (currentIndex + 1) % parent1.length;
      }
    }
    offspring[0] =
        'startPoint'; // Asegura que el punto de partida esté al principio
    offspring[offspring.length - 1] =
        'startPoint'; // Asegura que el punto de partida esté al final
    return offspring;
  } */

// FUNCINO ANTES DEL PUNTO INCIAL
/*   List<String> crossover(List<String> parent1, List<String> parent2) {
    int start = Random().nextInt(parent1.length);
    int end = Random().nextInt(parent1.length - start) + start;
    List<String> offspring = List.filled(parent1.length, '-1');
    for (int i = start; i < end; i++) {
      offspring[i] = parent1[i];
    }
    int currentIndex = end % parent1.length;

    for (int i = 0; i < parent2.length; i++) {
      if (!offspring.contains(parent2[i])) {
        offspring[currentIndex] = parent2[i];
        currentIndex = (currentIndex + 1) % parent1.length;
      }
    }
    return offspring;
  } 
  */

  //FUNCION DESPUES DEL PUNTO INICIAL
  List<String> crossover(List<String> parent1, List<String> parent2) {
    int start =
        Random().nextInt(parent1.length - 1) + 1; // Evitar la posición 0
    int end = Random().nextInt(parent1.length - start) + start;

    // Crear el offspring con el mismo tamaño que los padres y con el startingPoint fijo
    List<String> offspring = List.filled(parent1.length, '-1');
    offspring[0] =
        'startingPoint'; // Asegurar que el startingPoint esté en la primera posición

    // Copiar la porción del primer padre (evitando la primera posición)
    for (int i = start; i < end; i++) {
      offspring[i] = parent1[i];
    }

    // Llenar los espacios vacíos con genes del segundo padre (evitar duplicados)
    int currentIndex = end % parent1.length;

    for (int i = 1; i < parent2.length; i++) {
      // Empezar desde el índice 1 para evitar el startingPoint
      if (!offspring.contains(parent2[i]) && offspring.contains('-1')) {
        offspring[currentIndex] = parent2[i];
        currentIndex = (currentIndex + 1) % parent1.length;

        // Si currentIndex es 0, saltar a la siguiente posición (1) para no sobrescribir el startingPoint
        if (currentIndex == 0) {
          currentIndex = 1;
        }
      }
    }

    return offspring;
  }

// FUNCION ANTES DEL PUNTO INICIAL
/*   List<String> mutate(List<String> route) {
    //indice 1 y 2 aleatorios dentro de la ruta
    int index1 = Random().nextInt(route.length);
    int index2 = Random().nextInt(route.length);
    // crea una ruta temporal
    String temp = route[index1];
    // copea indice 1 en indice 2
    route[index1] = route[index2];
    // pega el indice 1 en indice 2
    route[index2] = temp;
    return route;
  } */

  // FUNCION DESPUES DEL PUNTO INICIAL
  List<String> mutate(List<String> route) {
    // Generar índices aleatorios dentro de la ruta, evitando el índice 0 (startingPoint)
    int index1 = Random().nextInt(route.length - 1) + 1; // Evitar el índice 0
    int index2 = Random().nextInt(route.length - 1) + 1; // Evitar el índice 0

    // Crear una ruta temporal para hacer el swap
    String temp = route[index1];
    // Intercambiar los valores de index1 e index2
    route[index1] = route[index2];
    route[index2] = temp;

    return route;
  }

/*   List<String> mutate(List<String> route) {
    // Solo realiza mutaciones en los lugares intermedios
    int index1 = Random().nextInt(route.length - 2) + 1;
    int index2 = Random().nextInt(route.length - 2) + 1;
    if (index1 == index2) return route; // Evita mutar el punto de partida
    String temp = route[index1];
    route[index1] = route[index2];
    route[index2] = temp;
    return route;
  } */

  List<List<String>> replacePopulation(
      List<List<String>> population, List<List<String>> newGeneration) {
    return newGeneration;
  }

  void runGeneticAlgorithm(
      int generations,
      int populationSize,
      List<List<double>> distanceMatrix,
      List<List<double>> timeMatrix,
      List<PlaceData> places,
      //int limit,
      Map<String, int> nameToIndex) {
    List<String> names = getNamesOfPlaces(places);
    //List<String> namesInDoor = getNamesOfPlacesInDoor(places);

    //print(names.length);
    //print(namesInDoor.length);

/*     List<PlaceData> newPlaces = filterAndOrderPlaces(places, limit);
    places = newPlaces; */

//FORMA ANTERIOR, DONDE SOLO SE CONSIDERAVA EL LIMIT NO EL TIEMPO EXTRA.
/*     int limit = 0;

    if ((climateDataList!.length - 1) % 3 == 0) {
      limit = ((climateDataList!.length - 1) ~/ 3) - 1;
    } else {
      limit = (climateDataList!.length - 1) ~/ 3;
    } */

    if ((climateDataList!.length - 1) % 3 == 0) {
      timeLimit['limit'] = ((climateDataList!.length - 1) ~/ 3) - 1;
      timeLimit['extraTime'] = 5400; //en segundos.
    } else {
      timeLimit['limit'] = (climateDataList!.length - 1) ~/ 3;
      if ((climateDataList!.length - 1) % 3 == 1) {
        timeLimit['extraTime'] = 1800;
      } else {
        timeLimit['extraTime'] = 3600;
      }
    }
    // EL tamaño de la poblacion inicial dependera de los intervalos que haya,
    // el limit.

    population = generateInitialPopulationMain(
        populationSize, names, timeLimit['limit']!);

    for (int generation = 0; generation < generations; generation++) {
/*       List<double> fitnessValues = population
          .map((route) => calculateFitness(route, distanceMatrix, timeMatrix,
              places, isOutdoorIntervals, nameToIndex))
          .toList();
           */
      List<Map<String, dynamic>> fitnessResults =
          population.asMap().entries.map((entry) {
        int index = entry.key; // El índice del elemento en population
        List<String> route =
            entry.value; // El elemento actual (la lista `route`)

        // Llamar a calculateFitness con el índice
        return calculateFitness(
            route,
            distanceMatrix,
            timeMatrix,
            places,
            isOutdoorIntervals,
            nameToIndex,
            index // Pasar el índice como parámetro adicional
            );
      }).toList();

      List<double> fitnessValues =
          fitnessResults.map((result) => result['fitness'] as double).toList();
      //List<String> names = getNamesOfPlaces(places);
      double minFitnessValue = fitnessValues.reduce((a, b) => a < b ? a : b);

      int bestSolutionIndex = fitnessValues.indexOf(minFitnessValue);
      List<String> bestRooute = population[bestSolutionIndex];
      List<String> bestTimeRoute =
          fitnessResults[bestSolutionIndex]['timeRoute'];

      //displayEvolution(generation, bestRooute, minFitnessValue);

      // Comparar y actualizar bestRouteAll
      if (minFitnessValue < bestRouteAll['fitness']) {
        bestRouteAll['route'] = bestRooute;
        bestRouteAll['fitness'] = minFitnessValue;
        bestRouteAll['timeRoute'] = bestTimeRoute;
        //Estan mal echos....
        PreferencesProvider.instance.groupedData =
            fitnessResults[bestSolutionIndex]['groupedData'];
        PreferencesProvider.instance.setOpeningsPeriods(
            fitnessResults[bestSolutionIndex]['openingsPeriods']);
      }

      List<List<String>> newGeneration = [];

      //Repite el proceso de generar nuevos cromosomas hasta llenar la nueva población
      for (int i = 0; i < populationSize; i++) {
        //Selecciona el primer y segundo padre usando la funcion de selección
        List<String> parent1 = selection(population, fitnessValues);
        List<String> parent2 = selection(population, fitnessValues);
        //Genera una descendencia generando un cruce
        List<String> offspring = crossover(parent1, parent2);
        //Aplica una mutación con una probabilidad del 10%
        if (Random().nextDouble() < 0.15) {
          // Probabilidad de mutación
          offspring = mutate(offspring);
        }
        //Añade descendencia a la nueva generación
        newGeneration.add(offspring);
      }
      //Reemplaza la población actual por la nueva generación
      population = replacePopulation(population, newGeneration);

      // Asume que la primera ruta en la población es la mejor
      //List<int> bestRoute = population.first;

      //Calula la aptitud de la mejor ruta
      //double bestFitness = calculateFitness(bestRoute, distanceMatrix);
      //Muesta la evolución.
      //displayEvolution(generation, bestRoute, bestFitness);
    }
    print(
        'La mejor ruta encontrada con fitness: ${bestRouteAll['fitness']}, ${bestRouteAll['route']}');
    print(
        'La mejor ruta encontrada con fitness time: ${bestRouteAll['fitness']}, ${bestRouteAll['timeRoute']}');

    //Mostrar informacion de si e al aire libre o no.
    /* for (String placeName in bestRouteAll['route']) {
      if (placeName != 'startingPoint') {
        // Acceder al índice utilizando el mapa nameToIndex
        print(placeName);
        int index = nameToIndex[placeName]!;
        PlaceData placeData =
            places[index]; // Acceder a la instancia de PlaceData

        // Ahora puedes acceder a los atributos de placeData
        print('Nombre: ${placeData.name}');
        print('¿Es al aire libre?: ${placeData.isOutdoor}');

        resultPlaces.add(placeData);

        // Agrega más atributos según sea necesario
      }
    } */
  }

  /// Muestra la evolución del mejor camino en cada generación
  void displayEvolution(
      int generation, List<String> bestRoute, double bestFitness) {
    print(
        "Generation $generation: Best route $bestRoute with distance: $bestFitness");
  }

  void printPlaceData(List<PlaceData> places) {
    for (var place in places) {
      debugPrint('ID: ${place.id}');
      debugPrint('Name: ${place.name}');
      debugPrint(
          'Coordinates: (${place.coordinates.latitude}, ${place.coordinates.longitude})');
      debugPrint('Rating: ${place.rating}');
      debugPrint('Type: ${place.type}');
      debugPrint('hours: ${place.weekdayDescriptions}');
      debugPrint('isOutdoor: ${place.isOutdoor}');
      debugPrint('isMandatory: ${place.isMandatory}');
      debugPrint('hola: ${place.openingPeriods.toString()}');
      debugPrint('-------------------');
    }
  }

  List<String> getNamesOfPlaces(List<PlaceData> places) {
    List<String> names = [];
    for (var place in places) {
      names.add(place.name);
    }
    return names;
  }

  List<String> getNamesOfPlacesInDoor(List<PlaceData> places) {
    List<String> names = [];
    for (var place in places) {
      if (place.isOutdoor == false) {
        names.add(place.name);
      }
    }
    return names;
  }

// Función para calcular la distancia entre dos puntos utilizando la fórmula del haversine en metros
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000; // Radio de la Tierra en metros
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = R * c;
    return distance; // Distancia en metros
  }

// Función auxiliar para convertir grados a radianes
  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

// Función para generar la matriz de distancias en metros
  List<List<double>> generateDistanceMatrix(List<PlaceData> places) {
    int n = places.length;
    List<List<double>> distanceMatrix =
        List.generate(n, (_) => List.filled(n, 0.0), growable: false);

    for (int i = 0; i < n; i++) {
      for (int j = 0; j < n; j++) {
        if (i == j) {
          distanceMatrix[i][j] = 0.0; // La distancia del lugar a sí mismo es 0
        } else {
          double distance = calculateDistance(
              places[i].coordinates.latitude,
              places[i].coordinates.longitude,
              places[j].coordinates.latitude,
              places[j].coordinates.longitude);
          distanceMatrix[i][j] = distance;
        }
      }
    }
    return distanceMatrix;
  }

// Función para generar la matriz de tiempos en segundos basada en la matriz de distancias y una velocidad promedio
  List<List<double>> generateTimeMatrix(List<List<double>> distanceMatrix) {
    int n = distanceMatrix.length;
    List<List<double>> timeMatrix =
        List.generate(n, (_) => List.filled(n, 0.0), growable: false);

    for (int i = 0; i < n; i++) {
      for (int j = 0; j < n; j++) {
        if (i == j) {
          timeMatrix[i][j] = 0.0; // El tiempo de viaje al mismo lugar es 0
        } else {
          // Calcular el tiempo en segundos basado en la distancia y la velocidad promedio
          double time = distanceMatrix[i][j] /
              averageSpeedMetersPerSecond; // Tiempo en segundos
          timeMatrix[i][j] = time;
        }
      }
    }
    return timeMatrix;
  }

/*   // Función para generar la matriz de distancias
  List<List<double>> generateDistanceMatrix2(
      List<PlaceData> places, LatLng startingPoint) {
    // Crear una nueva lista que incluya el punto de partida
    List<PlaceData> extendedPlaces = [
      PlaceData(
        id: 'startingPoint', // Puedes cambiar el ID según sea necesario
        name: 'Punto de Partida', // Nombre descriptivo
        coordinates: startingPoint,
        rating: 'N/A', // Asigna un valor adecuado según tu lógica
        type: 'starting_point', // Tipo para el punto de partida
        weekdayDescriptions: [],
        isOutdoor: true, // O falso, según tu caso
        isMandatory: true, // O falso, según tu caso
        urlImages: List.empty(growable: true),
        googleMapsUri: '',
      )
    ];

    // Añadir los lugares existentes
    extendedPlaces.addAll(places);

    int n = extendedPlaces.length;
    List<List<double>> distanceMatrix =
        List.generate(n, (_) => List.filled(n, 0.0), growable: false);

    for (int i = 0; i < n; i++) {
      for (int j = 0; j < n; j++) {
        if (i == j) {
          distanceMatrix[i][j] = 0.0; // La distancia del lugar a sí mismo es 0
        } else {
          double distance = calculateDistance(
              extendedPlaces[i].coordinates.latitude,
              extendedPlaces[i].coordinates.longitude,
              extendedPlaces[j].coordinates.latitude,
              extendedPlaces[j].coordinates.longitude);
          distanceMatrix[i][j] = distance;
        }
      }
    }
    return distanceMatrix;
  } */

  List<PlaceData> filterAndOrderPlaces(List<PlaceData> places, int limit) {
    // Asegura que el startingPoint siempre esté primero en la lista
    List<PlaceData> sortedPlaces = List.from(places);
    PlaceData startingPoint = sortedPlaces.removeAt(0);

    // Filtra lugares que tienen rating 'null' y los convierte en un número bajo para que no interfieran con la calificación
    sortedPlaces =
        sortedPlaces.where((place) => place.rating != 'null').toList();

    // Ordena los lugares por calificación en orden descendente
    sortedPlaces.sort((a, b) {
      // Convierte a double para ordenar
      double ratingA = double.tryParse(a.rating) ?? 0.0;
      double ratingB = double.tryParse(b.rating) ?? 0.0;
      return ratingB.compareTo(ratingA);
    });

    if (sortedPlaces.length > limit) {
      sortedPlaces = sortedPlaces.sublist(0, limit);
    }

    // Agrega el startingPoint nuevamente al inicio de la lista
    sortedPlaces.insert(0, startingPoint);

    return sortedPlaces;
  }

  double calculateTotalHours(String dateStart, String dateEnd) {
    // Convertir las cadenas a DateTime
    DateTime startDate = DateTime.parse(dateStart);
    DateTime endDate = DateTime.parse(dateEnd);

    // Calcular la diferencia
    Duration difference = endDate.difference(startDate);

    // Convertir la diferencia a horas con decimales
    double totalHours =
        difference.inHours.toDouble() + (difference.inMinutes % 60) / 60;

    return totalHours;
  }
}
