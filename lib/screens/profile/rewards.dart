import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RewardsPage(),
    );
  }
}

class RewardsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () {
            // Handle back button press
          },
        ),
        title: Text('Prémios'),
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          _buildRewardItem(
            image:
                'https://www.shopsemlim.com/wp-content/uploads/2020/11/Dragao.jpg',
            title: 'Caixa de Dragão.',
            points: 10,
            buttonText: 'Reivindicado',
            buttonColor: Colors.grey,
            strokeColor:
                const Color.fromARGB(255, 43, 43, 43), // Added strokeColor
          ),
          _buildRewardItem(
            image:
                'https://www.shopsemlim.com/wp-content/uploads/2020/11/Dragao.jpg',
            title: 'Caixa de Xelto.',
            points: 40,
            buttonText: 'Reivindicar',
            buttonColor: Colors.red,
            strokeColor:
                const Color.fromARGB(255, 43, 43, 43), // Added strokeColor
          ),
          _buildRewardItem(
            image:
                'https://www.shopsemlim.com/wp-content/uploads/2020/11/Dragao.jpg',
            title: 'Repelente Thermacell.',
            points: 60,
            buttonText: 'Reivindicar',
            buttonColor: Colors.red,
            strokeColor:
                const Color.fromARGB(255, 43, 43, 43), // Added strokeColor
          ),
        ],
      ),
    );
  }

  Widget _buildRewardItem({
    required String image,
    required String title,
    required int points,
    required String buttonText,
    required Color buttonColor,
    Color? strokeColor, // Added strokeColor parameter
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          color: strokeColor ??
              Colors.grey
                  .shade300, // Use strokeColor if provided, otherwise default to grey
          width: strokeColor != null
              ? 2.0
              : 1.0, // Set stroke width if strokeColor is provided
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Container(
                height: 80.0,
                child: Image.network(image),
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Nome:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(title),
            SizedBox(height: 8.0),
            Row(
              children: <Widget>[
                Icon(
                  Icons.star,
                  color: Colors.red,
                  size: 20.0,
                ),
                SizedBox(width: 4.0),
                Text('Pontos necessários: $points pontos'),
              ],
            ),
            SizedBox(height: 16.0),
            Align(
              alignment: Alignment.bottomLeft,
              child: ElevatedButton(
                onPressed: () {
                  // Handle button press
                },
                child: Text(
                  buttonText,
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
