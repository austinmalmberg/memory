import 'package:flutter/material.dart';

import 'src/screens/memory/memory.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memory',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MemoryScreen(),
    );
  }
}
