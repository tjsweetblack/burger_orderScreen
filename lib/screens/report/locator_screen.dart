import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vector_math/vector_math.dart' show degrees, radians;

class LocatorScreen extends StatefulWidget {
  final double reportLatitude;
  final double reportLongitude;

  LocatorScreen({required this.reportLatitude, required this.reportLongitude});

  @override
  _LocatorScreenState createState() => _LocatorScreenState();
}

class _LocatorScreenState extends State<LocatorScreen> {
  Position? _currentPosition;
  double _distanceToReport = 0.0;
  double _bearingToReport = 0.0;

  @override
  void initState() {
    super.initState();
    _startLocationUpdates();
  }

  Future<void> _startLocationUpdates() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Handle permission denial
        return;
      }
    }

    Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0, // Try setting distanceFilter to 0
      ),
    ).listen((Position position) {
      if (mounted) {
        // Check if the widget is still in the tree
        setState(() {
          _currentPosition = position;
          _distanceToReport = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            widget.reportLatitude,
            widget.reportLongitude,
          );
          _bearingToReport = _calculateBearing(
            position.latitude,
            position.longitude,
            widget.reportLatitude,
            widget.reportLongitude,
          );
        });
      }
    });
  }

  double _calculateBearing(double currentLat, double currentLon,
      double targetLat, double targetLon) {
    double startLat = radians(currentLat);
    double startLong = radians(currentLon);
    double endLat = radians(targetLat);
    double endLong = radians(targetLon);

    double dLong = endLong - startLong;

    double dPhi = math.log(
      math.tan(endLat / 2.0 + math.pi / 4.0) /
          math.tan(startLat / 2.0 + math.pi / 4.0),
    );
    if (dLong > math.pi) {
      dLong = -(2 * math.pi - dLong);
    } else if (dLong < -math.pi) {
      dLong = (2 * math.pi + dLong);
    }

    return degrees(math.atan2(
        math.sin(dLong) * math.cos(endLat),
        math.cos(startLat) * math.sin(endLat) -
            math.sin(startLat) * math.cos(endLat) * math.cos(dLong)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Localizador da Reportagem'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Distância: ${_distanceToReport.toStringAsFixed(2)} metros',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            if (_currentPosition != null)
              Transform.rotate(
                angle: radians(_bearingToReport),
                child: Icon(
                  Icons.arrow_upward,
                  size: 100,
                  color: Colors.red,
                ),
              )
            else
              CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              'Apontando para a direção da reportagem',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
