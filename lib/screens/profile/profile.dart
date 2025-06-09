import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import for FirebaseAuth

class ProfileForm extends StatefulWidget {
  const ProfileForm({super.key});

  @override
  _ProfileFormState createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  bool _isUpdating = false;
  late User? _user; // Add User variable
  late bool _isLoading;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _initializeData(); //initialize data in init state
  }

  Future<void> _initializeData() async {
    _user = FirebaseAuth.instance.currentUser; //get current user.
    if (_user != null) {
      try {
        //get user data from firestore
        DocumentSnapshot<Map<String, dynamic>> snapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(_user!.uid)
                .get();

        if (snapshot.exists) {
          var userData = snapshot.data() as Map<String, dynamic>;
          _firstNameController.text = userData['name']?.split(' ').first ?? '';
          _lastNameController.text = userData['name']?.split(' ').last ?? '';
          _usernameController.text = userData['username'] ?? '';
          _emailController.text = userData['email'] ?? '';
          _phoneController.text = userData['phoneNumber'] ?? '';
        }
      } catch (e) {
        //handle error
        print("Error fetching user data: $e");
        //show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Falha ao carregar dados do perfil: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading =
                false; //set loading to false whether or not the data loads
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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

  void _updateProfile(String userId) async {
    setState(() {
      _isUpdating = true;
    });

    try {
      // Get the updated values from the text controllers
      Map<String, dynamic> updatedData = {
        'name': '${_firstNameController.text} ${_lastNameController.text}',
        'username': _usernameController.text,
        'email': _emailController.text,
        'phoneNumber': _phoneController.text,
        // Add other fields as necessary
      };

      // Update the user data in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update(updatedData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Falha ao atualizar perfil: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('Error updating profile: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // Show a full-page loader if desired, or integrate into Scaffold
      return Scaffold(
        appBar: AppBar(
          title: const Text('Editar Perfil'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField("Nome", _firstNameController,
                              labelTextColor: Colors.black87),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                              "Sobrenome", _lastNameController,
                              labelTextColor: Colors.black87),
                        ),
                      ],
                    ),
                    _buildTextField("Nome de Usuário", _usernameController,
                        labelTextColor: Colors.black87),
                    _buildTextField("Email", _emailController,
                        keyboardType: TextInputType.emailAddress,
                        labelTextColor: Colors.black87),
                    _buildTextField("Número de Telefone", _phoneController,
                        keyboardType: TextInputType.phone,
                        prefixText:
                            '+234 ▼ ', // Consider making this dynamic or a country code picker
                        suffixIcon: const Icon(Icons.arrow_drop_down,
                            color: Colors.black87),
                        labelTextColor: Colors.black87),
                    _buildDropdown("Data de Nascimento",
                        [], // Pass empty list for placeholder
                        hintText: "DD/MM/AAAA", // Example hint
                        labelTextColor: Colors.black87),
                    _buildDropdown(
                        "Gender", [], // Pass empty list for placeholder
                        hintText: "Selecione o gênero", // Example hint
                        labelTextColor: Colors.black87),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isUpdating
                          ? null
                          : () {
                              if (_user?.uid != null) {
                                _updateProfile(_user!.uid);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: _isUpdating
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 3))
                          : const Text('Atualizar Perfil',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
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
            borderRadius: BorderRadius.circular(5),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String labelText, List<String> items,
      {String? hintText, Color? labelTextColor}) {
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
              color: Colors.white,
            ),
            child: DropdownButtonFormField<String>(
              value: null, // No default selection for placeholders
              hint: hintText != null
                  ? Text(hintText, style: TextStyle(color: Colors.grey[600]))
                  : null,
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child:
                      Text(item, style: const TextStyle(color: Colors.black)),
                );
              }).toList(),
              onChanged: items.isEmpty
                  ? null
                  : (String? newValue) {
                      // Disable if no items
                      // Handle dropdown changes
                    },
              dropdownColor: Colors.white,
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
