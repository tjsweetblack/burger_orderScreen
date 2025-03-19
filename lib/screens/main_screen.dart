import 'package:auth_bloc/screens/home/ui/queue_screen.dart';
import 'package:auth_bloc/screens/home/ui/cooking.dart';
import 'package:auth_bloc/screens/home/ui/packing.dart';
import 'package:auth_bloc/screens/home/ui/completed_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DelayedScreen extends StatelessWidget {
  const DelayedScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Delayed Screen"));
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  static List<Widget> _widgetOptions = <Widget>[
    const QueueScreen(),
    const CookingScreen(),
    const PackingScreen(),
    const CompletedScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            _buildlogo(),
            _buildHeader(),
            Expanded(
              child: _widgetOptions[_selectedIndex],
            ),
            if (_selectedIndex != 3) _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildlogo() {
    final now = DateTime.now();
    final formattedDateTime =
        DateFormat('EEEE, MMMM d, yyyy h:mm a').format(now);
    return Container(
      padding: const EdgeInsets.all(5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Image.asset('assets/images/logo/logo.png', height: 50),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Text(formattedDateTime),
          ),
          IconButton(
            onPressed: () {
              _showLogoutDialog(context);
            },
            icon: const Icon(Icons.power_settings_new),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildHeaderText("ACTIVE", 0),
          _buildHeaderText("COMPLETED", 3),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Log Out"),
          content: const Text("Do you wish to log out?"),
          actions: <Widget>[
            TextButton(
              child: const Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Yes"),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pop();
                Navigator.pushNamedAndRemoveUntil(
                    context, '/signin', (route) => false);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeaderText(String text, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          decoration:
              isSelected ? TextDecoration.underline : TextDecoration.none,
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildFooterButton("NEW ORDERS", 0),
          _buildFooterButton("COOKING", 1),
          _buildFooterButton("PACKING", 2),
        ],
      ),
    );
  }

  Widget _buildFooterButton(String text, int index) {
    final isSelected = _selectedIndex == index;
    return TextButton(
      onPressed: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          decoration:
              isSelected ? TextDecoration.underline : TextDecoration.none,
        ),
      ),
    );
  }
}
