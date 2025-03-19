import 'package:auth_bloc/firebase_options.dart';
import 'package:auth_bloc/logic/cubit/auth_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:device_preview/device_preview.dart';
import 'routing/app_router.dart';
import 'routing/routes.dart';
import 'theming/colors.dart';

late String initialRoute;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ),
    ScreenUtil.ensureScreenSize(),
    preloadSVGs(['assets/svgs/google_logo.svg'])
  ]);

  FirebaseAuth.instance.authStateChanges().listen(
    (user) {
      if (user == null || !user.emailVerified) {
        initialRoute = Routes.loginScreen;
      } else {
        initialRoute = Routes.mainScreen;
      }
    },
  );

  runApp(
    DevicePreview(
        enabled: false, builder: (context) => MyApp(router: AppRouter())),
  );
}

Future<void> preloadSVGs(List<String> paths) async {
  for (final path in paths) {
    final loader = SvgAssetLoader(path);
    await svg.cache.putIfAbsent(
      loader.cacheKey(null),
      () => loader.loadBytes(null),
    );
  }
}

class MyApp extends StatelessWidget {
  final AppRouter router;

  const MyApp({super.key, required this.router});

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
          return MaterialApp(
            debugShowCheckedModeBanner: false,
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
            onGenerateRoute: router.generateRoute,
            initialRoute: initialRoute,
          );
        },
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<AppRouter>('router', router));
  }
}
