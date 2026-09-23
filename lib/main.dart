import 'package:flutter/material.dart';

import 'models/vehiculo.dart';
import 'screens/vehiculos_screen.dart';

void main() {
  runApp(const BitacoraLlantasApp());
}

const vehiculosDeEjemplo = [
  Vehiculo(alias: 'Auto familiar', placa: 'ABC-123-A', kilometraje: 45200),
  Vehiculo(
    alias: 'Camioneta de trabajo',
    placa: 'XYZ-789-B',
    kilometraje: 87350,
  ),
];

class BitacoraLlantasApp extends StatelessWidget {
  const BitacoraLlantasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bitácora de llantas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: const VehiculosScreen(vehiculos: vehiculosDeEjemplo),
    );
  }
}
