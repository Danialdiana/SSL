//main dart
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'home_page.dart';
import 'camera_page.dart';
import 'learning_page.dart';
import 'translate_page.dart';
import 'settings_page.dart';
import 'settings_controller.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await EasyLocalization.ensureInitialized();

  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    debugPrint('Ошибка получения камер: $e');
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ru'), Locale('kk'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ru'),
      child: ChangeNotifierProvider(
        create: (_) => SettingsController(),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 1; // По умолчанию открывается "Словарь"

  static final List<Widget> _pages = <Widget>[
    const CameraPage(),     // 0
    const LearningPage(),   // 1 — Словарь
    TranslatePage(),        // 2 — Перевод
    const SettingsPage(),   // 3 — Настройка
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsController>(context);

   return MaterialApp(
  title: tr('app_title'),
  debugShowCheckedModeBanner: false,
  locale: context.locale,
  supportedLocales: context.supportedLocales,
  localizationsDelegates: context.localizationDelegates,
  themeMode: settings.themeMode,
  theme: ThemeData(
    primaryColor: const Color(0xFF1565C0), 
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1565C0),
      foregroundColor: Colors.white,
      elevation: 2,
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1565C0),
      brightness: Brightness.light,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xFF1565C0),
      unselectedItemColor: Colors.grey,
    ),
    cardColor: Colors.white,
    textTheme: Theme.of(context).textTheme.apply(
      fontSizeFactor: settings.fontScale,
      bodyColor: Colors.black,
      displayColor: Colors.black,
    ),
    useMaterial3: true,
  ),
  darkTheme: ThemeData(
    primaryColor: const Color(0xFF1565C0),
    scaffoldBackgroundColor: const Color(0xFF0D47A1),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1565C0),
      foregroundColor: Colors.white,
      elevation: 2,
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color(0xFF1565C0),
      brightness: Brightness.dark,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF0D47A1),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
    ),
    cardColor: const Color(0xFF1565C0),
    textTheme: Theme.of(context).textTheme.apply(
      fontSizeFactor: settings.fontScale,
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    useMaterial3: true,
  ),
  home: Scaffold(
    appBar: AppBar(title: Text(tr('app_title'))),
    body: _pages[_selectedIndex],
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.camera_alt),
          label: tr('camera'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.book),
          label: tr('dictionary'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.translate),
          label: tr('translate'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.settings),
          label: tr('settings'),
        ),
      ],
    ),
  ),
);

  }
}
