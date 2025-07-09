import 'dart:typed_data';
import 'package:auth_bloc/screens/main_screen.dart';
import 'package:auth_bloc/screens/report/locator_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/services.dart'; // Make sure this is imported
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart'; // Import for launching URLs
import 'package:image/image.dart' as img; // For loading fonts
import 'package:google_generative_ai/google_generative_ai.dart';

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
  bool _isProcessingResolution = false; // To show loading indicator
  final TextEditingController _resolutionController = TextEditingController();

  // PDF Font state
  pw.Font? _regularFont;
  pw.Font? _boldFont;
  bool _areFontsLoaded = false;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _loadPdfFonts();
  }

  /// Loads the regular and bold fonts required for generating the PDF.
  /// This prevents Unicode character issues.
  Future<void> _loadPdfFonts() async {
    try {
      // It's good practice to have both regular and bold for PDF reports.
      final regularFontData = await rootBundle.load('assets/fonts/ARIAL.TTF');
      _regularFont = pw.Font.ttf(regularFontData);

      // You must add a bold version of the font to your assets.
      // ARIALBD.TTF is a common filename for Arial Bold.
      final boldFontData = await rootBundle.load('assets/fonts/ARIALBD.TTF');
      _boldFont = pw.Font.ttf(boldFontData);

      setState(() {
        _areFontsLoaded = true;
      });
    } catch (e) {
      print("Error loading PDF fonts: $e");
      _showErrorDialog("Erro de Fonte", "Não foi possível carregar as fontes para o PDF. Verifique se 'ARIAL.TTF' e 'ARIALBD.TTF' (ou a fonte em negrito correspondente) estão na pasta 'assets/fonts/'.");
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
    setState(() {
      _isProcessingResolution = true;
    });
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
    } finally {
      // Ensure the loading indicator is turned off
      setState(() {
        _isProcessingResolution = false;
      });
    }
  }

   Future<void> _createAndDownloadPdf(String userSolution) async {
    if (!_areFontsLoaded || _regularFont == null || _boldFont == null) {
      _showErrorDialog("Erro", "As fontes para o PDF ainda não foram carregadas. Por favor, tente novamente.");
      return;
    }

    String? geminiAnalysisText;
    try {
      // IMPORTANT: Use environment variables for API keys, do not hardcode them.
      // Run your app with: flutter run --dart-define=GEMINI_API_KEY=YOUR_API_KEY
      const apiKey = 'AIzaSyBAO_rST4zn3HeQNFHDCXaczAwLMQ0VROg';
      if (apiKey.isEmpty) {
        throw Exception('A chave da API do Gemini não foi configurada.');
      }
      // Corrected model name to a valid one.
      final model = GenerativeModel(model: 'gemma-3n-e4b-it', apiKey: apiKey);
      final prompt = '''
        Baseado no seguinte relatório de um problema urbano, gere uma análise detalhada em Português.
        O relatório foi marcado como resolvido.

        Título: ${widget.report['title']}
        Descrição: ${widget.report['description']}
        Localização: ${widget.report['location']}
        Solução aplicada pelo usuário: $userSolution

        Sua análise deve incluir os seguintes pontos, formatados para um relatório em PDF:
        1.  **Resumo do Problema:** Um breve resumo do risco que foi reportado.
        2.  **Impacto Potencial:** Descreva os riscos e impactos potenciais que o problema representava para a comunidade (segurança, saúde pública, meio ambiente, etc.) se não fosse resolvido.
        3.  **Avaliação da Solução:** Comente sobre a eficácia da solução aplicada pelo usuário.
        4.  **Recomendações Futuras:** Sugira medidas preventivas para evitar que problemas semelhantes ocorram no futuro.

        Use títulos em negrito para cada seção (ex: **Resumo do Problema:**).
      ''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      geminiAnalysisText = response.text;
    } catch (e) {
      print("Error generating content with Gemini: $e");
      geminiAnalysisText = "Falha ao gerar a análise detalhada: $e";
      _showErrorDialog("Erro na IA", "Não foi possível gerar a análise detalhada com a IA. O PDF será gerado sem ela. Erro: $e");
    }

    final pdf = pw.Document();

    // --- Load Logo Image ---
    pw.Image? logoImageWidget;
    try {
      final ByteData logoByteData = await rootBundle.load('assets/images/logo/logo.png');
      final Uint8List logoBytes = logoByteData.buffer.asUint8List();
      final decodedLogo = img.decodeImage(logoBytes);
      if (decodedLogo != null) {
        final pngLogoBytes = img.encodePng(decodedLogo);
        logoImageWidget = pw.Image(pw.MemoryImage(pngLogoBytes), width: 80);
      } else {
        print("Error decoding logo image.");
      }
    } catch (e) {
      print("Error loading or processing logo image: $e");
    }
    //--- Load Report Image ---
    final imageUrl = widget.report['imageUrl'];
    pw.Widget? reportImageWidget;

    print("Attempting to load image from URL: $imageUrl");

    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        print("Fetching image data using http package...");
        final response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          final Uint8List imageBytes = response.bodyBytes;
          print("Image data fetched. Byte length: ${imageBytes.length}");

          if (imageBytes.isEmpty) {
            print("Warning: Fetched image data is empty.");
          }

          final decodedImage = img.decodeImage(imageBytes);

          if (decodedImage != null) {
            print("Image decoded successfully. Width: ${decodedImage.width}, Height: ${decodedImage.height}");
            final pngBytes = img.encodePng(decodedImage);

            // --- FIX: Adjust image size to fit page ---
            // Calculate available height based on a standard A4 page (or your desired format)
            // and estimate space taken by other elements (logo, text).
            // This is an estimation, you might need to fine-tune the 0.6 factor.
            // A typical A4 page is ~842 points tall.
            // Available height after typical margins might be ~728 points (as per your error).
            // Let's reserve about 60-70% of the available height for the main image.
            const double contentPadding = 30; // Estimate space taken by logo, title, descriptions, etc.
            final double availablePageHeightForContent = PdfPageFormat.a4.availableHeight - contentPadding;
            final double maxImageHeight = availablePageHeightForContent * 0.5; // e.g., 60% of available content height

            // Wrap the Image in a Container with a specific height to guarantee
            // the constraint and prevent it from overflowing the page.
            reportImageWidget = pw.Container(
              height: maxImageHeight,
              child: pw.Image(
                pw.MemoryImage(pngBytes),
                fit: pw.BoxFit.contain, // This will scale the image to fit within the container
              ),
            );
            print("PDF Image widget created with fitting adjustments (max height: $maxImageHeight).");
          } else {
            print("Error: Failed to decode image. The image format might be unsupported or the data is corrupt.");
          }
        } else {
          print("----------- HTTP ERROR -----------");
          print("Failed to fetch image. Status code: ${response.statusCode}");
          print("Response body: ${response.body}");
          print("----------------------------------");
        }
      } catch (e) {
        print("----------- CATCH ERROR -----------");
        print("Error loading or processing report image: $e");
        print("This can be a CORS (Cross-Origin Resource Sharing) issue when running on the web.");
        print("Ensure the server hosting the image (e.g., Firebase Storage) allows requests from this web app's domain.");
        print("-----------------------------------");
      }
    } else {
      print("Image URL is null or empty. Skipping image loading.");
    }

    pdf.addPage(pw.MultiPage(
      theme: pw.ThemeData.withFont(
        base: _regularFont!,
        bold: _boldFont!,
      ),
      build: (pw.Context context) => <pw.Widget>[
        if (logoImageWidget != null) ...[
          pw.Center(child: logoImageWidget),
          pw.SizedBox(height: 20),
        ],
        // The report image is the most likely culprit for overflow.
        // Ensure it's sized appropriately as done above.
        pw.Text(widget.report['title'],
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        if (reportImageWidget != null) ...[
          pw.Center(child: reportImageWidget),
          pw.SizedBox(height: 10),
        ],
        pw.SizedBox(height: 10),
        pw.Text('Descrição:',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.Paragraph(text: widget.report['description'] ?? 'Nenhuma descrição fornecida.'),
        pw.SizedBox(height: 10),
        pw.Text('Solução sugerida pela IA:',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.Paragraph(text: widget.report['solutionAi'] ?? 'Nenhuma solução fornecida.'),
        pw.SizedBox(height: 10),
        pw.Text('Solução do usuário:',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.Paragraph(text: userSolution),
        // Force a new page for the detailed analysis to prevent overflow errors.
        //pw.NewPage(),
        if (geminiAnalysisText != null && geminiAnalysisText.isNotEmpty) ...[
          pw.SizedBox(height: 20),
          pw.Divider(),
          pw.SizedBox(height: 10),
          pw.Text('Análise Detalhada do Relatório (Gerada por IA)',
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          // The Gemini API can return markdown. For simplicity, we'll display it as text.
          // The prompt asks for bolded headers, which the model will generate in the text.
          pw.Paragraph(text: geminiAnalysisText),
        ],
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
      _showErrorDialog("Erro ao salvar PDF", "Ocorreu um erro ao salvar o relatório em PDF: $e");
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
                      onPressed: _isProcessingResolution
                          ? null
                          : () async {
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
                      child: _isProcessingResolution
                          ? CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : Text('Definir como resolvido',
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
