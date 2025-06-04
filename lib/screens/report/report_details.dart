import 'dart:typed_data';
import 'package:auth_bloc/screens/main_screen.dart';
import 'package:auth_bloc/screens/report/locator_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:universal_html/html.dart' as html;
import 'package:flutter/services.dart'; // Make sure this is imported
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart'; // Import for launching URLs
import 'package:image/image.dart' as img; // For loading fonts

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
  final TextEditingController _resolutionController = TextEditingController();

  pw.Font? _unicodeFont; // To store the Unicode-supporting font

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _loadUnicodeFont();
  }

  Future<void> _loadUnicodeFont() async {
    try {
      final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
      final buffer = fontData.buffer;
      final uint8List =
          buffer.asUint8List(fontData.offsetInBytes, fontData.lengthInBytes);
      final byteData = ByteData.view(
          uint8List.buffer); // Create ByteData from Uint8List's buffer
      _unicodeFont = pw.Font.ttf(byteData);
    } catch (e) {
      print("Error loading Unicode font: $e");
      // Fallback to default font
    }
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
        });
      } else {
        setState(() {
          _userName = 'Usuário Desconhecido';
        });
      }
      _isLoadingUser = false;
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

// Function to handle the confirmation logic (keeping it for completeness)
  Future<void> _confirmReport() async {
    // ... (Your existing location confirmation logic)
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

  Future<void> _showResolutionDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Descreva como foi resolvido'),
          content: SingleChildScrollView(
            child: TextField(
              controller: _resolutionController,
              maxLines: 5, // Adjust as needed for a bigger input area
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Detalhe os passos para resolver este problema...',
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Concluído'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _markAsResolvedAndCreateReport(
                    _resolutionController.text);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _markAsResolvedAndCreateReport(String userSolution) async {
    try {
      // Update the document in Firestore
      await FirebaseFirestore.instance
          .collection('reports')
          .doc(widget.report['id'])
          .update({'status': 'fixed', 'solutionUser': userSolution});

      // Create PDF report
      await _createAndDownloadPdf(userSolution);

      // Show a success message
      _showSuccessDialog(
          "Status da reportagem atualizado e relatório criado com sucesso!");
    } catch (e) {
      // Handle any errors
      print("Error updating report status or creating PDF: $e");
      _showErrorDialog("Erro",
          "Falha ao atualizar o status da reportagem ou criar o relatório.");
    }
  }

  Future<void> _createAndDownloadPdf(String userSolution) async {
    final pdf = pw.Document();

    final imageUrl = widget.report['imageUrl'];
    pw.Image? imageWidget;
    try {
      final html.HttpRequest request = await html.HttpRequest.request(imageUrl);
      final Uint8List imageBytes = request.response as Uint8List;

      // Decode the image using the image package
      final decodedImage = img.decodeImage(imageBytes);

      if (decodedImage != null) {
        // Encode the image to PNG format (you can choose other formats if needed)
        final pngBytes = img.encodePng(decodedImage) as Uint8List;

        // Create the PDF image widget from the PNG bytes
        imageWidget = pw.Image(pw.MemoryImage(pngBytes));
      } else {
        print("Error decoding image.");
      }
    } catch (e) {
      print("Error loading or processing image: $e");
    }

    pdf.addPage(pw.MultiPage(
      theme: pw.ThemeData.withFont(
        base: _unicodeFont, // Use the loaded Unicode font
      ),
      build: (pw.Context context) => <pw.Widget>[
        if (imageWidget != null) imageWidget,
        pw.SizedBox(height: 10),
        pw.Text(widget.report['title'],
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Text('Descrição:',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.Text(widget.report['description'] ?? 'Nenhuma descrição fornecida.'),
        pw.SizedBox(height: 10), // Added space
        pw.Text('Solução sugerida pela IA:',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.Text(widget.report['solutionAi'] ??
            'Nenhuma solução fornecida.'), // Added space
        pw.SizedBox(height: 10),
        pw.Text('Solução do usuário:',
            style: pw.TextStyle(
                fontSize: 16, fontWeight: pw.FontWeight.bold)), // Added space
        pw.Text(userSolution),
      ],
    ));

    try {
      final bytes = await pdf.save();
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'report_${widget.report['id']}.pdf')
        ..click();
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      print("Error saving PDF: $e");
      _showErrorDialog("Erro ao salvar PDF",
          "Ocorreu um erro ao salvar o relatório em PDF: $e");
    }
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
                  Text(widget.report['title'],
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                      // Assuming your report map contains 'latitude' and 'longitude'
                      final latitude = widget.report['latitude'];
                      final longitude = widget.report['longitude'];

                      if (latitude != null && longitude != null) {
                        final Uri googleMapsUrl = Uri.parse(
                            'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
                        canLaunchUrl(googleMapsUrl).then((canLaunch) {
                          if (canLaunch) {
                            launchUrl(googleMapsUrl);
                          } else {
                            _showErrorDialog(
                                'Erro', 'Não foi possível abrir o mapa.');
                          }
                        });
                      } else {
                        _showErrorDialog('Erro',
                            'Localização não disponível para esta denúncia.');
                      }
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
                      Text('${widget.report['NoConfirmation'] ?? 0}',
                          style: TextStyle(fontWeight: FontWeight.bold)),
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
                      Text('${widget.report['NoResolved'] ?? 0}',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('Número de confirmações de resolvidos',
                          style: TextStyle(color: Colors.green)),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text('Descrição:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8), // Added space
                  Text(widget.report['description'] ??
                      'Nenhuma descrição fornecida.'),
                  SizedBox(height: 16), // Added space
                  Text('Solução criada por IA:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8), // Added space
                  Text(widget.report['solutionAi'] ??
                      'Nenhuma solução fornecida.'),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        _showResolutionDialog();
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
