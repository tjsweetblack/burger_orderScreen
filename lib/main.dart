import 'dart:async';
import 'dart:convert';
import 'package:auth_bloc/firebase_options.dart';
import 'package:auth_bloc/logic/cubit/auth_cubit.dart';
import 'package:auth_bloc/screens/splash_screen/splash.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import cloud_firestore
import 'package:device_preview/device_preview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart'; // Assuming this is needed for location
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:workmanager/workmanager.dart'; // Import workmanager if needed for background tasks
import 'routing/app_router.dart';
import 'routing/routes.dart';
import 'theming/colors.dart';
import 'package:provider/provider.dart'; // Assuming Provider is used elsewhere

late String initialRoute;

// Define a unique task name for our background job (if using workmanager)
// const String PROXIMITY_CHECK_TASK = "proximityCheckTask";

// Initialize FlutterLocalNotificationsPlugin (can be accessed globally or passed)

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Future.wait([
    Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ),
  ]);

  // Initialize Workmanager (if needed)
  // await Workmanager().initialize(
  //   callbackDispatcher, // The top-level function to execute
  //   isInDebugMode: kDebugMode, // Set to true for debugging
  // );

  // Register the periodic task for proximity checking (if needed)
  // await Workmanager().registerPeriodicTask(
  //   PROXIMITY_CHECK_TASK,
  //   PROXIMITY_CHECK_TASK,
  //   frequency: const Duration(minutes: 15), // Minimum 15 minutes on Android
  // );

  // Listen to auth state changes to determine the initial route
  // This listener is crucial for setting the initial route based on auth status.
  // We will wait for the first auth state change before setting the initialRoute.
  Completer<void> authCompleter = Completer<void>();
  FirebaseAuth.instance.authStateChanges().listen(
    (user) {
      if (user == null || !user.emailVerified) {
        initialRoute = Routes.loginScreen;
      } else {
        initialRoute = Routes.mainScreen;
      }
      // Complete the completer once the initial auth state is determined
      if (!authCompleter.isCompleted) {
        authCompleter.complete();
      }
    },
  );

  // Wait for the initial authentication state to be determined
  await authCompleter.future;

  // Initialize Firebase Messaging background handler (if using FCM)

  runApp(
    DevicePreview(
      enabled: false, // kDebugMode, // Enable DevicePreview only in debug mode
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
    // Initialize foreground local notifications (if using FCM)
    // Setup Push Notifications (if using FCM)
  }

  Future<void> _initializeApp() async {
    // Keep the splash screen delay
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Initialize local notifications specifically for the foreground isolate (if using FCM)

  // Setup Push Notifications (if using FCM)

  @override
  void dispose() {
    super.dispose();
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
              ? const SplashScreen() // Show Splash Screen while _isLoading is true
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
                  initialRoute: initialRoute, // Use the determined initialRoute
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
