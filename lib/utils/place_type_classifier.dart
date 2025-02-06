import 'dart:math';

class PlaceTypeClassifier {
  static const List<String> outdoorTypes = [
    'farm',
    'amusement_center',
    'amusement_park',
    'dog_park',
    'hiking_area',
    'historical_landmark',
    'marina',
    'national_park',
    'park',
    'tourist_attraction',
    'zoo',
    'campground',
    'rv_park',
    'cemetery',
    'playground',
    'stadium',
    'swimming_pool',
    'sports_complex',
    'camping_cabin',
    'golf_course',
  ];

  static bool isOutdoor(String type) {
    return outdoorTypes.contains(type.toLowerCase());
  }
}

List<List<String>> generateInitialPopulationMain(
    int populationSize, List<String> names) {
  List<List<String>> population = [];
  for (int i = 0; i < populationSize; i++) {
    List<String> newRoute = List.from(names);
    // Mezcla ciudades aleatoriamente by JG
    newRoute.shuffle();
    population.add(newRoute);
  }
  return population;
}

String places = '';

double calculateFitness(List<String> route, List<List<double>> distnaceMatrix) {
  double totalDIstance = 0.0;
  List<String> names = getNamesOfPlaces(places);
  for (int i = 0; i < route.length - 1; i++) {
    int position1 = names.indexOf(route[i]);
    int position2 = names.indexOf(route[i + 1]);
    totalDIstance += distnaceMatrix[position1][position2];
  }
  int position1 = names.indexOf(route.last);
  int position2 = names.indexOf(route.first);
  // Regresar al punto inicial by JG
  totalDIstance += distnaceMatrix[position1][position2];
  return totalDIstance;
}

List<String> getNamesOfPlaces(String hola) {
  return [];
}

List<String> selection(
    List<List<String>> population, List<double> fitnessValues) {
  // Cuantos individuos serán seleccionados para el torneo by JG
  int tournamentSize = 3;
  List<int> selected = [];
  for (int i = 0; i < tournamentSize; i++) {
    int randomIndex = Random().nextInt(population.length);
    selected.add(randomIndex);
  }
  // Ordenra los índices seleccionados en base a sus valores fitness by JG
  selected.sort((a, b) => fitnessValues[a].compareTo(fitnessValues[b]));
  return population[selected.first];
}

List<String> crossover(List<String> parent1, List<String> parent2) {
  // Establece indices aleatorios dentro para start y end by JG
  int start = Random().nextInt(parent1.length);
  int end = Random().nextInt(parent1.length - start) + start;
  List<String> offspring = List.filled(parent1.length, '-1');
  for (int i = start; i < end; i++) {
    // Copia los genbes del primer padre by JG
    offspring[i] = parent1[i];
  }
  int currentIndex = end % parent1.length;

  for (int i = 0; i < parent2.length; i++) {
    if (!offspring.contains(parent2[i])) {
      // Si el gen del segundo padre no está en la descenencia, lo añade by JG
      offspring[currentIndex] = parent2[i];
      currentIndex = (currentIndex + 1) % parent1.length;
    }
  }
  return offspring;
}

List<String> mutate(List<String> route) {
  // Indice 1 y 2 aleatorios dentro de la ruta by JG
  int index1 = Random().nextInt(route.length);
  int index2 = Random().nextInt(route.length);
  // Crea una ruta temporal by JG
  String temp = route[index1];
  // Copea indice 1 en indice 2 by JG
  route[index1] = route[index2];
  // Pega el indice 1 en el indice 2 by JG
  route[index2] = temp;

  return route;
}
