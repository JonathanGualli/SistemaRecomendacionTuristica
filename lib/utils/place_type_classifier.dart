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
