// ignore_for_file: avoid_print
import 'package:background_locator_2/location_dto.dart';
import 'kumar2.dart';

class LocationCallbackHandler {
  static initCallback(Map<dynamic, dynamic> params) async {
    LocationServiceRepository myLocationCallbackRepository =
    LocationServiceRepository();
    await myLocationCallbackRepository.init(params);
  }

  static disposeCallback() async {
    LocationServiceRepository myLocationCallbackRepository =
    LocationServiceRepository();
    await myLocationCallbackRepository.dispose();
  }

  static callback(LocationDto locationDto) async {
    LocationServiceRepository myLocationCallbackRepository =
    LocationServiceRepository();
    await myLocationCallbackRepository.callback(locationDto);
  }

  static notificationCallback() async {
    print('***notificationCallback');
  }
}