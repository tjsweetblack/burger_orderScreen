import 'package:auth_bloc/main.dart';
import 'package:auth_bloc/screens/main_screen.dart';
import 'package:auth_bloc/screens/profile/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../logic/cubit/auth_cubit.dart';
import '../screens/create_password/ui/create_password.dart';
import '../screens/forget/ui/forget_screen.dart';
import '../screens/login/ui/login_screen.dart';
import '../screens/onboarding/main_onboarding.dart';
import '../screens/signup/ui/sign_up_sceen.dart';
import 'routes.dart';

class AppRouter {
  late AuthCubit authCubit;

  AppRouter() {
    authCubit = AuthCubit();
  }

  Route? generateRoute(RouteSettings settings) {
    if (settings.name == null) {
      return _handleInitialRoute();
    }

    switch (settings.name) {
      case Routes.forgetScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: authCubit,
            child: const ForgetScreen(),
          ),
        );

      case Routes.createPassword:
        final arguments = settings.arguments;
        if (arguments is List) {
          return MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: authCubit,
              child: CreatePassword(
                googleUser: arguments[0],
                credential: arguments[1],
              ),
            ),
          );
        }
        return null; // Handle incorrect arguments

      case Routes.signupScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: authCubit,
            child: const SignUpScreen(),
          ),
        );

      case Routes.loginScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: authCubit,
            child: const LoginScreen(),
          ),
        );

      case Routes.mainScreen:
        return MaterialPageRoute(builder: (_) => MapZzzPage());

      case Routes.orderDetails:
        final args =
            settings.arguments as Map<String, dynamic>?; // Receive arguments
        final orderId = args?['orderId'] as String?; // Extract orderId

        if (orderId == null || orderId.isEmpty) {
          // Handle case where orderId is missing or invalid
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(title: const Text("Error")),
              body:
                  const Center(child: Text("Order ID is missing or invalid.")),
            ),
          );
        }

      case Routes.onboardingScreen: // Add onboarding route
        return MaterialPageRoute(builder: (_) => const mainOnboarding());

      default:
        return null;
    }
  }

  Route? _handleInitialRoute() {
    switch (initialRoute) {
      case Routes.loginScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: authCubit,
            child: const LoginScreen(),
          ),
        );
      case Routes.mainScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: authCubit,
            child: MapZzzPage(),
          ),
        );
      default:
        return null;
    }
  }
}
