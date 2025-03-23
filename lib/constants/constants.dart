import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

FirebaseAuth auth = FirebaseAuth.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;
Uuid uuid = const Uuid();
FirebaseStorage storage = FirebaseStorage.instance;
FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
