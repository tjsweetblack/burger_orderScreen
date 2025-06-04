import 'package:auth_bloc/screens/report/report_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class MapWidget extends StatefulWidget {
  final MapController mapController;

  const MapWidget({Key? key, required this.mapController}) : super(key: key);

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  LatLng? _currentLocation;
  bool _locationFetched = false;

  @override
  void initState() {
    super.initState();
    _getCurrentUserLocation();
  }

  Future<void> _getCurrentUserLocation() async {
    try {
      final Position position = await _getCurrentLocation();
      print(
          "Fetched Location: Latitude: ${position.latitude}, Longitude: ${position.longitude}"); // Log the fetched location
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _locationFetched = true;
      });
      widget.mapController.move(_currentLocation!, 15.0); // Initial zoom
    } catch (e) {
      print("Error getting location: $e");
      // Handle error appropriately, maybe show a default location
      setState(() {
        _currentLocation =
            LatLng(-8.9036, 13.2489); // Default to Belas if location fails
        _locationFetched = true;
      });
      widget.mapController.move(_currentLocation!, 13.0);
    }
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Serviços de localização desativados.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Permissões de localização negadas');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }
  
  final double heatmapRadiusKm = 0.3;

  Widget _greyScaleTileBuilder(
    BuildContext context,
    Widget tileWidget,
    TileImage tile,
  ) {
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(<double>[
        0.15,
        0.50,
        0.05,
        0,
        0,
        0.15,
        0.50,
        0.05,
        0,
        0,
        0.15,
        0.50,
        0.05,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
      ]),
      child: tileWidget,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _locationFetched && _currentLocation != null
        ? FlutterMap(
            key: UniqueKey(),
            mapController: widget.mapController,
            options: MapOptions(
              initialCenter: _currentLocation!, // Use the fetched location
              initialZoom: 15.0, // Increased initial zoom
              interactionOptions: InteractionOptions(
                flags: InteractiveFlag.all,
                cursorKeyboardRotationOptions:
                    const CursorKeyboardRotationOptions(),
                keyboardOptions: const KeyboardOptions(),
              ),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
                tileBuilder: _greyScaleTileBuilder,
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point:
                        _currentLocation!, // Use the fetched location for the marker
                    width: 30,
                    height: 30,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('reports')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final reports = snapshot.data!.docs
                      .map((doc) => doc.data() as Map<String, dynamic>)
                      .toList();
                  final reportMarkers = <Marker>[];
                  final heatmapCircles = <CircleMarker>[];
                  final processedReports = <Map<String, dynamic>>[];
                  final double heatmapRadiusMeters = heatmapRadiusKm * 1000;

                  for (final report in reports) {
                    final latitude = report['latitude'] as double?;
                    final longitude = report['longitude'] as double?;

                    if (latitude != null && longitude != null) {
                      reportMarkers.add(
                        Marker(
                          point: LatLng(latitude, longitude),
                          width: 20,
                          height: 20,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ReportDetailPage(report: report),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: Center(
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.red.withOpacity(0.8),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                  }

                  for (final report1 in reports) {
                    if (processedReports.contains(report1)) {
                      continue;
                    }

                    final lat1 = report1['latitude'] as double?;
                    final lon1 = report1['longitude'] as double?;

                    if (lat1 != null && lon1 != null) {
                      List<Map<String, dynamic>> reportsInRadius = [];
                      for (final report2 in reports) {
                        final lat2 = report2['latitude'] as double?;
                        final lon2 = report2['longitude'] as double?;

                        if (lat2 != null && lon2 != null) {
                          final distance = const Distance()
                              .distance(LatLng(lat1, lon1), LatLng(lat2, lon2));
                          if (distance <= heatmapRadiusMeters) {
                            reportsInRadius.add(report2);
                          }
                        }
                      }

                      if (reportsInRadius.length >= 3) {
                        double opacity = 0.0;
                        if (reportsInRadius.length >= 3 &&
                            reportsInRadius.length < 6) {
                          opacity = 0.3;
                        } else if (reportsInRadius.length >= 6 &&
                            reportsInRadius.length < 9) {
                          opacity = 0.6;
                        } else if (reportsInRadius.length >= 9) {
                          opacity = 0.9;
                        }

                        double sumLat = 0;
                        double sumLon = 0;
                        int count = 0;
                        for (final r in reportsInRadius) {
                          final rLat = r['latitude'] as double?;
                          final rLon = r['longitude'] as double?;

                          if (rLat != null && rLon != null) {
                            sumLat += rLat;
                            sumLon += rLon;
                            count++;
                          }
                        }
                        final centerLat = count > 0 ? sumLat / count : 0.0;
                        final centerLon = count > 0 ? sumLon / count : 0.0;

                        heatmapCircles.add(
                          CircleMarker(
                            point: LatLng(centerLat, centerLon),
                            radius: heatmapRadiusMeters,
                            useRadiusInMeter: true,
                            color: Colors.red.withOpacity(opacity),
                          ),
                        );

                        processedReports.addAll(reportsInRadius);
                      }
                    }
                  }

                  return Stack(
                    children: [
                      CircleLayer(circles: heatmapCircles),
                      MarkerLayer(markers: reportMarkers),
                    ],
                  );
                },
              ),
            ],
          )
        : Center(
            child:
                CircularProgressIndicator()); // Show loading while fetching location
  }
}