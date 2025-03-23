// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel extends Equatable {
  final String id;
  final String firstname;
  final String lastname;
  final String email;
  final String? profileImageUrl;
  final GeoPoint? location;
  final String? address;
  final bool isLocationSet;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const UserModel({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
    this.profileImageUrl,
    this.location,
    this.address,
    this.isLocationSet = false,
    required this.createdAt,
    this.lastLoginAt,
  });

  static final empty = UserModel(
    id: '',
    firstname: '',
    lastname: '',
    email: '',
    profileImageUrl: null,
    location: null,
    address: null,
    isLocationSet: false,
    createdAt: DateTime(1970),
    lastLoginAt: null,
  );

  /// Convenience getter to determine whether the current user is empty
  bool get isEmpty => this == UserModel.empty;

  /// Convenience getter to determine whether the current user is not empty
  bool get isNotEmpty => this != UserModel.empty;

  /// Full name getter
  String get fullName => '$firstname $lastname';

  static UserModel fromFirebaseUser(User user) {
    return UserModel(
      id: user.uid,
      firstname: user.displayName?.split(" ").first ?? "",
      lastname: user.displayName?.split(' ').skip(1).join(' ') ?? '',
      email: user.email ?? "",
      profileImageUrl: user.photoURL,
      isLocationSet: false,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
  }

  static UserModel fromFirestore(DocumentSnapshot userDoc) {
    final data = userDoc.data() as Map<String, dynamic>;

    return UserModel(
      id: userDoc.id,
      firstname: data['firstname'] ?? '',
      lastname: data['lastname'] ?? '',
      email: data['email'] ?? '',
      profileImageUrl: data['profileImageUrl'],
      location: data['location'],
      address: data['address'],
      isLocationSet: data['isLocationSet'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLoginAt: data['lastLoginAt'] != null
          ? (data['lastLoginAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'location': location,
      'address': address,
      'isLocationSet': isLocationSet,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt':
          lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
    };
  }

  UserModel copyWith({
    String? id,
    String? firstname,
    String? lastname,
    String? email,
    String? profileImageUrl,
    GeoPoint? location,
    String? address,
    bool? isLocationSet,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      location: location ?? this.location,
      address: address ?? this.address,
      isLocationSet: isLocationSet ?? this.isLocationSet,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  @override
  List<Object?> get props {
    return [
      id,
      firstname,
      lastname,
      email,
      profileImageUrl,
      location,
      address,
      isLocationSet,
      createdAt,
      lastLoginAt,
    ];
  }
}
