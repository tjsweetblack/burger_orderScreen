import 'package:auth_bloc/helpers/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../../core/widgets/login_and_signup_animated_form.dart';
import '../../../logic/cubit/auth_cubit.dart';
import '../../../routing/routes.dart';
import '../../../theming/styles.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) async {
          if (state is AuthLoading) {
            showLoadingDialog(context);
          } else if (state is AuthError) {
            Navigator.pop(context); // Close loading dialog
            showErrorDialog(context, state.message);
          } else if (state is UserSignIn) {
            Navigator.pop(context); // Close loading dialog
            Navigator.pushNamedAndRemoveUntil(
              context,
              Routes.mainScreen,
              (route) => false,
            );
          } else if (state is UserNotVerified) {
            Navigator.pop(context); // Close loading dialog
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20), // Adjust padding for spacing
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Text
            Text(
              'Login',
              style: TextStyles.font24Blue700Weight.copyWith(
                fontSize: 24, // Adjusted font size directly
              ),
            ),
            Gap(10),
            Text(
              "Login to continue using the app",
              style: TextStyles.font14Grey400Weight.copyWith(
                fontSize: 14, // Adjusted font size directly
              ),
            ),
            Gap(20),
            EmailAndPassword(),
            Gap(15),
            Gap(20),
            TextButton(
              onPressed: () {
                context.pushNamed(Routes.signupScreen);
              },
              child: Text(
                "Don't have an account? Sign up",
                style: TextStyles.font14Blue400Weight.copyWith(
                  fontSize: 14, // Adjusted font size directly
                ),
              ),
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
