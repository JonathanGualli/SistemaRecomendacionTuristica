import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  late final String id;
  late final String name;
  late final String email;
  late final String? phone;
  late final String image;
  late final List<String> preferences;

  UserData.empty()
      : id = '',
        name = '',
        email = '',
        phone = '',
        image = '',
        preferences = [];

  UserData({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.image,
    required this.preferences,
  });

  factory UserData.fromFirestore(DocumentSnapshot snapshot) {
    var data = snapshot.data() as Map<String, dynamic>;
    return UserData(
      id: snapshot.id,
      name: data["name"],
      email: data["email"],
      phone: data["phone"],
      image: data["image"],
      preferences: List<String>.from(data["preferences"]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      "image": image,
      'preferences': preferences,
    };
  }
}
