import '../data/vehiculos_api.dart';

import 'package:flutter/material.dart';

import '../models/vehiculo.dart';
import 'agregar_vehiculo_screen.dart';
import 'vehiculo_detalle_screen.dart';

class VehiculosScreen extends StatefulWidget {
  const VehiculosScreen({super.key, required this.api});

  final VehiculosApi api;

  @override
  State<VehiculosScreen> createState() => _VehiculosScreenState();
}

class _VehiculosScreenState extends State<VehiculosScreen> {
  List<Vehiculo> _vehiculos = [];
  bool _cargando = true;
  String? _error;
  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final resultado = await widget.api.listar();
      if (mounted) {
        setState(() {
          _vehiculos = resultado;
          _cargando = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _cargando = false;
          _error = error is ApiException
              ? error.message
              : 'No se pudieron cargar los vehículos.';
        });
      }
    }
  }

  Future<void> _agregarVehiculo() async {
    final vehiculo = await Navigator.of(context).push<Vehiculo>(
      MaterialPageRoute<Vehiculo>(
        builder: (context) => AgregarVehiculoScreen(
          guardar: widget.api.crear,
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
      appBar: AppBar(
        title: const Text('Bitácora de llantas'),
        actions: [
          IconButton(
            onPressed: _cargando ? null : _cargar,
            tooltip: 'Actualizar lista',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
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
              onPressed: _cargando || _error != null ? null : _agregarVehiculo,
              icon: const Icon(Icons.add),
              label: const Text('Agregar vehículo'),
            ),
            const SizedBox(height: 16),
            if (_cargando) const Center(child: CircularProgressIndicator()),
            if (_error != null) ...[
              Text(_error!),
              TextButton(onPressed: _cargar, child: const Text('Reintentar')),
            ],
            if (!_cargando && _error == null && _vehiculos.isEmpty)
              const Text('Todavía no hay vehículos. Agrega el primero.'),
            if (!_cargando && _error == null)
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
                            api: widget.api,
                            onVehiculoActualizado: (actualizado) {
                              setState(() {
                                final indice = _vehiculos.indexWhere(
                                  (item) => item.id == actualizado.id,
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
