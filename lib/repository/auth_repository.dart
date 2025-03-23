// ignore_for_file: unused_field

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:nextbai/constants/constants.dart';
import 'package:nextbai/models/user_hive.dart';
import 'package:nextbai/models/user_model.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Exception thrown when the email provided is already in use
class EmailAlreadyInUseException implements Exception {}

/// Exception thrown when the email provided is invalid
class InvalidEmailException implements Exception {}

/// Exception thrown when the password provided is too weak
class WeakPasswordException implements Exception {}

/// Exception thrown when the user is not found
class UserNotFoundException implements Exception {}

/// Exception thrown when the password provided is wrong
class WrongPasswordException implements Exception {}

/// Exception thrown when networks issues prevent authentication
class NetworkException implements Exception {}

/// Exception thrown for any other authentication error
class GenericAuthException implements Exception {}

class AuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;
  final Box _authBox = Hive.box('authBox');

  AuthRepository({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.standard();

  /// Stream of [UserModel] which will emit the current user when the authentication state changes
  Stream<UserModel> get user {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        return UserModel.empty;
      }

      final firestoreUser = await _getUserFromFirestore(firebaseUser.uid);
      if (firestoreUser != null) {
        _saveUserToHive(firestoreUser);
        return firestoreUser;
      }

      return UserModel.fromFirebaseUser(firebaseUser);
    });
  }

  /// Fetch user from Firestore by ID
  Future<UserModel?> _getUserFromFirestore(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final user = UserModel.fromFirestore(doc);
        _saveUserToHive(user); // Store in Hive
        return user;
      }
      return null;
    } catch (e) {
      log('Error fetching user from Firestore: $e');
      return null;
    }
  }

  /// Returns the current user
  Future<UserModel> getCurrentUser() async {
    // Checks if user exists in Hive
    final hiveUser = _getUserFromHive();
    if (hiveUser != null) {
      return hiveUser;
    }

    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) {
      return UserModel.empty;
    }

    // Try to get user from Firestore first
    final firestoreUser = await _getUserFromFirestore(firebaseUser.uid);
    if (firestoreUser != null) {
      return firestoreUser;
    }

    // Fallback to creating from Firebase user
    return UserModel.fromFirebaseUser(firebaseUser);
  }

  bool isUserLoggedIn() {
    return _firebaseAuth.currentUser != null;
  }

  // Register user with Email and Password
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String firstname,
    required String lastname,
  }) async {
    try {
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      log("Firebase sign-up success: ${userCredential.user?.uid}");

      final user = userCredential.user;
      if (user == null) {
        throw GenericAuthException();
      }

      await user.updateDisplayName('$firstname $lastname');

      // Create user document in Firestore
      final newUser = UserModel(
        id: user.uid,
        firstname: firstname,
        lastname: lastname,
        email: email,
        profileImageUrl: user.photoURL,
        location: null,
        address: null,
        isLocationSet: false,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      await firestore.collection('users').doc(user.uid).set(newUser.toMap());
      _saveUserToHive(newUser);
      return newUser;
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw EmailAlreadyInUseException();
      } else if (e.code == 'invalid-email') {
        throw InvalidEmailException();
      } else if (e.code == 'weak-password') {
        throw WeakPasswordException();
      } else if (e.code == 'network-request-failed') {
        throw NetworkException();
      }
      throw GenericAuthException();
    } catch (_) {
      throw GenericAuthException();
    }
  }

  // Login with email and password
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw GenericAuthException();
      }

      // Update last login time
      await firestore.collection('users').doc(user.uid).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
      // Convert Firebase user to UserModel
      final userModel = await _getUserFromFirestore(user.uid) ??
          UserModel.fromFirebaseUser(user);

      _saveUserToHive(userModel);

      return userModel;
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw UserNotFoundException();
      } else if (e.code == 'wrong-password') {
        throw WrongPasswordException();
      } else if (e.code == 'invalid-email') {
        throw InvalidEmailException();
      }
      throw GenericAuthException();
    } catch (_) {
      throw GenericAuthException();
    }
  }

  /// Signs in with Google
  Future<UserModel> signInWithGoogle() async {
    try {
      final googleSignInAccount = await _googleSignIn.signIn();
      if (googleSignInAccount == null) {
        throw GenericAuthException();
      }

      final googleSignInAuthentication =
          await googleSignInAccount.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        throw GenericAuthException();
      }

      // Fetch user from Firestore
      UserModel? userModel;
      try {
        userModel = await _getUserFromFirestore(user.uid);
      } catch (e) {
        log(e.toString());
        throw GenericAuthException(); // Custom exception for Firestore issues
      }

      if (userModel == null) {
        // Extract name components safely
        final names = user.displayName?.split(' ') ?? ['User'];
        final firstname = names.first;
        final lastname = names.length > 1 ? names.sublist(1).join(' ') : '';

        // Create new user in Firestore
        userModel = UserModel(
          id: user.uid,
          firstname: firstname,
          lastname: lastname,
          email: user.email ?? '',
          profileImageUrl: user.photoURL,
          location: null,
          address: null,
          isLocationSet: false,
          createdAt:
              DateTime.now(), // Consider using FieldValue.serverTimestamp()
          lastLoginAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(userModel.toMap());
        _saveUserToHive(userModel);
      } else {
        // Update last login time
        await _firestore.collection('users').doc(user.uid).update({
          'lastLoginAt': FieldValue.serverTimestamp(),
        });

        // Update the userModel with the new login time
        userModel = userModel.copyWith(lastLoginAt: DateTime.now());
      }

      return userModel;
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'network-request-failed') {
        throw NetworkException();
      }
      log("FirebaseAuthException: ${e.message}");
      throw GenericAuthException();
    } catch (e) {
      log("Google Sign-In Error: $e");
      throw GenericAuthException();
    }
  }

  Future<UserModel> signInWithApple() async {
    try {
      // Begin the Apple sign-in process
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create an OAuthCredential from the Apple credential
      final oauthCredential =
          firebase_auth.OAuthProvider('apple.com').credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      // Sign in to Firebase with the Apple OAuth credential
      final userCredential =
          await _firebaseAuth.signInWithCredential(oauthCredential);
      final user = userCredential.user;

      if (user == null) {
        throw GenericAuthException();
      }

      // Fetch user from Firestore
      UserModel? userModel;
      try {
        userModel = await _getUserFromFirestore(user.uid);
      } catch (e) {
        log(e.toString());
        throw GenericAuthException();
      }

      if (userModel == null) {
        // Apple sign-in might not always provide names, handle accordingly
        String firstname = credential.givenName ?? '';
        String lastname = credential.familyName ?? '';

        // If names weren't provided or are empty, extract from displayName or use defaults
        if (firstname.isEmpty && lastname.isEmpty) {
          final names = user.displayName?.split(' ') ?? ['User'];
          firstname = names.first;
          lastname = names.length > 1 ? names.sublist(1).join(' ') : '';
        }

        // Create new user in Firestore
        userModel = UserModel(
          id: user.uid,
          firstname: firstname,
          lastname: lastname,
          email: user.email ?? credential.email ?? '',
          profileImageUrl: user.photoURL,
          location: null,
          address: null,
          isLocationSet: false,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(userModel.toMap());
        _saveUserToHive(userModel);
      } else {
        // Update last login time
        await _firestore.collection('users').doc(user.uid).update({
          'lastLoginAt': FieldValue.serverTimestamp(),
        });

        // Update the userModel with the new login time
        userModel = userModel.copyWith(lastLoginAt: DateTime.now());
      }

      return userModel;
    } on SignInWithAppleException catch (e) {
      log("Apple Sign-In Exception: $e");
      throw GenericAuthException();
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'network-request-failed') {
        throw NetworkException();
      }
      log("FirebaseAuthException: ${e.message}");
      throw GenericAuthException();
    } catch (e) {
      log("Apple Sign-In Error: $e");
      throw GenericAuthException();
    }
  }

// Save user to Hive Storage
  void _saveUserToHive(UserModel user) {
    final hiveUser = UserHive(
      id: user.id,
      email: user.email,
    );
    _authBox.put("currentUser", hiveUser);
  }

  /// Get user from Hive storage
  UserModel? _getUserFromHive() {
    final hiveUser = _authBox.get('currentUser') as UserHive?;
    if (hiveUser == null) return null;

    return UserModel(
      id: hiveUser.id,
      firstname: "", // Placeholder since Hive doesn't store this
      lastname: "",
      email: hiveUser.email,
      profileImageUrl: null,
      location: null,
      address: null,
      isLocationSet: false,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
  }

  // Signout user and clear hive storage
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _authBox.delete("currentUser");
  }
}
