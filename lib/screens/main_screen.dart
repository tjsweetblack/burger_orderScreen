import 'package:auth_bloc/logic/cubit/auth_cubit.dart';
import 'package:auth_bloc/routing/routes.dart';
import 'package:auth_bloc/screens/menu.dart';
import 'package:auth_bloc/screens/report/create_report.dart';
import 'package:auth_bloc/screens/report/report_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:universal_html/html.dart' as html;
import 'package:cloud_firestore/cloud_firestore.dart';

class MapZzzPage extends StatefulWidget {
  @override
  _MapZzzPageState createState() => _MapZzzPageState();
}

class _MapZzzPageState extends State<MapZzzPage> {
  final LatLng belasLuanda = LatLng(-8.9036, 13.2489);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final MapController _mapController = MapController();
  Map<String, dynamic>? _selectedReport;
  String? _selectedReportId;

  void _recenterMapToUser() async {
    final Position position = await _getCurrentLocation();
    _mapController.move(LatLng(position.latitude, position.longitude), 15.0);
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
  
  void _zoomInMap() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom + 1);
  }

  void _zoomOutMap() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom - 1);
  }

  @override
  Widget build(BuildContext context) {
    final authCubit = context.watch<AuthCubit>();
    final userId = authCubit.currentUser?.uid;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.black),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Row(
          children: [
            Text(
              'MapaZZZ',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            Spacer(),
            Row(
              children: [
                Icon(Icons.badge, color: Colors.red, size: 18),
                SizedBox(width: 4),
                Text(
                  'ADMIN',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8),
              ],
            ),
          ],
        ),
        elevation: 0,
      ),
      drawer: buildAppDrawer(context),
      body: Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.3,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                SizedBox(height: 16),
                Text(
                  'Reportagens',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                if (_selectedReport != null)
                  Expanded(
                    child: ReportDetailPage(report: _selectedReport!),
                  )
                else
                  Expanded(
                    child: ReportList(onReportSelected: (reportId, reportData) {
                      setState(() {
                        _selectedReport = reportData;
                        _selectedReportId = reportId;
                      });
                    }),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                MapWidget(
                  mapController: _mapController,
                  selectedReportId: _selectedReportId,
                  onReportSelected: (reportId, reportData, lat, lon) {
                    setState(() {
                      _selectedReport = reportData;
                      _selectedReportId = reportId;
                    });
                    if (lat != null && lon != null) {
                      _mapController.move(LatLng(lat, lon), 17.0);
                    }
                  },
                ),
                Positioned(
                  bottom: 16, // Adjust position as needed
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: _zoomInMap,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(Icons.add, color: Colors.red),
                        ),
                      ),
                      SizedBox(height: 8),
                      GestureDetector(
                        onTap: _zoomOutMap,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(Icons.remove, color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ReportList extends StatefulWidget {
  final Function(String, Map<String, dynamic>) onReportSelected;
  ReportList({Key? key, required this.onReportSelected}) : super(key: key);

  @override
  _ReportListState createState() => _ReportListState();
}

class _ReportListState extends State<ReportList> {
  List<Map<String, dynamic>> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  Future<void> _fetchReports() async {
    try {
      FirebaseFirestore.instance
          .collection('reports')
          .snapshots()
          .listen((snapshot) {
        List<Map<String, dynamic>> fetchedReports = [];
        for (final doc in snapshot.docs) {
          fetchedReports.add(doc.data() as Map<String, dynamic>);
        }
        setState(() {
          _reports = fetchedReports;
          _isLoading = false;
        });
      });
    } catch (e) {
      print("Error fetching reports: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildRiskLevelIcons(int riskLevel) {
    Icon levelIcon =
        Icon(Icons.signal_cellular_alt_1_bar_sharp, color: Colors.red);
    if (riskLevel == 1) {
      levelIcon =
          Icon(Icons.signal_cellular_alt_1_bar_sharp, color: Colors.red);
    } else if (riskLevel == 2) {
      levelIcon =
          Icon(Icons.signal_cellular_alt_2_bar_sharp, color: Colors.red);
    } else if (riskLevel == 3) {
      levelIcon = Icon(Icons.signal_cellular_alt_sharp, color: Colors.red);
    } else if (riskLevel == 4) {
      levelIcon = Icon(Icons.signal_cellular_alt, color: Colors.red);
    }

    return levelIcon;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_reports.isEmpty) {
      return Center(child: Text('Nenhuma reportagem encontrada.'));
    }

    return ListView.builder(
      itemCount: _reports.length,
      itemBuilder: (context, index) {
        final report = _reports[index];
        final reportId = report['id'];
        final isFixed = report['status'] == 'fixed';
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: InkWell(
            onTap: () {
              print(reportId);
              print(report);
              widget.onReportSelected(
                reportId,
                report,
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: isFixed
                    ? Colors.red.withOpacity(0.15)
                    : null, // Light red with 50% opacity (0.5)
                borderRadius:
                    BorderRadius.circular(4), // Optional: Add rounded corners
              ),
              padding: const EdgeInsets.all(
                  8.0), // Optional: Add some padding inside the colored container
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Image.network(
                      report['imageUrl'],
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return SizedBox(
                          width: 50,
                          height: 50,
                          child: Icon(Icons.error_outline),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report['title'],
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          report['location'],
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: _buildRiskLevelIcons(report['riskLevel'] as int),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class MapWidget extends StatefulWidget {
  final MapController mapController;
  final Function(String, Map<String, dynamic>, double?, double?)
      onReportSelected;
  final String? selectedReportId;

  const MapWidget(
      {Key? key,
      required this.mapController,
      required this.onReportSelected,
      this.selectedReportId})
      : super(key: key);

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  LatLng? _currentLocation;
  bool _locationFetched = false;
  final double heatmapRadiusKm = 0.3;
  String? _selectedMarkerId;

  @override
  void initState() {
    super.initState();
    _getCurrentUserLocation();
  }

  Future<void> _getCurrentUserLocation() async {
    try {
      final Position position = await _getCurrentLocation();
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _locationFetched = true;
      });
      widget.mapController.move(_currentLocation!, 15.0);
    } catch (e) {
      print("Error getting location: $e");
      setState(() {
        _currentLocation = LatLng(-8.913499751058776, 13.18721354420165);
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
  
  Widget _greyScaleTileBuilder(
    BuildContext context,
    Widget tileWidget,
    TileImage tile,
  ) {
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(<double>[
        0.15, 0.50, 0.05, 0, 0, //
        0.15, 0.50, 0.05, 0, 0, //
        0.15, 0.50, 0.05, 0, 0, //
        0, 0, 0, 1, 0, //
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
              initialCenter: _currentLocation!,
              initialZoom: 15.0,
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
                    point: _currentLocation!,
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
                    .where('status',
                        isEqualTo:
                            'active') // Only fetch reports with status 'active'
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final List<Map<String, dynamic>> reports =
                      snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return {'id': doc.id, ...data};
                  }).toList();

                  final List<Marker> reportMarkers = <Marker>[];
                  final heatmapCircles = <CircleMarker>[];
                  final processedReports = <Map<String, dynamic>>[];
                  final double heatmapRadiusMeters = heatmapRadiusKm * 1000;

                  for (final report in reports) {
                    final latitude = report['latitude'] as double?;
                    final longitude = report['longitude'] as double?;
                    final reportId = report['id'] as String;

                    double markerSize = 20;
                    Color markerColor = Colors.red.withOpacity(0.8);

                    if (widget.selectedReportId == reportId) {
                      markerSize = 50;
                      markerColor = Colors.red;
                    }

                    if (latitude != null && longitude != null) {
                      reportMarkers.add(
                        Marker(
                          point: LatLng(latitude, longitude),
                          width: markerSize,
                          height: markerSize,
                          child: GestureDetector(
                            onTap: () {
                              widget.onReportSelected(
                                  reportId, report, latitude, longitude);
                              setState(() {
                                _selectedMarkerId = reportId;
                              });
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
                                    color: markerColor,
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
                        double circleRadius = heatmapRadiusMeters;

                        if (reportsInRadius.length >= 3 &&
                            reportsInRadius.length < 6) {
                          opacity = 0.3;
                        } else if (reportsInRadius.length >= 6 &&
                            reportsInRadius.length < 9) {
                          opacity = 0.6;
                        } else if (reportsInRadius.length >= 9) {
                          opacity = 0.9;
                        }
                        if (widget.selectedReportId != null) {
                          final selectedReport = reportsInRadius.firstWhere(
                            (report) => report['id'] == widget.selectedReportId,
                            orElse: () => {},
                          );
                          if (selectedReport.isNotEmpty) {
                            circleRadius = heatmapRadiusMeters * 2;
                          }
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
                            radius: circleRadius,
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
        : const Center(child: CircularProgressIndicator());
  }
}
