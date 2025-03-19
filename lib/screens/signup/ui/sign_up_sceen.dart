import 'package:auth_bloc/helpers/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../logic/cubit/auth_cubit.dart';
import '../../../routing/routes.dart';
import '../../../theming/styles.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) async {
          if (state is AuthLoading) {
            showLoadingDialog(context);
          } else if (state is AuthError) {
            Navigator.pop(context);
            showErrorDialog(context, state.message);
          } else if (state is UserSignIn) {
            Navigator.pop(context);
            Navigator.pushNamedAndRemoveUntil(
              context,
              Routes.mainScreen,
              (route) => false,
            );
          } else if (state is UserSingupButNotVerified) {
            Navigator.pop(context);
            showInfoDialog(
              context,
              'Sign up Success',
              'Don\'t forget to verify your email. Check your inbox.',
            );
          }
        },
        builder: (context, state) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_add, size: 80, color: Colors.blue),
                  SizedBox(height: 16),
                  Text(
                    "Create Account",
                    style: TextStyles.font24Blue700Weight.copyWith(fontSize: 24),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Sign up now and start exploring all that our app has to offer.",
                    style: TextStyles.font14Grey400Weight.copyWith(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Full Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: "Phone Number",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AuthCubit>().signUpWithEmail(
                        nameController.text,
                        emailController.text,
                        passwordController.text,
                        phoneController.text);
                    },
                    child: Text("Sign Up"),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have an account? "),
                      GestureDetector(
                        onTap: () {
                          context.pushNamed(Routes.loginScreen);
                        },
                        child: Text(
                          "Sign In",
                          style: TextStyles.font14Blue400Weight.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text("Or sign up with Google"),
                  SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      context.read<AuthCubit>().signInWithGoogle();
                    },
                    child: SvgPicture.asset(
                      'assets/svgs/google_logo.svg',
                      width: 40,
                      height: 40,
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
