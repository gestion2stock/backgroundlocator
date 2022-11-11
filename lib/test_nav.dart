import 'package:flutter/material.dart';
import 'dart:isolate';

import 'kumar1.dart';

class BackgroundLocationTest extends StatefulWidget {
  const BackgroundLocationTest({Key? key}) : super(key: key);

  @override
  BackgroundLocationTestPageState createState() => BackgroundLocationTestPageState();
}

class BackgroundLocationTestPageState extends State<BackgroundLocationTest> {
  ReceivePort port = ReceivePort();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //var lL = context.watch<UpdateLocation>().currentLocation;
    return WillPopScope(
      onWillPop: () async => false,
      child:  Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                  onPressed: () => onStart(),
                  child: const Text('Start')),

              TextButton(
                  onPressed: () => onStop(),
                  child: const Text('Stop'))
            ],
          ),
        ),
      ),
    );
  }
}
