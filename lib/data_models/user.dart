import 'package:firebase_database/firebase_database.dart';

class LoggedInUser {
  String? fullName;
  String? email;
  String? phone;
  String? id;

  LoggedInUser({
    this.email,
    this.fullName,
    this.id,
    this.phone,
  });

  LoggedInUser.fromSnapshot(DataSnapshot snapshot) {
    id = snapshot.key;
    phone = (snapshot.value as Map)["phone"];
    email = (snapshot.value as Map)["email"];
    fullName = (snapshot.value as Map)["fullName"];
  }
}
