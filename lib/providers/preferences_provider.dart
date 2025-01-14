import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tesis_v2/models/place_model.dart';

class PreferencesProvider extends ChangeNotifier {
  static PreferencesProvider instance = PreferencesProvider();

  String? _selectedCity; // Ciudad seleccionada
  LatLng? _initialLocation; // Punto de partida
  double _radius =
      4000; //Por defecto sera de 4km. En el futuro sea modificable por el usuario
  List<String> _preferences = []; // Lista de preferencias
  TimeOfDay? _startTime; // Hora inicio del recorrido
  TimeOfDay? _endTime; //Hora fin del recorrido
  DateTime _date = DateTime.now(); // Fecha del itinerario
  List<PlaceData>? _specificPoiSelected; // Puntos de interés específicos
  List<PlaceData>? _places; // Totos los POI
  List<PlaceData> _resultPlaces = List.empty(growable: true); // Resultado final
  List<double> _timeResultPlaces =
      List.empty(growable: true); // Resultado final
  List<Map<String, dynamic>> _groupedData = [];
  double _additionalTime = 0;
  List<String> _openingsPeriods = [];

  //Getters

  DateTime getDate() {
    return _date;
  }

  String? getStartTIme() {
    DateTime fechaHoraInicio = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _startTime!.hour,
      _startTime!.minute,
    );
    return '${fechaHoraInicio.toIso8601String()}Z';
  }

  String? getEndTime() {
    DateTime fechaHoraFin = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _endTime!.hour,
      _endTime!.minute,
    );
    return '${fechaHoraFin.toIso8601String()}Z';
  }

  String? getSelectedCity() {
    return _selectedCity;
  }

  LatLng? getInitialLocation() {
    return _initialLocation;
  }

  double getRadius() {
    return _radius;
  }

  List<String>? getPreferences() {
    return _preferences;
  }

  List<PlaceData>? getSpecificPoiPreferences() {
    return _specificPoiSelected;
  }

  List<PlaceData>? getPlaces() {
    return _places;
  }

  List<PlaceData> getResultPlaces() {
    return _resultPlaces;
  }

  List<double> getTimeResultPlaces() {
    return _timeResultPlaces;
  }

  double getAdditionalTime() {
    return _additionalTime;
  }

  List<String> getOpeningsPeriods() {
    return _openingsPeriods;
  }

  // Getters
  String? get selectedCity => _selectedCity;
  LatLng? get initialLocation => _initialLocation;
  double? get radius => _radius;
  List<String> get preferences => _preferences;
  List<Map<String, dynamic>> get groupedData => _groupedData;

  // Setters

  void setDate(DateTime date) {
    _date = date;
    notifyListeners();
  }

  void setStartTime(TimeOfDay startTime) {
    _startTime = startTime;
    notifyListeners();
  }

  void setEndTime(TimeOfDay endTime) {
    _endTime = endTime;
    notifyListeners();
  }

  void setSelectedCity(String city) {
    _selectedCity = city;
    notifyListeners();
  }

  void setInitialLocation(LatLng location) {
    _initialLocation = location;
    notifyListeners();
  }

  void setRadius(double radius) {
    _radius = radius;
    notifyListeners();
  }

  void setPreferences(List<String> preferences) {
    _preferences = preferences;
    notifyListeners();
  }

  void addPreference(String preference) {
    _preferences.add(preference);
    notifyListeners();
  }

  void removePreference(String preference) {
    _preferences.remove(preference);
    notifyListeners();
  }

  void setSpecificPoiPreferences(List<PlaceData> specificPreferences) {
    _specificPoiSelected = specificPreferences;
    notifyListeners();
  }

  void setPlaces(List<PlaceData> places) {
    _places = places;
    notifyListeners();
  }

  void setResultPlaces(List<PlaceData> resultPlaces) {
    _resultPlaces = resultPlaces;
    notifyListeners();
  }

  void setTimeResultPlaces(List<double> timeResultPlaces) {
    _timeResultPlaces = timeResultPlaces;
    notifyListeners();
  }

  void setOpeningsPeriods(List<String> openingsPeriods) {
    _openingsPeriods = openingsPeriods;
    notifyListeners();
  }

  void setAdditionalTime(double additionalTime) {
    _additionalTime = additionalTime;
    notifyListeners();
  }

  set groupedData(List<Map<String, dynamic>> data) {
    _groupedData = data;
    notifyListeners();
  }
}
