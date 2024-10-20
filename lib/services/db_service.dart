import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tesis_v2/models/user_%20model.dart';
import 'package:tesis_v2/providers/auth_provider.dart';

class DBService {
  static DBService instance = DBService();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final String _userCollection = "Users";

  Future<void> createdUserInDB(String uid, String name, String email,
      String phone, String imageURL) async {
    try {
      await _db.collection(_userCollection).doc(uid).set({
        "name": name,
        "email": email,
        "phone": phone,
        "image": imageURL,
        "preferences": [],
      });
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  Future<bool> existUserInDatabase(String uid) async {
    try {
      DocumentSnapshot user =
          await _db.collection(_userCollection).doc(uid).get();

      if (user.exists) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
      return false;
    }
  }

  Future<UserData> get getUserData async {
    final docSnapshot = await _db
        .collection(_userCollection)
        .doc(AuthProvider.instance.user!.uid)
        .get();
    final userData = UserData.fromFirestore(docSnapshot);
    //print(userData);
    return userData;
  }

  Stream<UserData> getUserDataStream(String userID) {
    return _db
        .collection(_userCollection)
        .doc(userID)
        .snapshots()
        .map((snapshot) => UserData.fromFirestore(snapshot));
  }

  Future<void> updateUserInDB(UserData user) async {
    try {
      await _db.collection(_userCollection).doc(user.id).update({
        "name": user.name,
        "phone": user.phone,
        "image": user.image,
        //"preferences": user.preferences,
      });
      print("paso por aqui we");
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  Future<void> updatePreferencesInDB(List<String> preferences) async {
    await _db
        .collection(_userCollection)
        .doc(AuthProvider.instance.user!.uid)
        .update({'preferences': preferences});
  }
}
