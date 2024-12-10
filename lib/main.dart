import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storedge/constants.dart';
import 'package:storedge/entry_point.dart';
import 'package:storedge/route/router.dart' as router;
import 'package:storedge/theme/button_theme.dart';
import 'package:storedge/theme/theme_provider.dart';

void main() async {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const Main(),
    ),
  );
}

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _MainState();

  static _MainState of(BuildContext context) =>
      context.findAncestorStateOfType<_MainState>()!;
}

class _MainState extends State<Main> {
  bool useMaterial3 = true;
  ThemeMode _themeMode = ThemeMode.light
  ;
  ColorSeed colorSelected = ColorSeed.baseColor;
  ColorScheme? imageColorScheme = const ColorScheme.light();

  bool get useLightMode => switch (_themeMode) {
        ThemeMode.system =>
          View.of(context).platformDispatcher.platformBrightness ==
              Brightness.light,
        ThemeMode.light => true,
        ThemeMode.dark => false
      };
    void handleBrightnessChange(bool useLightMode) {
    setState(() {
      _themeMode = useLightMode ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StorEdge',
      onGenerateRoute: router.generateRoute,
      themeMode: _themeMode,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: useMaterial3,
        brightness: Brightness.light,
        fontFamily: "Plus Jakarta Sans",
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: blackColor40),
        ),
        outlinedButtonTheme: outlinedButtonTheme(),
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: useMaterial3,
        brightness: Brightness.dark,
        fontFamily: "Plus Jakarta Sans",
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: blackColor40),
        ),
        outlinedButtonTheme: outlinedButtonTheme(),
      ),
      home: const EntryPoint(),
    );
  }
}
