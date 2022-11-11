import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:background_locator_2/location_dto.dart';
//import 'package:battery_plus/battery_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import '../../firebase_options.dart';

class LocationServiceRepository {
  static final LocationServiceRepository _instance =
  LocationServiceRepository._();

  LocationServiceRepository._();

  factory LocationServiceRepository() {
    return _instance;
  }

  // static const String isolateName = 'LocatorIsolate';

  // ignore: unused_field
  int _count = -1;

  Future<void> init(Map<dynamic, dynamic> params) async {
    // ignore: avoid_print
    print("*****Init callback handler");
    if (params.containsKey('countInit')) {
      dynamic tmpCount = params['countInit'];
      if (tmpCount is double) {
        _count = tmpCount.toInt();
      } else if (tmpCount is String) {
        _count = int.parse(tmpCount);
      } else if (tmpCount is int) {
        _count = tmpCount;
      } else {
        _count = -2;
      }
    } else {
      _count = 0;
    }

    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser?.uid.toString())
        .get()
        .then((value) {
      final SendPort? send =
      IsolateNameServer.lookupPortByName(value["isolateName"]);
      send?.send(null);
    });
  }

  Future<void> dispose() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser?.uid.toString())
        .get()
        .then((value) {
      final SendPort? send =
      IsolateNameServer.lookupPortByName(value["isolateName"]);
      send?.send(null);
    });
  }

  Future<void> callback(LocationDto locationDto) async {
    debugPrint("*****Callback LocationDto: ${locationDto.toJson()}");
    try {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      debugPrint("*****Callback Firebase Init Error: ${e.toString()}");
    }

   // Battery battery = Battery();
    //int batteryLevel = await battery.batteryLevel;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser?.uid.toString())
        .update({
      'latitude': locationDto.latitude,
      'longitude': locationDto.longitude,
      'time': Timestamp.now(),
      'isMocked': locationDto.isMocked,
      'batteryLevel': "batteryLevel",
    }).then((value) {
      debugPrint("success");
    }, onError: (error) {
      debugPrint(error);
    });

    await FirebaseFirestore.instance.collection("users")
        .doc(FirebaseAuth.instance.currentUser?.uid.toString())
        .get().then((value) {
      final SendPort? send =
      IsolateNameServer.lookupPortByName(value["isolateName"]);
      send?.send(locationDto);
    });

    _count++;
    debugPrint('***Callback: $_count');
  }
}