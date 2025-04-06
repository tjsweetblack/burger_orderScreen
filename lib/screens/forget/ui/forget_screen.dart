import 'package:auth_bloc/helpers/extensions.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import '../../../logic/cubit/auth_cubit.dart';
import '../../../theming/styles.dart';

class ForgetScreen extends StatefulWidget {
  const ForgetScreen({super.key});

  @override
  State<ForgetScreen> createState() => _ForgetScreenState();
}

class _ForgetScreenState extends State<ForgetScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set background color to black
      body: SafeArea(
        child: Padding(
          padding:
              EdgeInsets.only(left: 30.w, right: 30.w, bottom: 15.h, top: 5.h),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reset',
                              style: TextStyles.font24Blue700Weight.copyWith(
                                  color: Colors.white), // White Reset text
                            ),
                            Gap(10.h),
                            Text(
                              "Enter email to reset password",
                              style: TextStyles.font14Grey400Weight.copyWith(
                                  color: Colors.white70), // Lighter white text
                            ),
                          ],
                        ),
                      ),
                      Gap(20.h),
                      BlocConsumer<AuthCubit, AuthState>(
                        listenWhen: (previous, current) => previous != current,
                        listener: (context, state) async {
                          if (state is AuthLoading) {
                            print("loading");
                            showLoadingDialog(context); // Show loading dialog
                          } else if (state is AuthError) {
                            Navigator.pop(context); // Pop loading dialog
                            await showErrorDialog(
                                context, state.message); // Show error dialog
                          } else if (state is ResetPasswordSent) {
                            Navigator.pop(context); // Pop loading dialog
                            showSuccessDialog(
                              // Use the new Success Dialog
                              context,
                              'Reset Password Email Sent!',
                              'A password reset link has been sent to your email. Please check your inbox and follow the instructions to reset your password.',
                            );
                          }
                        },
                        buildWhen: (previous, current) {
                          return previous != current;
                        },
                        builder: (context, state) {
                          return const PasswordResetThemed(); // Use themed PasswordReset widget
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Ensure minimum height
                  children: [
                    const TermsAndConditionsTextThemed(), // Use themed Terms and Conditions text
                    Gap(24.h),
                    const AlreadyHaveAccountTextThemed(), // Use themed Already have account text
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ), // White loading indicator
      ),
    );
  }

  Future<void> showErrorDialog(BuildContext context, String message) async {
    await AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.rightSlide,
      title: 'Error',
      desc: message,
      titleTextStyle: const TextStyle(color: Colors.white), // White title text
      descTextStyle:
          const TextStyle(color: Colors.white), // White description text
      headerAnimationLoop: false,
      dialogBackgroundColor: Colors.grey[900], // Dark dialog background
      buttonsTextStyle:
          const TextStyle(color: Colors.white), // White button text
    ).show();
  }

  void showSuccessDialog(BuildContext context, String title, String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success, // Change to DialogType.success
      animType: AnimType.rightSlide,
      title: title,
      desc: message,
      titleTextStyle: const TextStyle(color: Colors.white), // White title text
      descTextStyle:
          const TextStyle(color: Colors.white), // White description text
      headerAnimationLoop: false,
      dialogBackgroundColor: Colors.grey[900], // Dark dialog background
      buttonsTextStyle:
          const TextStyle(color: Colors.white), // White button text
      btnOkText: 'OK', // Set button text to "OK"
      btnOkOnPress: () {
        // Action when OK is pressed
        context.pop(); // Go back to login page
      },
      btnOkColor: Colors.green[700], // Optional: Style OK button color
    ).show();
  }

  @override
  void initState() {
    super.initState();
    BlocProvider.of<AuthCubit>(context);
  }
}

class PasswordResetThemed extends StatefulWidget {
  const PasswordResetThemed({super.key});

  @override
  State<PasswordResetThemed> createState() => _PasswordResetThemedState();
}

class _PasswordResetThemedState extends State<PasswordResetThemed> {
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: emailController,
          style: const TextStyle(color: Colors.white), // Input text color white
          decoration: InputDecoration(
            labelText: "Email",
            labelStyle: const TextStyle(
                color: Colors.white70), // Label text color white
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide:
                  const BorderSide(color: Colors.white54), // White border
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide:
                  const BorderSide(color: Colors.white), // White focused border
            ),
          ),
        ),
        Gap(24.h),
        ElevatedButton(
          onPressed: () {
            context.read<AuthCubit>().resetPassword(emailController.text);
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(110.0)),
            backgroundColor: Colors.white, // White button
            foregroundColor: Colors.black, // Black button text
          ),
          child: const Text(
            "Reset Password",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold), // Black button text
          ),
        ),
      ],
    );
  }
}

class TermsAndConditionsTextThemed extends StatelessWidget {
  const TermsAndConditionsTextThemed({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyles.font13Grey400Weight.copyWith(
            height: 1.5,
            fontSize: 13.sp,
            color: Colors.white70, // White terms and conditions text
          ),
          children: const [
            TextSpan(text: 'By continue, you agree to our\n'),
            TextSpan(
              text: 'Terms of Service',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: ' and '),
            TextSpan(
              text: 'Privacy Policy',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class AlreadyHaveAccountTextThemed extends StatelessWidget {
  const AlreadyHaveAccountTextThemed({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account?",
          style: TextStyle(
              color: Colors.white70), // White "Don't have an account?" text
        ),
        GestureDetector(
          onTap: () {
            context.pop();
          },
          child: Text(
            "Sign In",
            style: TextStyles.font14Blue400Weight.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white, // White "Sign In" text
            ),
          ),
        ),
      ],
    );
  }
}
