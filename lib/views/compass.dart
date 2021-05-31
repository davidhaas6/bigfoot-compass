import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;
import 'package:motion_sensors/motion_sensors.dart';
import 'shapes.dart';
import 'dart:math' as math;

import 'package:matrix4_transform/matrix4_transform.dart';
import 'package:align_positioned/align_positioned.dart';


class Compass extends StatefulWidget {
  @override
  _CompassState createState() => _CompassState();
}

class _CompassState extends State<Compass> with SingleTickerProviderStateMixin {
  Vector3 _accelerometer = Vector3.zero();
  Vector3 _orientation = Vector3.zero();
  Vector3? _lastOrientation;

  // threshold to update/animate compass to a new position (radians)
  static const num _UPDATE_THRESH = 5 * math.pi / 180; 

  // number of samples in the rolling average filter
  static const num _FILTER_SIZE = 5;

  // array to store raw headings for the rolling average filter (radians) 
  List<num> _headingBuffer = [];
  double _filteredHeading = 0;  // the resulting heading of the filter (degrees)

  int? _groupValue = 0;

  Animation<double>? animation;
  AnimationController? controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);

    animation = Tween<double>(begin: 0, end: 360).animate(
      new CurvedAnimation(parent: controller!, curve: Curves.bounceOut),
    );

    motionSensors.accelerometer.listen((AccelerometerEvent event) {
      // setState(() {
      _accelerometer.setValues(event.x, event.y, event.z);
      // });
    });

    motionSensors.isOrientationAvailable().then((available) {
      if (available) {
        motionSensors.orientation.listen((OrientationEvent event) {
          // print('update');
          _orientation.setValues(event.yaw, event.pitch, event.roll);
          double heading = _orientation.x;
          // print(event.yaw);

          if (_lastOrientation == null) {
            _lastOrientation = Vector3.copy(_orientation);
          }

          if (_headingBuffer.length < _FILTER_SIZE) {
            // Instantiate buffer (effectively)
            _headingBuffer = List<num>.filled(5, heading);
          } else {
            // Pop oldest and insert newest element to index 0
            for (int i = _headingBuffer.length - 1; i > 0; i--) {
              _headingBuffer[i] = _headingBuffer[i - 1];
            }
            _headingBuffer[0] = heading;
          }

          if ((_lastOrientation!.x - heading).abs() > _UPDATE_THRESH) {
            // Rolling average filter

            setState(() {
              _filteredHeading = degrees(
                  _headingBuffer.reduce((value, element) => value + element) /
                      _FILTER_SIZE);
              print(_filteredHeading);
            });
            print(
                'initialized animation -- delta: ${(degrees(_lastOrientation!.x) - heading).abs().toStringAsFixed(4)}');

            _lastOrientation = Vector3.copy(_orientation);
          }
        });
      }
      else {
        print('unavailable');
      }
    });

    print('initialized');
  }

  void setUpdateInterval(int? groupValue, int interval) {
    motionSensors.accelerometerUpdateInterval = interval;
    motionSensors.orientationUpdateInterval = interval;
    setState(() {
      _groupValue = groupValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    // print(animation?.value);
    return buildCompass();
  }

  Widget buildCompass() {
    double _width = 100, _height = 100;
    return Center(
      child: AnimatedContainer(
        // Use the properties stored in the State class.
        width: _width,
        height: _height,
        transform: Matrix4Transform()
            .rotateDegrees(_filteredHeading,
                origin: Offset(_width / 2, _height / 2))
            .matrix4,
        decoration: BoxDecoration(
          // color: Colors.amber,
          image: DecorationImage(
            image: AssetImage('assets/arrow.png'),
            fit: BoxFit.fill,
          ),
        ),
        duration: Duration(milliseconds: 1000),
        curve: Curves.easeOut,
      ),
    );
  }

  Widget buildInfoText() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('Update Interval'),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Radio(
              value: 1,
              groupValue: _groupValue,
              onChanged: (dynamic value) =>
                  setUpdateInterval(value, Duration.microsecondsPerSecond ~/ 1),
            ),
            Text("1 FPS"),
            Radio(
              value: 2,
              groupValue: _groupValue,
              onChanged: (dynamic value) => setUpdateInterval(
                  value, Duration.microsecondsPerSecond ~/ 30),
            ),
            Text("30 FPS"),
            Radio(
              value: 3,
              groupValue: _groupValue,
              onChanged: (dynamic value) => setUpdateInterval(
                  value, Duration.microsecondsPerSecond ~/ 60),
            ),
            Text("60 FPS"),
          ],
        ),
        Text('Accelerometer'),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text('z: ${_accelerometer.z.toStringAsFixed(4)}'),
          ],
        ),
        Text('Orientation'),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text('compass: ${degrees(_orientation.x).toStringAsFixed(4)}'),

            // Text('${degrees(_orientation.y).toStringAsFixed(4)}'),
            // Text('${degrees(_orientation.z).toStringAsFixed(4)}'),
          ],
        ),
        SizedBox(height: 64),
      ],
    );
  }
}
