import 'package:flutter/material.dart';
import 'epaludismo_result_screen.dart'; // Assuming epaludismo_result_screen.dart is the file name

class EPaldudismoScreen extends StatefulWidget {
  const EPaldudismoScreen({super.key});

  @override
  State<EPaldudismoScreen> createState() => _EPaldudismoScreenState();
}

class _EPaldudismoScreenState extends State<EPaldudismoScreen> {
  final TextEditingController _symptomsController = TextEditingController();

  @override
  void dispose() {
    _symptomsController.dispose();
    super.dispose();
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
      backgroundColor: Colors.white, // Set Scaffold background to white
      body: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 30.0,
            vertical: 25.0), // Increased horizontal and vertical padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 30), // Increased spacing
            const Text(
              'Datalhe os sintomas do paciente e receba a probalidade de malaria',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18, // Slightly reduced font size
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 30), // Increased spacing
            const Text(
              'Detalhes de sintomas',
              style: TextStyle(
                fontSize: 16,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 15), // Increased spacing
            Container(
              height: 150, // Reduced height for the input field
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: Colors.black), // Add black border
              ),
              child: TextFormField(
                controller: _symptomsController,
                maxLines: 5, // Set a specific maxLines to control height
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText:
                      'Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in', // Placeholder text as in the image
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                style: const TextStyle(color: Colors.black87),
              ),
            ),
            const SizedBox(height: 40), // Increased spacing
            ElevatedButton(
              onPressed: () {
                final String symptoms = _symptomsController.text;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          MalariaResultScreen(symptomsDescription: symptoms)),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              child: const Text(
                'Ver Resultados',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
