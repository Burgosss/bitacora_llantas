import 'package:flutter/material.dart';

import '../models/vehiculo.dart';

class VehiculoDetalleScreen extends StatelessWidget {
  const VehiculoDetalleScreen({super.key, required this.vehiculo});

  final Vehiculo vehiculo;

  static const _posiciones = [
    'Delantera izquierda',
    'Delantera derecha',
    'Trasera izquierda',
    'Trasera derecha',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(vehiculo.alias)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Placa: ${vehiculo.placa}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('Kilometraje: ${vehiculo.kilometraje} km'),
            const SizedBox(height: 24),
            Text(
              'Posiciones de llantas',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Las posiciones se indican desde el asiento del conductor.',
            ),
            const SizedBox(height: 16),
            for (final posicion in _posiciones)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.radio_button_unchecked),
                  title: Text(posicion),
                  subtitle: const Text('Sin llanta asignada'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
