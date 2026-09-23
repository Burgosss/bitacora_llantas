import 'package:flutter/material.dart';

import '../models/vehiculo.dart';
import 'vehiculo_detalle_screen.dart';

class VehiculosScreen extends StatelessWidget {
  const VehiculosScreen({super.key, required this.vehiculos});

  final List<Vehiculo> vehiculos;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bitácora de llantas')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Mis vehículos',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text('Selecciona un vehículo para consultar sus llantas.'),
            const SizedBox(height: 16),
            for (final vehiculo in vehiculos)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.directions_car_outlined),
                  title: Text(vehiculo.alias),
                  subtitle: Text(
                    'Placa: ${vehiculo.placa}\n${vehiculo.kilometraje} km',
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) =>
                            VehiculoDetalleScreen(vehiculo: vehiculo),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
