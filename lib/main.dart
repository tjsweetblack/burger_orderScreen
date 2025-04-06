// main.dart
import 'package:auth_bloc/firebase_options.dart';
import 'package:auth_bloc/logic/cubit/auth_cubit.dart';
import 'package:auth_bloc/screens/splash_screen/splash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:device_preview/device_preview.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import 'routing/app_router.dart';
import 'routing/routes.dart';
import 'theming/colors.dart';
import 'package:provider/provider.dart';

late String initialRoute;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Future.wait([
    Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ),
  ]);

  // Check if onboarding is completed
  final prefs = await SharedPreferences.getInstance();
  bool onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

  if (!onboardingCompleted) {
    initialRoute =
        Routes.onboardingScreen; // Route to onboarding if not completed
  } else {
    FirebaseAuth.instance.authStateChanges().listen(
      (user) {
        if (user == null || !user.emailVerified) {
          initialRoute = Routes.loginScreen;
        } else {
          initialRoute = Routes.mainScreen;
        }
      },
    );
  }

  runApp(
    DevicePreview(
      enabled: false, // kDebugMode, // Enable only in debug mode if desired
      builder: (context) => MyApp(router: AppRouter()),
    ),
  );
}

class MyApp extends StatefulWidget {
  final AppRouter router;
  const MyApp({super.key, required this.router});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(
        const Duration(seconds: 3)); // Reduced delay for faster testing

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, child) {
          return _isLoading
              ? const SplashScreen()
              : MaterialApp(
                  locale: DevicePreview.locale(context),
                  builder: DevicePreview.appBuilder,
                  title: 'Login & Signup App',
                  theme: ThemeData(
                    useMaterial3: true,
                    textSelectionTheme: const TextSelectionThemeData(
                      cursorColor: ColorsManager.mainBlue,
                      selectionColor: Color.fromARGB(188, 36, 124, 255),
                      selectionHandleColor: ColorsManager.mainBlue,
                    ),
                  ),
                  onGenerateRoute: widget.router.generateRoute,
                  debugShowCheckedModeBanner: false,
                  initialRoute: initialRoute,
                );
        },
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<AppRouter>(
        'router', widget.router)); // Use widget.router
  }
}
