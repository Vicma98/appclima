import 'package:flutter/material.dart';
import 'widgets/location_form.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clima por Coordenadas',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clima por Coordenadas')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: LocationForm(),
      ),
    );
  }
}