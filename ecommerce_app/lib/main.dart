import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'firebase_options.dart';
import 'package:ecommerce_app/screens/auth_wrapper.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app/providers/cart_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color kCharcoal = Color(0xFF121417);
const Color kElectricBlue = Color(0xFF0077FF);
const Color kTealAccent = Color(0xFF00C2A8);
const Color kSlateGrey = Color(0xFF2A2F35);
const Color kCoolOffWhite = Color(0xFFF5F7FA);

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
  if (kIsWeb) {
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  }
  final cartProvider = CartProvider();
  cartProvider.initializeAuthListener();
  runApp(
    ChangeNotifierProvider.value(value: cartProvider, child: const MyApp()),
  );
  FlutterNativeSplash.remove();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseText = GoogleFonts.latoTextTheme(Theme.of(context).textTheme)
        .apply(bodyColor: kCharcoal, displayColor: kCharcoal);
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
        ).copyWith(
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onError: Colors.white,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: kCoolOffWhite,
        textTheme: baseText.copyWith(
          bodyMedium: baseText.bodyMedium?.copyWith(fontSize: 16),
          bodyLarge: baseText.bodyLarge?.copyWith(fontSize: 18),
          titleMedium: baseText.titleMedium?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          titleLarge: baseText.titleLarge?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: ButtonStyle(
            overlayColor: WidgetStatePropertyAll(
              kElectricBlue.withValues(alpha: 0.08),
            ),
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
            borderSide: const BorderSide(color: kElectricBlue, width: 2.0),
          ),
          labelStyle: TextStyle(color: kSlateGrey.withValues(alpha: 0.8)),
          hintStyle: TextStyle(color: kSlateGrey.withValues(alpha: 0.5)),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          color: Colors.white,
          shadowColor: kElectricBlue.withValues(alpha: 0.12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: kCharcoal,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
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
}import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'firebase_options.dart';
import 'package:ecommerce_app/screens/auth_wrapper.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app/providers/cart_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color kCharcoal = Color(0xFF121417);
const Color kElectricBlue = Color(0xFF0077FF);
const Color kTealAccent = Color(0xFF00C2A8);
const Color kSlateGrey = Color(0xFF2A2F35);
const Color kCoolOffWhite = Color(0xFFF5F7FA);

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
  if (kIsWeb) {
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  }
  final cartProvider = CartProvider();
  cartProvider.initializeAuthListener();
  runApp(
    ChangeNotifierProvider.value(value: cartProvider, child: const MyApp()),
  );
  FlutterNativeSplash.remove();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseText = GoogleFonts.latoTextTheme(Theme.of(context).textTheme)
        .apply(bodyColor: kCharcoal, displayColor: kCharcoal);
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
        ).copyWith(
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onError: Colors.white,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: kCoolOffWhite,
        textTheme: baseText.copyWith(
          bodyMedium: baseText.bodyMedium?.copyWith(fontSize: 16),
          bodyLarge: baseText.bodyLarge?.copyWith(fontSize: 18),
          titleMedium: baseText.titleMedium?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          titleLarge: baseText.titleLarge?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: ButtonStyle(
            overlayColor: WidgetStatePropertyAll(
              kElectricBlue.withValues(alpha: 0.08),
            ),
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
            borderSide: const BorderSide(color: kElectricBlue, width: 2.0),
          ),
          labelStyle: TextStyle(color: kSlateGrey.withValues(alpha: 0.8)),
          hintStyle: TextStyle(color: kSlateGrey.withValues(alpha: 0.5)),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          color: Colors.white,
          shadowColor: kElectricBlue.withValues(alpha: 0.12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: kCharcoal,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
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
import 'package:google_fonts/google_fonts.dart'; // 1. ADD THIS IMPORT
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'firebase_options.dart';
// 1. Import your new login screen
import 'package:ecommerce_app/screens/auth_wrapper.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app/providers/cart_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Note: We will use a custom theme below instead of AppTheme

// --- AGP LIGHTS & SOUNDS EQUIPMENT SHOP COLOR PALETTE ---
// Dark foundation, vibrant accents for a tech/audio vibe
const Color kCharcoal = Color(0xFF121417); // Near-black background tone
const Color kElectricBlue = Color(
  0xFF0077FF,
); // Primary accent (buttons, highlights)
const Color kTealAccent = Color(
  0xFF00C2A8,
); // Secondary accent (interactive states)
const Color kSlateGrey = Color(0xFF2A2F35); // Elevated surface
const Color kCoolOffWhite = Color(0xFFF5F7FA); // App scaffold background
// --- END PALETTE ---

void main() async {
  // 1. Preserve the splash screen before runApp
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // 2. Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Enable Firestore offline persistence and larger cache for faster reloads
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  // 3. Set web persistence (web-only) and prepare CartProvider BEFORE runApp
  if (kIsWeb) {
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  }

  // Manually create and initialize CartProvider before Flutter builds widgets
  final cartProvider = CartProvider();
  cartProvider.initializeAuthListener();

  // 4. Run the app, providing the pre-created CartProvider instance
  runApp(
    ChangeNotifierProvider.value(value: cartProvider, child: const MyApp()),
  );

  // 5. Remove the splash screen after the app is ready
  FlutterNativeSplash.remove();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // The CartProvider is provided at the top-level in main.dart
    return MaterialApp(
      // 2. This removes the "Debug" banner
      debugShowCheckedModeBanner: false,
      title: 'AGP Lights & Sounds Equipment Shop',

      // 1. --- THIS IS THE NEW, COMPLETE THEME ---
      theme: ThemeData(
        // Use fromSeed to avoid deprecated background/onBackground fields.
        colorScheme:
            ColorScheme.fromSeed(
              seedColor: kElectricBlue,
              brightness: Brightness.light,
              primary: kElectricBlue,
              secondary: kTealAccent,
              error: Colors.red.shade700,
              surface: Colors.white,
              onSurface: kCharcoal,
            ).copyWith(
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onError: Colors.white,
            ),
        useMaterial3: true,

        scaffoldBackgroundColor: kCoolOffWhite,

        // 4. Apply the Google Font (Lato) with improved readability
        textTheme: (() {
          final base = GoogleFonts.latoTextTheme(
            Theme.of(context).textTheme,
          ).apply(bodyColor: kCharcoal, displayColor: kCharcoal);
          return base.copyWith(
            bodyMedium: base.bodyMedium?.copyWith(fontSize: 16),
            bodyLarge: base.bodyLarge?.copyWith(fontSize: 18),
            titleMedium: base.titleMedium?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            titleLarge: base.titleLarge?.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
            headlineSmall: base.headlineSmall?.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          );
        })(),

        // 5. Global button style
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kElectricBlue, // uses colorScheme.primary
            foregroundColor: Colors.white, // uses colorScheme.onPrimary
            minimumSize: const Size(48, 48),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 22),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),

        // Make TextButtons readable and consistent
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: kElectricBlue,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),

        // Outline button for secondary emphasis
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: kElectricBlue, // readable on light background
            side: const BorderSide(color: kElectricBlue, width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),

        // Icon buttons with better contrast feedback
        iconButtonTheme: IconButtonThemeData(
          style: ButtonStyle(
            overlayColor: WidgetStatePropertyAll(
              kElectricBlue.withValues(alpha: 0.08),
            ),
          ),
        ),

        // 6. Global text field style
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
            borderSide: const BorderSide(color: kElectricBlue, width: 2.0),
          ),
          labelStyle: TextStyle(color: kSlateGrey.withValues(alpha: 0.8)),
          hintStyle: TextStyle(color: kSlateGrey.withValues(alpha: 0.5)),
        ),

        // 7. Global card style
        cardTheme: CardThemeData(
          elevation: 2,
          color: Colors.white,
          shadowColor: kElectricBlue.withValues(alpha: 0.12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
        ),

        // 8. Global AppBar style
        appBarTheme: const AppBarTheme(
          backgroundColor: kCharcoal,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),

        // Chips adapt label contrast on selection
        chipTheme: ChipThemeData(
          labelStyle: const TextStyle(
            color: kCharcoal,
          ), // default on light chips
          secondaryLabelStyle: const TextStyle(color: Colors.white),
          backgroundColor: Colors.white,
          disabledColor: Colors.grey.shade200,
          selectedColor: kElectricBlue,
          secondarySelectedColor: kElectricBlue,
          side: BorderSide(color: kSlateGrey.withValues(alpha: 0.25)),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // --- END OF NEW THEME ---

      // 3. Route through auth state
      home: const AuthWrapper(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
