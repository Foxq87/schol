import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String username;
  final String email;
  final String photoUrl;
  final String displayName;
  final String bio;
  final String grade;
  final String dormType;
  final int dormNumber;
  final double rating;
  final bool isVendor;
  final int approve;
  final bool tripMode;
  final bool isDeliverer;
  final String phoneNumber;
  final String password;
  final String schoolNumber;
  final Timestamp creation;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.photoUrl,
    required this.displayName,
    required this.bio,
    required this.rating,
    required this.isVendor,
    required this.approve,
    required this.grade,
    required this.tripMode,
    required this.password,
    required this.phoneNumber,
    required this.schoolNumber,
    required this.creation,
    required this.isDeliverer,
    required this.dormType,
    required this.dormNumber,
  });

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      id: doc['id'],
      username: doc['username'],
      email: doc['email'],
      photoUrl: doc['photoUrl'],
      displayName: doc['displayName'],
      bio: doc['bio'],
      rating: doc['rating'],
      isVendor: doc['isVendor'],
      approve: doc['approve'],
      grade: doc['grade'],
      tripMode: doc['tripMode'],
      password: doc['password'],
      phoneNumber: doc['phoneNumber'],
      schoolNumber: doc['schoolNumber'],
      creation: doc['creation'],
      isDeliverer: doc['isDeliverer'],
      dormNumber: doc['dormNumber'],
      dormType: doc['dormType'],
    );
  }
}
