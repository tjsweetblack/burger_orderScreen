// ignore_for_file: must_be_immutable

import 'package:auth_bloc/helpers/extensions.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/widgets/login_and_signup_animated_form.dart';
import '../../../core/widgets/terms_and_conditions_text.dart';
import '../../../helpers/rive_controller.dart';
import '../../../logic/cubit/auth_cubit.dart';
import '../../../routing/routes.dart';
import '../../../theming/styles.dart';

class CreatePassword extends StatelessWidget {
  late GoogleSignInAccount googleUser;
  late OAuthCredential credential;
  final RiveAnimationControllerHelper riveHelper =
      RiveAnimationControllerHelper();
  CreatePassword({
    super.key,
    required this.googleUser,
    required this.credential,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding:
              EdgeInsets.only(left: 30.w, right: 30.w, bottom: 15.h, top: 5.h),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Criar Senha',
                          style: TextStyles.font24Blue700Weight),
                      BlocConsumer<AuthCubit, AuthState>(
                        buildWhen: (previous, current) => previous != current,
                        listenWhen: (previous, current) => previous != current,
                        listener: (context, state) async {
                          if (state is AuthLoading) {
                            print("loading");
                          } else if (state is AuthError) {
                            riveHelper.addFailController();
                            await AwesomeDialog(
                              context: context,
                              dialogType: DialogType.error,
                              animType: AnimType.rightSlide,
                              title: 'Error',
                              desc: state.message,
                            ).show();
                          } else if (state is UserSingupAndLinkedWithGoogle) {
                            riveHelper.addSuccessController();
                            await AwesomeDialog(
                              context: context,
                              dialogType: DialogType.success,
                              animType: AnimType.rightSlide,
                              title: 'Cadastro Realizado com Sucesso',
                              desc: 'Você se cadastrou com sucesso.',
                            ).show();
                            await Future.delayed(const Duration(seconds: 2));
                            riveHelper.removeAllControllers();
                            if (!context.mounted) return;
                            context.pushNamedAndRemoveUntil(
                              Routes.mainScreen,
                              predicate: (route) => false,
                            );
                          }
                        },
                        builder: (context, state) {
                          return EmailAndPassword(
                            isPasswordPage: true,
                            googleUser: googleUser,
                            credential: credential,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const TermsAndConditionsText(),
            ],
          ),
        ),
      ),
    );
  }
}
