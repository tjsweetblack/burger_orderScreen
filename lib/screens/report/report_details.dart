import 'package:auth_bloc/screens/main_screen.dart';
import 'package:auth_bloc/screens/report/locator_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // Import the geolocator package

class ReportDetailPage extends StatefulWidget {
  final Map<String, dynamic> report;

  ReportDetailPage({required this.report});

  @override
  _ReportDetailPageState createState() => _ReportDetailPageState();
}

class _ReportDetailPageState extends State<ReportDetailPage> {
  String? _userName;
  bool _isLoadingUser = true;
  int? _userVote; // Track user's vote
  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    setState(() {
      _isLoadingUser = true;
      _userName = null;
    });
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.report['userId'])
          .get();
      if (userDoc.exists) {
        setState(() {
          _userName = userDoc.data()?['name'];
          _isLoadingUser = false;
        });
      } else {
        setState(() {
          _userName = 'Unknown User';
          _isLoadingUser = false;
        });
      }
    } catch (e) {
      print("Error fetching user name: $e");
      setState(() {
        _userName = 'Error Loading User';
        _isLoadingUser = false;
      });
    }
  }

  String _getRiskLevelText(int riskLevel) {
    switch (riskLevel) {
      case 1:
        return 'Baixo';
      case 2:
        return 'Médio';
      case 3:
        return 'Alto';
      case 4:
        return 'Muito Alto';
      default:
        return 'Desconhecido';
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

  Widget _buildVoteButton(int voteValue, String label) {
    return Expanded(
// Use Expanded to give them equal width
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 4.0), // Add padding for space
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _userVote = voteValue;
                });
// Implement logic to store the vote in Firebase
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _userVote == voteValue
                    ? Colors.red[100]
                    : Colors.white, // Light red when selected
                foregroundColor: Colors.black,
                side: BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Icon(Icons.signal_cellular_alt_sharp),
            ),
            SizedBox(height: 4),
            Text(label,
                style: TextStyle(fontSize: 12)), // Add label below button
          ],
        ),
      ),
    );
  }

// Function to calculate distance between two coordinates
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

// Function to handle the confirmation logic
  Future<void> _confirmReport() async {
    double reportLatitudes = widget.report['latitude'];
    double reportLongitudes = widget.report['longitude'];
    print('Report Longitude: $reportLongitudes');
    print('Report Latitude: $reportLatitudes');
    print(
        'Report ID being used: ${widget.report['id']}'); // Print the report ID
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          await _showErrorDialog('Permissão de localização negada',
              'Por favor, habilite a permissão de localização para confirmar a reportagem.');
          return;
        }
      }
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      double userLatitude = position.latitude;
      double userLongitude = position.longitude;
      print('User Longitude: $userLongitude');
      print('User Latitude: $userLatitude');
// Assuming 'latitude' and 'longitude' fields exist in the report document
      double reportLatitude = widget.report['latitude'];
      double reportLongitude = widget.report['longitude'];
      double distanceInMeters = _calculateDistance(
          userLatitude, userLongitude, reportLatitude, reportLongitude);
      print('Distance to report: $distanceInMeters meters');
      if (distanceInMeters <= 5) {
// User is within 5 meters, update NoConfirmation
        try {
          await FirebaseFirestore.instance
              .collection('reports')
              .doc(widget.report['id']) // Assuming 'id' is the document ID
              .update({'NoConfirmation': FieldValue.increment(1)});
          await _showSuccessDialog('Reportagem confirmada com sucesso!');
        } on FirebaseException catch (e) {
          await _showErrorDialog('Erro ao confirmar no Firestore',
              'Ocorreu um erro ao atualizar o número de confirmações: ${e.message ?? e.code}');
        } catch (e) {
          await _showErrorDialog('Erro inesperado ao confirmar', e.toString());
        }
      } else {
// User is too far, show error dialog
        await _showErrorDialog('Localização distante',
            'Nao se encontras no local da reportagem. Chegue mais proximo, 5 metros pelo menos de distancia.');
      }
    } catch (locationError) {
      print("Error getting location: $locationError");
      await _showErrorDialog(
          'Erro ao obter localização', locationError.toString());
    } catch (e) {
      print("General error during confirmation: $e");
      await _showErrorDialog('Erro geral ao confirmar', e.toString());
    }
  }

  Future<void> _showErrorDialog(String title, String message) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSuccessDialog(String message) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sucesso'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 43),
            Stack(
              children: [
                Hero(
                  tag: 'reportImage-${widget.report['imageUrl']}',
                  child: Image.network(
                    widget.report['imageUrl'],
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 250,
                        color: Colors.grey[300],
                        child: Center(child: Icon(Icons.image_not_supported)),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 18,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MapZzzPage()));
                      },
                      iconSize: 20,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.report['title'],
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.red),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.report['location'],
                          softWrap: true,
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                  SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
// Implement "Ver no mapa" functionality
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: Text('Ver no mapa'),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Text('Criado por: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      _isLoadingUser
                          ? CircularProgressIndicator()
                          : Text(_userName ?? 'Loading...'),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text('Nível de risco: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      _buildRiskLevelIcons(widget.report['riskLevel'] as int),
                      SizedBox(width: 8),
                      Text(
                          _getRiskLevelText(widget.report['riskLevel'] as int)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.people, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        '${widget.report['NoConfirmation'] ?? 0}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text('Número de confirmações',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.people, color: Colors.green),
                      SizedBox(width: 4),
                      Text(
                        '${widget.report['NoResolved'] ?? 0}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text('Número de confirmações de resolvidos',
                          style: TextStyle(color: Colors.green)),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text('Descrição:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(widget.report['description'] ??
                      'No description provided.'),
                  SizedBox(height: 16),
                  Text('Solução criada por IA:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(widget.report['solutionAi'] ?? 'No solution provided.'),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Get the report ID
                        String reportId = widget.report['id'];
                        try {
                          // Update the document in Firestore
                          await FirebaseFirestore.instance
                              .collection('reports')
                              .doc(reportId)
                              .update({'status': 'fixed'});
                          // Show a success message
                          _showSuccessDialog(
                              "Report status updated successfully.");
                        } catch (e) {
                          // Handle any errors
                          print("Error updating report status: $e");
                          _showErrorDialog(
                              "Error", "Failed to update report status.");
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Definir como resolvido',
                          style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
