/* import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlaceData {
  late final String id; // Identificador del lugar
  late final String name; // Nombre del lugar
  late final LatLng coordinates; // Coordenadas geográficas (latitud y longitud)
  late final String rating; // Calificación del lugar
  late final String type;

  PlaceData({
    required this.id,
    required this.name,
    required this.coordinates,
    required this.rating,
    required this.type,
  });

  factory PlaceData.fromJson(Map<String, dynamic> json) {
    return PlaceData(
        id: json['id'],
        name: json['name'],
        coordinates: LatLng(
            json['coordinates']['latitude'], json['coordinates']['longitude']),
        rating: json['rating'],
        type: json['type']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'coordinates': {
        'latitude': coordinates.latitude,
        'longitude': coordinates.longitude,
      },
      'rating': rating,
      'type': type
    };
  }
}
 
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlaceData {
  late final String id; // Identificador del lugar
  late final String name; // Nombre del lugar
  late final LatLng coordinates; // Coordenadas geográficas (latitud y longitud)
  late final String rating; // Calificación del lugar
  late final String type;
  late final List<String> weekdayDescriptions; // Horarios de apertura

  PlaceData({
    required this.id,
    required this.name,
    required this.coordinates,
    required this.rating,
    required this.type,
    required this.weekdayDescriptions, // Inicializa la lista de horarios
  });

  factory PlaceData.fromJson(Map<String, dynamic> json) {
    return PlaceData(
      id: json['id'],
      name: json['displayName']
          ['text'], // Cambia el nombre para obtener el texto correcto
      coordinates:
          LatLng(json['location']['latitude'], json['location']['longitude']),
      rating: json['rating']
          .toString(), // Convierte la calificación a string si es necesario
      type: json['type'],
      weekdayDescriptions: List<String>.from(
          json['regularOpeningHours']['weekdayDescriptions'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'coordinates': {
        'latitude': coordinates.latitude,
        'longitude': coordinates.longitude,
      },
      'rating': rating,
      'type': type,
      'regularOpeningHours': {
        'weekdayDescriptions': weekdayDescriptions,
      },
    };
  }
}
*/

import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlaceData {
  late final String id; // Identificador del lugar
  late final String name; // Nombre del lugar
  late final LatLng coordinates; // Coordenadas geográficas (latitud y longitud)
  late final String rating; // Calificación del lugar
  late final String type;
  late final List<String> weekdayDescriptions; // Horarios de apertura
  late final bool
      isOutdoor; // Nuevo atributo para indicar si el lugar es al aire libre
  late final bool isMandatory;
  late final List<String> urlImages;

  PlaceData(
      {required this.id,
      required this.name,
      required this.coordinates,
      required this.rating,
      required this.type,
      required this.weekdayDescriptions,
      required this.isOutdoor,
      required this.isMandatory,
      required this.urlImages});

/*   setImages(List<String> images) {
    urlImages.addAll(images);
  }
 */
  factory PlaceData.fromJson(Map<String, dynamic> json) {
    // Determina si el lugar es al aire libre basado en el tipo
    const outdoorTypes = ['park', 'beach', 'zoo', 'garden'];
    final type = json['type'];
    final isOutdoor = outdoorTypes.contains(type.toLowerCase());

    return PlaceData(
      id: json['id'],
      name: json['displayName']['text'],
      coordinates:
          LatLng(json['location']['latitude'], json['location']['longitude']),
      rating: json['rating'].toString(),
      type: type,
      weekdayDescriptions: List<String>.from(
          json['regularOpeningHours']['weekdayDescriptions'] ?? []),
      isOutdoor: isOutdoor,
      isMandatory: json['isMandatory'],
      urlImages: List.empty(growable: true),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'coordinates': {
        'latitude': coordinates.latitude,
        'longitude': coordinates.longitude,
      },
      'rating': rating,
      'type': type,
      'regularOpeningHours': {
        'weekdayDescriptions': weekdayDescriptions,
      },
      'isOutdoor': isOutdoor,
      'isMandatory': isMandatory,
    };
  }
}

class Itinerary {
  final List<PlaceData> places;
  final DateTime date;

  Itinerary({
    required this.places,
    required this.date,
  });
}
