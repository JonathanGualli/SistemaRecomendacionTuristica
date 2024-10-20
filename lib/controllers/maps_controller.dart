import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tesis_v2/services/snackbar_service.dart';

class MapsController extends ChangeNotifier {
// Coordenadas geográficas de los límites de París
  final double parisMinLatitude = 48.815573;
  final double parisMaxLatitude = 48.902145;
  final double parisMinLongitude = 2.224199;
  final double parisMaxLongitude = 2.469921;

  // Coordenadas geográfiocas de los límites de Londres
  final double londonSouthLatitude = 51.384940;
  final double londonNorthLatitude = 51.672343;
  final double londonWestLongitude = -0.351468;
  final double londonEastLongitude = 0.148271;

  final Map<MarkerId, Marker> _markers = {};
  late GoogleMapController mapController;
  //Marker? _startMarker;
  //bool _startPointSelected = false;

  Set<Marker> get markers => _markers.values.toSet();
  final _markersController = StreamController<String>.broadcast();
  //Stream<String> get onMarkerTap => _markersController.stream;

  //Marker? get startMarker => _startMarker;
  //bool get startPointSelected => _startPointSelected;

  final initialCameraPositionParis = const CameraPosition(
    target: LatLng(48.8566, 2.3522),
    zoom: 13,
  );

  final initialCameraPositionLondres = const CameraPosition(
    target: LatLng(51.5074, -0.1278),
    zoom: 13,
  );

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }
/*
  void onTap(LatLng position) {
    final id = _markers.length.toString();
    final markerId = MarkerId(_markers.length.toString());
    final marker = Marker(
      markerId: const MarkerId('start'),
      position: position,
      onTap: () {
        //print(markerId.toString());
        _markersController.sink.add(id);
      },
    );
    _markers[markerId] = marker;
    markers.clear();
    markers.add(marker);
    mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 15)));
    notifyListeners();
  }*/

  Future<String> onTapParis(LatLng position) async {
    if (_isPointInsideParisBounds(position)) {
      // El punto está dentro de los límites de París, puedes realizar la acción deseada aquí
      final id = _markers.length.toString();
      final markerId = MarkerId(_markers.length.toString());
      String detailedAddress = '';
      final marker = Marker(
        markerId: const MarkerId('start'),
        position: position,
        onTap: () {
          //print(markerId.toString());
          _markersController.sink.add(id);
        },
      );
      _markers[markerId] = marker;
      markers.clear();
      markers.add(marker);
      mapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: position, zoom: 15)));

      notifyListeners();

      // Obtener el nombre del punto seleccionado
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        detailedAddress =
            '${placemark.street}, ${placemark.subLocality}, ${placemark.locality}, ${placemark.subAdministrativeArea}, ${placemark.administrativeArea}, ${placemark.postalCode}, ${placemark.country}';
      }

      return detailedAddress;
    } else {
      //El punto está fuera de los límites de París, muestra un mensaje al usuario
      SnackBarService.instance.showSnackBar("Punto fuera de París", false);
      // ignore: avoid_print
      print('fuera de paris');
      return "";
    }
  }

  Future<String> onTapLondon(LatLng position) async {
    if (_isPointInsideLondonBounds(position)) {
      // El punto está dentro de los límites de París, puedes realizar la acción deseada aquí
      final id = _markers.length.toString();
      String detailedAddress = '';
      final markerId = MarkerId(_markers.length.toString());
      final marker = Marker(
        markerId: const MarkerId('start'),
        position: position,
        onTap: () {
          //print(markerId.toString());
          _markersController.sink.add(id);
        },
      );
      _markers[markerId] = marker;
      markers.clear();
      markers.add(marker);
      mapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: position, zoom: 15)));
      notifyListeners();
      // Obtener el nombre del punto seleccionado
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        detailedAddress =
            '${placemark.street}, ${placemark.subLocality}, ${placemark.locality}, ${placemark.subAdministrativeArea}, ${placemark.administrativeArea}, ${placemark.postalCode}, ${placemark.country}';
      }

      return detailedAddress;
    } else {
      //El punto está fuera de los límites de París, muestra un mensaje al usuario
      SnackBarService.instance.showSnackBar("Punto fuera de Londres", false);
      // ignore: avoid_print
      print('fuera de Londres');
      return '';
    }
  }

  bool _isPointInsideParisBounds(LatLng point) {
    return point.latitude >= parisMinLatitude &&
        point.latitude <= parisMaxLatitude &&
        point.longitude >= parisMinLongitude &&
        point.longitude <= parisMaxLongitude;
  }

  bool _isPointInsideLondonBounds(LatLng point) {
    return point.latitude >= londonSouthLatitude &&
        point.latitude <= londonNorthLatitude &&
        point.longitude >= londonWestLongitude &&
        point.longitude <= londonEastLongitude;
  }

/*   void onTap(LatLng position) {
    if (!_startPointSelected) {
      _startMarker = Marker(
        markerId: MarkerId('start'),
        position: position,
        onTap: () {
          print('Start Marker tapped: $position');
          _markersController.sink.add("start");
        },
      );
      _startPointSelected = true;
      notifyListeners();
    }
  } */

/*   void removeStartMarker() {
    _startMarker = null;
    _startPointSelected = false;
    notifyListeners();
  } */

  @override
  void dispose() {
    _markersController.close();
    super.dispose();
  }

/*   void addMarker(LatLng latLng) {
    final String markerIdValue = '${latLng.latitude}_${latLng.longitude}';
    final MarkerId markerId = MarkerId(markerIdValue);

    final Marker marker = Marker(
      markerId: markerId,
      position: latLng,
      infoWindow: InfoWindow(
        title: 'Marcador $markerIdValue',
      ),
    );
  } */
}
