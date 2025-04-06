import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:url_launcher/url_launcher.dart';

class MalariaResultScreen extends StatefulWidget {
  final String symptomsDescription;

  const MalariaResultScreen({super.key, required this.symptomsDescription});

  @override
  State<MalariaResultScreen> createState() => _MalariaResultScreenState();
}

class _MalariaResultScreenState extends State<MalariaResultScreen> {
  String probabilityResult = 'Analisando...';
  bool isLoading = true;
  String errorMessage = '';
  String explanation = '';

  @override
  void initState() {
    super.initState();
    _getMalariaProbability();
  }

  Future<void> _getMalariaProbability() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
      probabilityResult = 'Analisando...';
      explanation = '';
    });

    final apiKey = 'AIzaSyBAO_rST4zn3HeQNFHDCXaczAwLMQ0VROg';
    if (apiKey.isEmpty) {
      setState(() {
        errorMessage =
            'Chave da API Gemini não encontrada. Por favor, insira sua chave da API.';
        isLoading = false;
      });
      return;
    }

    final model = GenerativeModel(
      model: 'gemini-2.5-pro-exp-03-25',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 1,
        topK: 64,
        topP: 0.95,
        maxOutputTokens: 65536,
      ),
    );

    final chat = model.startChat(history: [
      Content.multi([
        TextPart(
            'Based on the following symptoms: "${widget.symptomsDescription}", what is the probability (as a percentage) that the person has malaria? Please give a rough estimate and output the percentage number followed by a very breve explicação em português de por que você deu essa porcentagem (uma ou duas frases curtas) nao fale de nenhuma doenca alem de malaria.'),
      ]),
    ]);

    final content = Content.text('');

    try {
      final response = await chat.sendMessage(content);
      print(response);
      if (response.text != null) {
        final output = response.text!;
        print(output);

        List<String> parts = output.split('%');
        if (parts.length >= 2) {
          final percentagePart = parts[0].trim();
          final explanationPart = parts.sublist(1).join('%').trim();

          final percentageMatch =
              RegExp(r'(\d+(\.\d+)?)').firstMatch(percentagePart);
          if (percentageMatch != null) {
            setState(() {
              probabilityResult = '${percentageMatch.group(1)}%';
              explanation = explanationPart.isNotEmpty
                  ? explanationPart
                  : 'A explicação para esta probabilidade não foi fornecida.';
              isLoading = false;
            });
          } else {
            setState(() {
              probabilityResult = 'Não foi possível estimar a probabilidade.';
              explanation =
                  'Não foi possível analisar a resposta para obter a probabilidade.';
              isLoading = false;
            });
          }
        } else {
          setState(() {
            probabilityResult = 'Resposta em formato inesperado.';
            explanation =
                'A resposta da IA não continha a probabilidade e a explicação no formato esperado.';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          probabilityResult = 'Nenhuma resposta recebida.';
          explanation = 'Nenhuma resposta foi recebida da IA.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erro ao obter a probabilidade: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('EPaludismo ?', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: CircularProgressIndicator(
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.red),
                        backgroundColor: Colors.grey[300],
                        strokeWidth: 10,
                        value: isLoading
                            ? null
                            : double.tryParse(
                                        probabilityResult.replaceAll('%', ''))
                                    ?.clamp(0, 100) ??
                                0 / 100,
                      ),
                    ),
                    Text(
                      isLoading ? 'Analisando...' : probabilityResult,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  isLoading
                      ? 'Aguarde enquanto analisamos os sintomas...'
                      : errorMessage.isNotEmpty
                          ? errorMessage
                          : 'o Paciente tem $probabilityResult chance de ter paludismo .',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (!isLoading && errorMessage.isEmpty && explanation.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Explicação: $explanation',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  '" Não é um substituto para aconselhamento médico profissional ou tratamento .',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.red,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              // const Spacer(), // Removed this line
              ElevatedButton(
                onPressed: () async {
                  final Uri phoneUri = Uri(scheme: 'tel', path: '111');
                  if (await canLaunchUrl(phoneUri)) {
                    await launchUrl(phoneUri);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not launch phone.')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[300],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                child: const Text(
                  'Contancto de emergencia',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // Handle view nearest hospital action
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[200],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                child: const Text(
                  'ver hospital mais proximo',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[700],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                child: const Text(
                  'voltar ao inicio .',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
