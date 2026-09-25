import 'package:flutter/material.dart';

import '../models/vehiculo.dart';
import 'agregar_vehiculo_screen.dart';
import 'vehiculo_detalle_screen.dart';

class VehiculosScreen extends StatefulWidget {
  const VehiculosScreen({super.key, required this.vehiculos});

  final List<Vehiculo> vehiculos;

  @override
  State<VehiculosScreen> createState() => _VehiculosScreenState();
}

class _VehiculosScreenState extends State<VehiculosScreen> {
  late final List<Vehiculo> _vehiculos = List.of(widget.vehiculos);

  Future<void> _agregarVehiculo() async {
    final vehiculo = await Navigator.of(context).push<Vehiculo>(
      MaterialPageRoute<Vehiculo>(
        builder: (context) => AgregarVehiculoScreen(
          placasRegistradas: _vehiculos
              .map((vehiculo) => vehiculo.placa)
              .toSet(),
        ),
      ),
    );
    if (!mounted || vehiculo == null) return;
    setState(() => _vehiculos.add(vehiculo));
  }

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
            FilledButton.icon(
              onPressed: _agregarVehiculo,
              icon: const Icon(Icons.add),
              label: const Text('Agregar vehículo'),
            ),
            const SizedBox(height: 16),
            for (final vehiculo in _vehiculos)
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
                        builder: (context) => VehiculoDetalleScreen(
                          vehiculo: vehiculo,
                          onVehiculoActualizado: (actualizado) {
                            setState(() {
                              final indice = _vehiculos.indexWhere(
                                (item) => item.placa == actualizado.placa,
                              );
                              _vehiculos[indice] = actualizado;
                            });
                          },
                        ),
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
