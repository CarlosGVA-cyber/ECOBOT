import 'package:flutter/material.dart';

import 'access.dart';
import 'console.dart';
import 'ui.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = ColorScheme.fromSeed(
      seedColor: mint,
      brightness: Brightness.dark,
      primary: mint,
      surface: panel,
    );
    return MaterialApp(
      title: 'ECOBOT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: colors,
        scaffoldBackgroundColor: background,
        appBarTheme: const AppBarTheme(backgroundColor: background),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
          fillColor: panel,
        ),
      ),
      routes: {
        '/': (_) => const AccessScreen(),
        '/console': (context) =>
            switch (ModalRoute.of(context)?.settings.arguments) {
              final Session session => ConsoleScreen(session: session),
              _ => const AccessScreen(),
            },
      },
    );
  }
}
