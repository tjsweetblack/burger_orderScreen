import 'package:auth_bloc/helpers/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../logic/cubit/auth_cubit.dart';
import '../../../routing/routes.dart';
import '../../../theming/styles.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            showLoadingDialog(context);
          } else if (state is AuthError) {
            Navigator.pop(context);
            showErrorDialog(context, state.message);
          } else if (state is UserSignIn) {
            Navigator.pop(context);
            Navigator.pushNamedAndRemoveUntil(
              context,
              Routes.mainScreen, //change here
              (route) => false,
            );
          } else if (state is UserNotVerified) {
            Navigator.pop(context);
            showInfoDialog(
              context,
              'Email Not Verified',
              'Please check your email and verify your account.',
            );
          }
        },
        builder: (context, state) {
          return _buildLoginPage(context);
        },
      ),
    );
  }

  Widget _buildLoginPage(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        // Wrap with SingleChildScrollView
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/logo/logo.png',
                height: 200), // Replace with your logo path
            const SizedBox(height: 16),
            Text(
              "Please enter your e-mail address\nand enter password",
              textAlign: TextAlign.center,
              style: TextStyles.font16Grey500Weight.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Enter your email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0), // Rounded corners
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Enter your password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0), // Rounded corners
                ),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {}, // Add forgot password functionality
                child: const Text("Forgot password?"),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<AuthCubit>().signInWithEmail(
                      _emailController.text,
                      _passwordController.text,
                    );
              },
              style: ElevatedButton.styleFrom(
                  minimumSize:
                      const Size(double.infinity, 50), // Full width button
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(110.0), // Rounded corners
                  ),
                  backgroundColor: Color.fromARGB(255, 13, 13, 14)),
              child: const Text(
                "Login",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account?"),
                GestureDetector(
                  onTap: () {
                    context.pushNamed(Routes.signupScreen);
                  },
                  child: Text(
                    "Sign Up",
                    style: TextStyles.font14Blue400Weight.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void showInfoDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
