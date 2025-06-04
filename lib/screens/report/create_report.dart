import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:auth_bloc/screens/main_screen.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'report_details.dart';

class CreateReportCameraScreen extends StatefulWidget {
  @override
  _CreateReportCameraScreenState createState() =>
      _CreateReportCameraScreenState();
}

class _CreateReportCameraScreenState extends State<CreateReportCameraScreen> {
  late CameraController _cameraController;
  late Future<void> _initializeCameraControllerFuture;
  List<CameraDescription> _cameras = [];

  @override
  void initState() {
    super.initState();
    _setupCamera();
  }

  Future<void> _setupCamera() async {
    try {
      _cameras = await availableCameras();
      _cameraController = CameraController(
        _cameras.first, // Get a specific camera from the list
        ResolutionPreset.high, // Set the resolution
      );
      _initializeCameraControllerFuture = _cameraController.initialize();
      if (!mounted) {
        return;
      }
      setState(() {});
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar reportagem'),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle:
            const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MapZzzPage(),
              ),
            ); // Navigate back to the previous screen (main screen)
          },
        ),
      ),
      body: FutureBuilder<void>(
        future: _initializeCameraControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
// Camera initialized, display the preview
            return Stack(
              children: [
                CameraPreview(_cameraController),
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Tire uma foto do risco.',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 30.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          await _initializeCameraControllerFuture;
                          final image = await _cameraController.takePicture();
// Navigate to the next screen (Title and Description)
// You will need to create this screen next
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateReportDetailsScreen(
                                  imagePath: image.path),
                            ),
                          );
                        } catch (e) {
                          print('Error taking picture: $e');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(30),
                        backgroundColor: Colors.white, // White button
                      ),
                      child: Icon(Icons.camera_alt,
                          size: 40, color: Colors.red), // Red camera icon
                    ),
                  ),
                ),
              ],
            );
          } else {
// Otherwise, display a loading indicator
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class CreateReportDetailsScreen extends StatefulWidget {
  final String imagePath;

  CreateReportDetailsScreen({required this.imagePath});

  @override
  _CreateReportDetailsScreenState createState() =>
      _CreateReportDetailsScreenState();
}

class _CreateReportDetailsScreenState extends State<CreateReportDetailsScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _imageUrl;
  bool _isUploading = false;
  String _shippingAddress = ''; // To store the fetched address
  bool _isCreatingReport = false; // To track report creation process

  Future<String?> _uploadImageToCloudinary(String imagePath) async {
    setState(() {
      _isUploading = true;
    });
    try {
      List<int> imageBytes = await File(imagePath).readAsBytes();
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://burger-image-api.vercel.app/upload'),
      );
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: imagePath.split('/').last,
        ),
      );
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        var decodedResponse = jsonDecode(responseBody);
        setState(() {
          _isUploading = false;
        });
        return decodedResponse['imageUrl'];
      } else {
        print('Backend upload error: ${response.statusCode} - ${responseBody}');
        setState(() {
          _isUploading = false;
        });
        throw Exception('Backend upload failed');
      }
    } catch (e) {
      print('Upload exception: $e');
      setState(() {
        _isUploading = false;
      });
      rethrow;
    }
  }

  Future<String?> _getCurrentLocationName(
      double latitude, double longitude) async {
    try {
      final response = await http.get(Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$latitude&lon=$longitude&addressdetails=1'));
      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        print("Nominatim API decodedResponse: $decodedResponse");
        if (decodedResponse != null &&
            decodedResponse['display_name'] != null) {
// <-- Check for display_name
            if (mounted) {
              setState(() {
                _shippingAddress = decodedResponse['display_name']; // <-- Use display_name directly
              });
            }
          return _shippingAddress;
        } else {
          print(
              "Nominatim API: No address details found in response (inside IF condition)");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('No address found for selected location.')),
          ); // Log shipping address
            if (mounted) {
              setState(() {
                _shippingAddress = '';
              });
            }
          return null;
        }
      } else {
// Handle API error (e.g., show an error message)
        print(
            "Nominatim API request failed with status: ${response.statusCode}");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Falha ao obter endereço.')),
          );
          setState(() {
            _shippingAddress = '';
          });
        }
        return null;
      }
    } catch (e) {
// Handle any exceptions (e.g., network issues)
      print("Error fetching address: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Falha ao obter endereço.')),
        );
        setState(() {
          _shippingAddress = '';
        });
      }
      return null;
    }
  }

  Future<Position> _getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;
// Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<void> _createReport() async {
    if (_isCreatingReport || _isUploading) {
      return; // Prevent multiple submissions during upload/creation
    }
    String title = _titleController.text.trim();
    String description = _descriptionController.text.trim();
    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, preencha o título e a descrição.')),
      );
      return;
    }
    setState(() {
      _isCreatingReport = true;
    });
    try {
      String? imageUrl = await _uploadImageToCloudinary(widget.imagePath);
      if (imageUrl != null) {
        Position position = await _getCurrentPosition();
        String? locationName = await _getCurrentLocationName(
            position.latitude, position.longitude);
        String? userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId != null) {
          DocumentReference reportRef =
              await FirebaseFirestore.instance.collection('reports').add({
            'NoConfirmation': 0,
            'description': description,
            'imageUrl': imageUrl,
            'latitude': position.latitude,
            'longitude': position.longitude,
            'location': locationName ?? 'Localização desconhecida',
            'riskLevel': 1,
            'solutionAi': 'none',
            'status': 'active',
            'title': title,
            'userId': userId,
          });

// Update user points
          DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();
          if (userSnapshot.exists && userSnapshot.data() != null) {
            int currentPoints =
                (userSnapshot.data() as Map<String, dynamic>)['points'] ?? 0;
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .update({'points': currentPoints + 30});
          }
          setState(() {
            _isCreatingReport = false;
          });

// Fetch the newly created report data
          DocumentSnapshot<Map<String, dynamic>> newReportSnapshot =
              await reportRef.get() as DocumentSnapshot<Map<String, dynamic>>;

          // Add the document ID to the report data
          Map<String, dynamic>? reportDataWithId = newReportSnapshot.data();
          if (reportDataWithId != null) {
            reportDataWithId['id'] = newReportSnapshot.id;
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CreateReportSuccessScreen(
                  report: reportDataWithId), // Pass report data with ID
            ),
          );
        } else {
          setState(() {
            _isCreatingReport = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao obter o ID do usuário.')),
          );
        }
      } else {
        setState(() {
          _isCreatingReport = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao fazer o upload da imagem.')),
        );
      }
    } catch (e) {
      setState(() {
        _isCreatingReport = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ocorreu um erro ao criar a reportagem: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MapZzz'),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle:
            const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => CreateReportCameraScreen(),
              ),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detalhe o risco e as potenciais\ncausas do risco',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Título',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Detalhes',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Descreva detalhadamente o risco observado, possíveis causas, e qualquer informação relevante...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
            Spacer(), // Push the button to the bottom
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _isCreatingReport || _isUploading ? null : _createReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  textStyle: TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
                child: (_isCreatingReport || _isUploading)
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : Text('Completar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CreateReportSuccessScreen extends StatelessWidget {
  final Map<String, dynamic>? report; // Receive the report data

  CreateReportSuccessScreen({this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MapZzz'),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle:
            TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Colors.red,
              size: 120,
            ),
            SizedBox(height: 20),
            const Text(
              'Concluído.',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 8),
            const Text(
              'Reportagem criada com sucesso.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Ganhaste',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.star_border, color: Colors.red, size: 20),
                const SizedBox(width: 4),
                const Text(
                  '30 pontos',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 40),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  if (report != null && report!.containsKey('id')) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReportDetailPage(report: report!),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Erro ao carregar detalhes da reportagem.')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  textStyle: TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
                child: const Text('Ver reportagem'),
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
// Navigate back to the main map screen
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[700],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  textStyle: TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
                child: const Text('Voltar ao início'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
