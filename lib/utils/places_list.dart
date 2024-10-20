import 'package:flutter/material.dart';

class PlacesList {
  final List<Map<String, dynamic>> lugares = [
    {
      "icon": Icons.attractions,
      "color": Colors.blue,
      "name": "Parque de atracciones",
      "type": "amusement_park"
    },
    {
      "icon": Icons.water,
      "color": Colors.cyan,
      "name": "Acuario",
      "type": "aquarium"
    },
    {
      "icon": Icons.audiotrack_sharp,
      "color": Colors.orange,
      "name": "Galería de arte",
      "type": "art_gallery"
    },
    {
      "icon": Icons.local_bar,
      "color": Colors.redAccent,
      "name": "Bar",
      "type": "bar"
    },
    {
      "icon": Icons.circle,
      "color": Colors.purple,
      "name": "Bolera",
      "type": "bowling_alley"
    },
    {
      "icon": Icons.local_cafe,
      "color": Colors.brown,
      "name": "Cafetería",
      "type": "cafe"
    },
    {
      "icon": Icons.campaign,
      "color": Colors.greenAccent,
      "name": "Camping",
      "type": "campground"
    },
    {
      "icon": Icons.casino,
      "color": Colors.black,
      "name": "Casino",
      "type": "casino"
    },
    {
      "icon": Icons.church,
      "color": Colors.blueGrey,
      "name": "Iglesia",
      "type": "church"
    },
    {
      "icon": Icons.location_city,
      "color": Colors.lightBlue,
      "name": "Ayuntamiento",
      "type": "city_hall"
    },
    {
      "icon": Icons.checkroom,
      "color": Colors.pink,
      "name": "Tienda de ropa",
      "type": "clothing_store"
    },
    {
      "icon": Icons.apartment,
      "color": Colors.teal,
      "name": "Embajada",
      "type": "embassy"
    },
    {
      "icon": Icons.temple_hindu,
      "color": Colors.amber,
      "name": "Templo hindú",
      "type": "hindu_temple"
    },
    {
      "icon": Icons.library_books,
      "color": Colors.deepOrange,
      "name": "Biblioteca",
      "type": "library"
    },
    {
      "icon": Icons.hotel,
      "color": Colors.indigo,
      "name": "Alojamiento",
      "type": "lodging"
    },
    {
      "icon": Icons.mosque,
      "color": Colors.blueAccent,
      "name": "Mezquita",
      "type": "mosque"
    },
    {
      "icon": Icons.local_movies,
      "color": Colors.red,
      "name": "Cine",
      "type": "movie_theater"
    },
    {
      "icon": Icons.museum,
      "color": Colors.yellow,
      "name": "Museo",
      "type": "museum"
    },
    {
      "icon": Icons.nightlife,
      "color": Colors.deepPurple,
      "name": "Club nocturno",
      "type": "night_club"
    },
    {
      "icon": Icons.park,
      "color": Colors.green,
      "name": "Parque",
      "type": "park"
    },
    {
      "icon": Icons.restaurant,
      "color": Colors.redAccent,
      "name": "Restaurante",
      "type": "restaurant"
    },
    {
      "icon": Icons.shopping_bag,
      "color": Colors.purpleAccent,
      "name": "Centro comercial",
      "type": "shopping_mall"
    },
    {
      "icon": Icons.spa,
      "color": Colors.pinkAccent,
      "name": "Spa",
      "type": "spa"
    },
    {
      "icon": Icons.sports_soccer,
      "color": Colors.deepOrangeAccent,
      "name": "Estadio",
      "type": "stadium"
    },
    {
      "icon": Icons.attractions,
      "color": Colors.tealAccent,
      "name": "Atracción turística",
      "type": "tourist_attraction"
    },
    {
      "icon": Icons.train,
      "color": Colors.lightBlueAccent,
      "name": "Estación de tren",
      "type": "train_station"
    },
    {
      "icon": Icons.transfer_within_a_station,
      "color": Colors.amberAccent,
      "name": "Estación de tránsito",
      "type": "transit_station"
    },
    {
      "icon": Icons.travel_explore,
      "color": Colors.lightGreen,
      "name": "Agencia de viajes",
      "type": "travel_agency"
    },
    {
      "icon": Icons.school,
      "color": Colors.brown,
      "name": "Universidad",
      "type": "university"
    },
    {
      "icon": Icons.pets,
      "color": Colors.pinkAccent,
      "name": "Zoológico",
      "type": "zoo"
    },
    {
      "icon": Icons.comment_bank_rounded,
      "color": Colors.teal,
      "name": "Centro cultural",
      "type": "cultural_center"
    },
  ];
}

Map<String, dynamic> getPlaceDetails(String type) {
  return PlacesList().lugares.firstWhere(
        (place) => place["type"] == type,
        orElse: () => {
          "icon": Icons.help_outline,
          "color": Colors.grey,
          "name": "Unknown",
          "type": "unknown"
        },
      );
}
