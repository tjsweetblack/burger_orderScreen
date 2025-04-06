import 'package:auth_bloc/logic/cubit/auth_cubit.dart';
import 'package:auth_bloc/routing/routes.dart';
import 'package:auth_bloc/screens/profile/rewards.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Placeholder function for updating profile information
  void _updateProfile(String userId) async {
    setState(() => _isUpdating = true);
    try {
      // Simulate an update process
      await Future.delayed(const Duration(seconds: 2));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            backgroundColor: Colors.grey,
            content: Text('Profile updated successfully!',
                style: TextStyle(color: Colors.white))),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.grey,
            content: Text('Error updating profile: $e',
                style: TextStyle(color: Colors.white))),
      );
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authCubit = context.watch<AuthCubit>();
    final user = authCubit.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Profile")),
        body: const Center(
            child: Text("No user logged in", style: TextStyle(fontSize: 18))),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white, // White background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Colors.black), // Black back arrow
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('',
            style: TextStyle(color: Colors.black)), // Empty title
        centerTitle: false,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
                    color: Colors.black)); // Black indicator
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.black))); // Black text
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
                child: Text('No user data found.',
                    style: TextStyle(color: Colors.black))); // Black text
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;
          _firstNameController.text = userData['name']?.split(' ').first ?? '';
          _lastNameController.text = userData['name']?.split(' ').last ?? '';
          _usernameController.text = userData['username'] ?? '';
          _emailController.text = userData['email'] ?? '';
          _phoneController.text = userData['phoneNumber'] ?? '';

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: NetworkImage(
                            userData['photoURL'] ??
                                'https://cdn4.iconfinder.com/data/icons/glyphs/24/icons_user-512.png',
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                            border: Border.all(color: Colors.white, width: 1),
                          ),
                          padding: const EdgeInsets.all(4.0),
                          child: const Icon(Icons.edit,
                              color: Colors.white, size: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'Caçador de Mosquitos', // Replace with actual user role if available
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: LinearProgressIndicator(
                      value: 0.7, // Example progress value
                      backgroundColor: Colors.grey[300],
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.red),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star_border, color: Colors.black, size: 16),
                        SizedBox(width: 4),
                        Text('+30 pontos',
                            style:
                                TextStyle(color: Colors.black, fontSize: 14)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RewardsPage()));
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.redeem, color: Colors.red, size: 16),
                          SizedBox(width: 4),
                          Text('Reivindicar prêmios',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildTextField("Primeiro nome", _firstNameController,
                      labelTextColor: Colors.black87),
                  _buildTextField("Sobrenome", _lastNameController,
                      labelTextColor: Colors.black87),
                  _buildTextField("Nome de usuário", _usernameController,
                      labelTextColor: Colors.black87),
                  _buildTextField("Email", _emailController,
                      keyboardType: TextInputType.emailAddress,
                      labelTextColor: Colors.black87),
                  _buildTextField("Número de telefone", _phoneController,
                      keyboardType: TextInputType.phone,
                      prefixText: '+234 ▼ ', // Added prefix
                      suffixIcon: const Icon(Icons.arrow_drop_down,
                          color: Colors.black87),
                      labelTextColor: Colors.black87),
                  _buildDropdown("Aniversário", const [''],
                      labelTextColor: Colors.black87), // Add actual items
                  _buildDropdown("Gênero", const [''],
                      labelTextColor: Colors.black87), // Add actual items
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed:
                        _isUpdating ? null : () => _updateProfile(user.uid),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        // Rounded button
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: _isUpdating
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.lock, color: Colors.white),
                              SizedBox(width: 8),
                              Text('Alterar a senha',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16)),
                            ],
                          ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () async {
                        await authCubit.signOut();
                        if (context.mounted) {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            Routes.loginScreen,
                            (route) => false,
                          );
                        }
                      },
                      child: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.black87, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(String labelText, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text,
      String? prefixText,
      Widget? suffixIcon,
      Color? labelTextColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: labelTextColor ?? Colors.black87),
          prefixText: prefixText,
          suffixIcon: suffixIcon,
          prefixStyle: const TextStyle(color: Colors.black),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black38),
            borderRadius: BorderRadius.circular(5), // Rounded corners
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(5), // Rounded corners
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String labelText, List<String> items,
      {Color? labelTextColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelText,
            style: TextStyle(color: labelTextColor ?? Colors.black87),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black38),
              borderRadius: BorderRadius.circular(5),
              color: Colors.white, // White background for dropdown container
            ),
            child: DropdownButtonFormField<String>(
              value: null, // Set to null initially
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child:
                      Text(item, style: const TextStyle(color: Colors.black)),
                );
              }).toList(),
              onChanged: (String? newValue) {
                // Handle dropdown changes
              },
              dropdownColor: Colors.white, // White background for dropdown menu
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                border: InputBorder.none,
                suffixIcon: Icon(Icons.arrow_drop_down, color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
