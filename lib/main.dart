import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stylelist/firebase_options.dart';
import 'package:stylelist/pages/repository/auth_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('th_TH');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        textTheme: GoogleFonts.robotoTextTheme(
          Theme.of(context).textTheme.copyWith(
            displayLarge: const TextStyle(fontWeight: FontWeight.normal),
            displayMedium: const TextStyle(fontWeight: FontWeight.normal),
            displaySmall: const TextStyle(fontWeight: FontWeight.normal),
            headlineMedium: const TextStyle(fontWeight: FontWeight.normal),
            headlineSmall: const TextStyle(fontWeight: FontWeight.normal),
            titleLarge: const TextStyle(fontWeight: FontWeight.normal),
            titleMedium: const TextStyle(fontWeight: FontWeight.normal),
            titleSmall: const TextStyle(fontWeight: FontWeight.normal),
            bodyLarge: const TextStyle(fontWeight: FontWeight.normal),
            bodyMedium: const TextStyle(fontWeight: FontWeight.normal),
            bodySmall: const TextStyle(fontWeight: FontWeight.normal),
            labelLarge: const TextStyle(fontWeight: FontWeight.normal),
            labelSmall: const TextStyle(fontWeight: FontWeight.normal),
          ),
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('th', 'TH'),
      ],
      home: const AuthPage());
  }
}

