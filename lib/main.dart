import 'package:flutter/material.dart';

import 'data/vehiculos_api.dart';
import 'screens/vehiculos_screen.dart';

void main() {
  runApp(const BitacoraLlantasApp());
}

class BitacoraLlantasApp extends StatefulWidget {
  const BitacoraLlantasApp({super.key, this.api});
  final VehiculosApi? api;
  @override
  State<BitacoraLlantasApp> createState() => _BitacoraLlantasAppState();
}

class _BitacoraLlantasAppState extends State<BitacoraLlantasApp> {
  late final VehiculosApi api = widget.api ?? VehiculosApi();
  @override
  void dispose() {
    if (widget.api == null) api.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bitácora de llantas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: VehiculosScreen(api: api),
    );
  }
}
