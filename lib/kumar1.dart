import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/location_dto.dart';
import 'package:background_locator_2/settings/android_settings.dart';
import 'package:background_locator_2/settings/ios_settings.dart';
import 'package:background_locator_2/settings/locator_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart' as perm;
import 'kumar3.dart';

loc.Location location = loc.Location();

getIsolateName() async {
   User? currentUser = FirebaseAuth.instance.currentUser;
  String abc = "";
  var something = await FirebaseFirestore.instance.collection("users")
      .doc(currentUser!.uid)
      .get();
  abc = something.data()!["isolateName"];
  return abc;
}

setIsolateName() async {
  User? currentUser = FirebaseAuth.instance.currentUser;
  String randomIsolate = "ISOLATE${Random().nextInt(100000)}";
  await FirebaseFirestore.instance.collection("users")
      .doc(currentUser!.uid)
      .set({"isolateName": randomIsolate}, SetOptions(merge: true));
}

checkGps() async {
  if (!await location.serviceEnabled()) {
    var locStatus = await location.requestService();

    if (!locStatus) {
      return false;
    }
  } else {
    return true;
  }
}

Future<void> initPlatformState() async {
  debugPrint('Initializing...');
  await BackgroundLocator.initialize();
  debugPrint('Initialization done');
  var isRunning = await BackgroundLocator.isServiceRunning();

  isRunning = isRunning;
}

onStop() async {
  String isolateName = await getIsolateName();

  IsolateNameServer.removePortNameMapping(isolateName);

  await BackgroundLocator.unRegisterLocationUpdate().then((value) async {
    var isRunning = await BackgroundLocator.isServiceRunning();
    debugPrint('Is Running: ${isRunning.toString()}');
    isRunning = isRunning;
    await setIsolateName();
  });
  await location.enableBackgroundMode(enable: false).then((value) {
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else if (Platform.isIOS) {
      exit(0);
    }
  });
}

Future<void> updateUI(LocationDto data) async {
  await updateNotificationText(data);
}

updateNotificationText(LocationDto data) async {
  await BackgroundLocator.updateNotificationText(
      title: "Location Service",
      msg: "Latitude: ${data.latitude}, Longitude: ${data.longitude}");
}

checkLocationPermission() async {
  const perm.Permission locationPermission = perm.Permission.location;

  bool isPermanentDenied = await locationPermission.isPermanentlyDenied;
  bool isDenied = await locationPermission.isDenied;
  bool isLimited = await locationPermission.isLimited;
  bool isRestricted = await locationPermission.isRestricted;
  bool isOnlyWhenInUse = await perm.Permission.locationWhenInUse.isGranted;
  bool isAlways = await perm.Permission.locationAlways.isGranted;

  if (isPermanentDenied ||
      isDenied ||
      isLimited ||
      isRestricted ||
      !isAlways ||
      isOnlyWhenInUse) {
    await perm.Permission.location.request();

    perm.PermissionStatus locPermissionAll =
    await perm.Permission.locationAlways.request();

    if (locPermissionAll.isGranted) {
      return true;
    } else {
      await perm.openAppSettings();
      return false;
    }
  } else {
    return false;
  }
}

onStart() async {
  debugPrint("Illidivi 01");
  if (await checkLocationPermission()) {
    await location.enableBackgroundMode(enable: true);

    debugPrint("Illidivi 02");
    await Future.delayed(const Duration(seconds: 1), () async {
      startLocator();

      debugPrint("Illidivi 04");
    });

    var isRunning = await BackgroundLocator.isServiceRunning();

    debugPrint("Is Running: ${isRunning.toString()}");
    isRunning = isRunning;
  } else {
    debugPrint("Location permission not granted");
  }
}


void startLocator() async {
  debugPrint("Illidivi 03");
  Map<String, dynamic> data = {'countInit': 1};

  return await BackgroundLocator.registerLocationUpdate(
    LocationCallbackHandler.callback,
    initCallback: LocationCallbackHandler.initCallback,
    initDataCallback: data,
    disposeCallback: LocationCallbackHandler.disposeCallback,
    iosSettings: const IOSSettings(
        accuracy: LocationAccuracy.NAVIGATION,
        distanceFilter: 0,
        stopWithTerminate: true),
    autoStop: false,
    androidSettings: const AndroidSettings(
      accuracy: LocationAccuracy.NAVIGATION,
      interval: 120,
      distanceFilter: 0,
      client: LocationClient.google,
      androidNotificationSettings: AndroidNotificationSettings(
        notificationChannelName: 'Teju Masala Location Tracking',
        notificationTitle: 'Teju Masala Tracking',
        notificationMsg: 'Your location is being tracked by Teju Masala',
        notificationBigMsg:
        'Background location is ON to keep the app up-to-date with your location. This is required for main features to work properly when the app is not running.',
        notificationIconColor: Colors.grey,
        notificationTapCallback: LocationCallbackHandler.notificationCallback,
      ),
    ),
  );
}