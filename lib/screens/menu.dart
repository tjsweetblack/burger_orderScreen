import 'package:auth_bloc/screens/blog/blog_screen.dart';
import 'package:auth_bloc/screens/epaludismo/epaludismo_screen.dart';
import 'package:auth_bloc/screens/profile/profile.dart';
import 'package:auth_bloc/screens/quiz/quiz_page.dart';
import 'package:auth_bloc/screens/stats/stats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auth_bloc/logic/cubit/auth_cubit.dart';
import 'package:auth_bloc/routing/routes.dart';

Widget buildAppDrawer(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  return SizedBox(
    width: screenWidth * 0.3, // Covers 70% of the screen
    child: Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.white, // Match the header color from the image
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0, left: 16.0),
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.person_outline,
              color: Colors.red,
            ), // Match the icon from the image
            title: Text('Perfil', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const ProfileForm())); // Close the drawer
              // Handle Perfil action
            },
          ),
          ListTile(
            leading: Icon(Icons.article_outlined,
                color: Colors.red), // Using an article icon for Blog
            title: Text('Blog', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const BlogPage())); // Close the drawer
              // Handle Blog action
            },
          ),
          ListTile(
            leading: Icon(Icons.assessment,
                color: Colors.red), 
            title: Text('Estatísticas', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const AdminStatsScreen())); // Close the drawer
              // Handle Blog action
            },
          ),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Sair', style: TextStyle(color: Colors.red)),
            onTap: () async {
              Navigator.pop(context); // Close the drawer
              await context.read<AuthCubit>().signOut();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  Routes.loginScreen,
                  (route) => false,
                );
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Você está em',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.red, size: 16),
                    SizedBox(width: 4),
                    Text(
                        'Belas, Luanda'), // Replace with actual location if needed
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              '42 Luanda ISPTEC', // Example location from image
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Talatona', // Example location from image
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Luanda', // Example location from image
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Angola', // Example location from image
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    ),
  );
}
