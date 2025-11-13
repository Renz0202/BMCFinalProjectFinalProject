import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/providers/cart_provider.dart';
import 'package:ecommerce_app/screens/auth_wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

// --- Color Palette ---
const Color kCharcoal = Color(0xFF121417);
const Color kElectricBlue = Color(0xFF0077FF);
const Color kTealAccent = Color(0xFF00C2A8);
const Color kSlateGrey = Color(0xFF2A2F35);
const Color kCoolOffWhite = Color(0xFFF5F7FA);

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);

  if (kIsWeb) {
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  }

  final cartProvider = CartProvider();
  cartProvider.initializeAuthListener();

  runApp(ChangeNotifierProvider.value(value: cartProvider, child: const MyApp()));

  FlutterNativeSplash.remove();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseText = GoogleFonts.latoTextTheme(
      Theme.of(context).textTheme,
    ).apply(bodyColor: kCharcoal, displayColor: kCharcoal);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AGP Lights & Sounds Equipment Shop',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: kElectricBlue,
          brightness: Brightness.light,
          primary: kElectricBlue,
          secondary: kTealAccent,
          error: Colors.red.shade700,
          surface: Colors.white,
          onSurface: kCharcoal,
        ).copyWith(onPrimary: Colors.white, onSecondary: Colors.white, onError: Colors.white),
        useMaterial3: true,
        scaffoldBackgroundColor: kCoolOffWhite,
        textTheme: baseText.copyWith(
          bodyMedium: baseText.bodyMedium?.copyWith(fontSize: 16),
          bodyLarge: baseText.bodyLarge?.copyWith(fontSize: 18),
          titleMedium: baseText.titleMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
          titleLarge: baseText.titleLarge?.copyWith(fontSize: 22, fontWeight: FontWeight.w700),
          headlineSmall: baseText.headlineSmall?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kElectricBlue,
            foregroundColor: Colors.white,
            minimumSize: const Size(48, 48),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 22),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: kElectricBlue,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: kElectricBlue,
            side: const BorderSide(color: kElectricBlue, width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: ButtonStyle(
            overlayColor: WidgetStatePropertyAll(kElectricBlue.withValues(alpha: 0.08)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: kSlateGrey.withValues(alpha: 0.4)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: kSlateGrey.withValues(alpha: 0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: kElectricBlue, width: 2),
          ),
          labelStyle: TextStyle(color: kSlateGrey.withValues(alpha: 0.8)),
          hintStyle: TextStyle(color: kSlateGrey.withValues(alpha: 0.5)),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          color: Colors.white,
          shadowColor: kElectricBlue.withValues(alpha: 0.12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          clipBehavior: Clip.antiAlias,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: kCharcoal,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        chipTheme: ChipThemeData(
          labelStyle: const TextStyle(color: kCharcoal),
          secondaryLabelStyle: const TextStyle(color: Colors.white),
          backgroundColor: Colors.white,
          disabledColor: Colors.grey.shade200,
          selectedColor: kElectricBlue,
          secondarySelectedColor: kElectricBlue,
          side: BorderSide(color: kSlateGrey.withValues(alpha: 0.25)),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  void _incrementCounter() => setState(() => _counter++);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text('$_counter', style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
