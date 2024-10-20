import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:tesis_v2/algoritm/algoritm.dart';
import 'package:tesis_v2/firebase_options.dart';
import 'package:tesis_v2/providers/auth_provider.dart';
import 'package:tesis_v2/providers/preferences_provider.dart';
import 'package:tesis_v2/screens/climate_information_screen.dart';
import 'package:tesis_v2/screens/initial_screen.dart';
import 'package:tesis_v2/screens/login_screen.dart';
import 'package:tesis_v2/screens/pois_information_screen.dart';
import 'package:tesis_v2/screens/preferences_selection_screen.dart';
import 'package:tesis_v2/screens/profile_screen.dart';
import 'package:tesis_v2/screens/schedule_selection_screen.dart';
import 'package:tesis_v2/screens/select_city_screen.dart';
import 'package:tesis_v2/screens/select_initial_point_screen.dart';
import 'package:tesis_v2/screens/specific_poi_selection_screen.dart';
import 'package:tesis_v2/services/navigation_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFF5FAFF),
        statusBarIconBrightness: Brightness.dark),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider.instance,
        ),
        ChangeNotifierProvider<PreferencesProvider>(
          create: (context) => PreferencesProvider.instance,
        )
      ],
      child: GetMaterialApp(
        navigatorKey: NavigationService.instance.navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          //colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        initialRoute: LoginScreen.routeName,
        routes: {
          LoginScreen.routeName: (context) => const LoginScreen(),
          InitialScreen.routeName: (context) => const InitialScreen(),
          SelectInitialPointScreen.routeName: (context) =>
              const SelectInitialPointScreen(),
          SelectCityScreen.routeName: (context) => const SelectCityScreen(),
          PreferencesSelectionScreen.routeName: (context) =>
              const PreferencesSelectionScreen(),
          ProfileScreen.routeName: (context) => const ProfileScreen(),
          PoisInformation.routeName: (context) => const PoisInformation(),
          ClimateInformationScreen.routeName: (context) =>
              const ClimateInformationScreen(),
          ScheduleSelectionScreen.routeName: (context) =>
              const ScheduleSelectionScreen(),
          SpecificPoiSelectionScreen.routeName: (context) =>
              const SpecificPoiSelectionScreen(),
          Algoritm.routeName: (context) => const Algoritm(),
        },
      ),
    );
  }
}
