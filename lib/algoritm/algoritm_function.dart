import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tesis_v2/models/place_model.dart';
import 'package:tesis_v2/providers/preferences_provider.dart';
import 'package:tesis_v2/screens/result_screen.dart';
import 'package:tesis_v2/services/climate_service.dart';
import 'package:tesis_v2/services/navigation_service.dart';

void runAlgoritm() {
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

  Map<String, dynamic> bestRouteAll = {
    'route': [],
    'fitness': double.infinity,
  };

  places = PreferencesProvider.instance.getPlaces()!;

  List<PlaceData> placesToRemove = [];

  for (var place in places) {
    if (!place.isMandatory) {
      if (place.rating != 'null') {
        if (double.parse(place.rating) <= 4) {
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
    ),
  );

  List<List<String>> generateInitialPopulationMain(
      int populationSize, List<String> names, int limit) {
    List<List<String>> population = [];

    List<String> availableNames = List.from(names);
    availableNames.remove('startingPoint');

    limit = limit.clamp(0, availableNames.length);

    for (int i = 0; i < populationSize; i++) {
      List<String> selectedPlaces =
          (List.of(availableNames)..shuffle()).sublist(0, limit);

      List<String> newRoute = List.from(selectedPlaces);

      newRoute.insert(0,
          'startingPoint'); // Insertar el punto de inicio en la primera posición.
      population.add(newRoute);
    }

    return population;
  }

  double calculateFitness(
      List<String> route,
      List<List<double>> distanceMatrix,
      List<PlaceData> places,
      List<bool> isOutdoorIntervals,
      Map<String, int> nameToIndex) {
    double totalDistance = 0.0;
    double penalty = 0.0;

    for (int i = 0; i < route.length - 1; i++) {
      int position1 = nameToIndex[route[i]]!;
      int position2 = nameToIndex[route[i + 1]]!;
      totalDistance += distanceMatrix[position1][position2];

      if (i > 0) {
        bool isOutdoorPlace = places[position1].isOutdoor;
        if (isOutdoorPlace != isOutdoorIntervals[i - 1]) {
          if (isOutdoorIntervals[i - 1] == true) {
            penalty += 5;
          } else {
            penalty += 25.0;
          }
        }
      }

      if (!places[position1].isMandatory) {
        penalty += 50;
      }
    }

    int startPosition = nameToIndex[route.first]!;
    int endPosition = nameToIndex[route.last]!;
    totalDistance += distanceMatrix[endPosition][startPosition];

    return totalDistance +
        penalty; // Retorna la distancia total con la penalización
  }

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

  List<String> crossover(List<String> parent1, List<String> parent2) {
    int start =
        Random().nextInt(parent1.length - 1) + 1; // Evitar la posición 0
    int end = Random().nextInt(parent1.length - start) + start;

    List<String> offspring = List.filled(parent1.length, '-1');
    offspring[0] = 'startingPoint';

    for (int i = start; i < end; i++) {
      offspring[i] = parent1[i];
    }

    int currentIndex = end % parent1.length;

    for (int i = 1; i < parent2.length; i++) {
      if (!offspring.contains(parent2[i])) {
        offspring[currentIndex] = parent2[i];
        currentIndex = (currentIndex + 1) % parent1.length;

        if (currentIndex == 0) {
          currentIndex = 1;
        }
      }
    }

    return offspring;
  }

  List<String> mutate(List<String> route) {
    int index1 = Random().nextInt(route.length - 1) + 1;
    int index2 = Random().nextInt(route.length - 1) + 1;

    String temp = route[index1];
    route[index1] = route[index2];
    route[index2] = temp;

    return route;
  }

  List<List<String>> replacePopulation(
      List<List<String>> population, List<List<String>> newGeneration) {
    return newGeneration;
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

  void runGeneticAlgorithm(
      int generations,
      int populationSize,
      List<List<double>> distanceMatrix,
      List<PlaceData> places,
      int limit,
      Map<String, int> nameToIndex) {
    List<String> names = getNamesOfPlaces(places);
    List<String> namesInDoor = getNamesOfPlacesInDoor(places);
    print('Llego aca aa');
    List<List<String>> population =
        generateInitialPopulationMain(populationSize, names, limit);

    for (int generation = 0; generation < generations; generation++) {
      List<double> fitnessValues = population
          .map((route) => calculateFitness(
              route, distanceMatrix, places, isOutdoorIntervals, nameToIndex))
          .toList();
      double minFitnessValue = fitnessValues.reduce((a, b) => a < b ? a : b);

      int bestSolutionIndex = fitnessValues.indexOf(minFitnessValue);
      List<String> bestRooute = population[bestSolutionIndex];
      if (minFitnessValue < bestRouteAll['fitness']) {
        bestRouteAll['route'] = bestRooute;
        bestRouteAll['fitness'] = minFitnessValue;
      }
      List<List<String>> newGeneration = [];
      for (int i = 0; i < populationSize; i++) {
        List<String> parent1 = selection(population, fitnessValues);
        List<String> parent2 = selection(population, fitnessValues);
        List<String> offspring = crossover(parent1, parent2);
        if (Random().nextDouble() < 0.15) {
          offspring = mutate(offspring);
        }
        newGeneration.add(offspring);
      }
      population = replacePopulation(population, newGeneration);
    }
    print(
        'La mejor ruta encontrada con fitness: ${bestRouteAll['fitness']}, ${bestRouteAll['route']}');
  }

  // Función auxiliar para convertir grados a radianes
  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

// Función para calcular la distancia entre dos puntos utilizando la fórmula del haversine
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // Radio de la Tierra en kilómetros
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = R * c;
    return distance; // Distancia en kilómetros
  }

// Función para generar la matriz de distancias
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

  void runAutomaticAlgoritm() async {
    //showClimaFunction();
    isOutdoorIntervals = [];
    groupedData = [];
    int interval = 3; // Agrupar cada 3 elementos (1.5 horas)

    climateDataList = await _climateService.fetchClimateData(
      locationLatLng,
      dateStart,
      dateEnd,
    );

    for (int i = 0; i < climateDataList!.length; i += 1) {
      print(i);
      if (i + interval > climateDataList!.length) break;
      List<Map<String, dynamic>> group = climateDataList!
          .sublist(i, i + interval + 1)
          .cast<Map<String, dynamic>>();
      print(group);

      int maxPrecipitationProbability = -1;
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
      groupedData.add({
        'startTime': group.first['startTime'],
        'endTime': group.last['startTime'],
        'maxPrecipitationProbability': maxPrecipitationProbability,
        'code': weatherCode,
      });

      isOutdoorIntervals.add(maxPrecipitationProbability <= 25);
      i += 2;
    }
    PreferencesProvider.instance.groupedData = groupedData;

    //startFunction();

    print(places.length);

    List<List<double>> distanceMatrix = generateDistanceMatrix(places);

    for (int i = 0; i < places.length; i++) {
      nameToIndex[places[i].name] = i;
    }
    print(nameToIndex);
    for (int i = 0; i < distanceMatrix.length; i++) {
      String row = '';
      for (int j = 0; j < distanceMatrix[i].length; j++) {
        row += '${distanceMatrix[i][j].toStringAsFixed(2)}\t';
      }
    }
    runGeneticAlgorithm(
        600, 250, distanceMatrix, places, groupedData.length, nameToIndex);

    //showResultFunction();
    print(bestRouteAll);

    resultPlaces = [];

    for (String placeName in bestRouteAll['route']) {
      if (placeName != 'startingPoint') {
        int index = nameToIndex[placeName]!;
        PlaceData placeData = places[index];
        resultPlaces.add(placeData);
      }
    }
    print('Llegye aca xd');
    PreferencesProvider.instance.setResultPlaces(resultPlaces);
    NavigationService.instance.navigatePushName(ResultScreen.routeName);
  }

  runAutomaticAlgoritm();
}
