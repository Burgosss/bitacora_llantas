import '../data/vehiculos_api.dart';

import 'package:flutter/material.dart';

import '../models/vehiculo.dart';
import '../models/llanta.dart';
import 'asignar_llanta_screen.dart';
import 'actualizar_kilometraje_screen.dart';

class VehiculoDetalleScreen extends StatefulWidget {
  const VehiculoDetalleScreen({
    super.key,
    required this.vehiculo,
    required this.api,
    required this.onVehiculoActualizado,
  });

  final Vehiculo vehiculo;
  final VehiculosApi api;
  final ValueChanged<Vehiculo> onVehiculoActualizado;

  @override
  State<VehiculoDetalleScreen> createState() => _VehiculoDetalleScreenState();
}

class _VehiculoDetalleScreenState extends State<VehiculoDetalleScreen> {
  late Vehiculo vehiculo = widget.vehiculo;

  Future<void> _actualizarKilometraje() async {
    final nuevo = await Navigator.of(context).push<Vehiculo>(
      MaterialPageRoute<Vehiculo>(
        builder: (context) => ActualizarKilometrajeScreen(
          kilometrajeActual: vehiculo.kilometraje,
          guardar: (km) => widget.api.actualizarKilometraje(vehiculo.id, km),
        ),
      ),
    );
    if (!mounted || nuevo == null) return;
    setState(() => vehiculo = nuevo);
    widget.onVehiculoActualizado(vehiculo);
  }

  Future<void> _asignar(PosicionLlanta posicion) async {
    final llanta = await Navigator.of(context).push<Vehiculo>(
      MaterialPageRoute<Vehiculo>(
        builder: (context) => AsignarLlantaScreen(
          posicion: posicion,
          guardar: (llanta) =>
              widget.api.asignar(vehiculo.id, posicion, llanta),
          kilometraje: vehiculo.kilometraje,
        ),
      ),
    );
    if (!mounted || llanta == null) return;
    setState(() => vehiculo = llanta);
    widget.onVehiculoActualizado(vehiculo);
  }

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
            TextButton.icon(
              onPressed: _actualizarKilometraje,
              icon: const Icon(Icons.speed),
              label: const Text('Actualizar kilometraje'),
            ),
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
            for (final posicion in PosicionLlanta.values)
              Card(
                child: ListTile(
                  leading: Icon(
                    vehiculo.llantas.containsKey(posicion)
                        ? Icons.check_circle_outline
                        : Icons.radio_button_unchecked,
                  ),
                  title: Text(posicion.etiqueta),
                  subtitle: vehiculo.llantas.containsKey(posicion)
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${vehiculo.llantas[posicion]!.marca} · ${vehiculo.llantas[posicion]!.modelo}\n'
                              'Instalada a los ${vehiculo.llantas[posicion]!.kilometrajeInstalacion} km',
                            ),
                            Text(
                              'Recorridos: ${vehiculo.kilometraje - vehiculo.llantas[posicion]!.kilometrajeInstalacion} km',
                            ),
                          ],
                        )
                      : const Text('Sin llanta asignada'),
                  trailing: vehiculo.llantas.containsKey(posicion)
                      ? null
                      : const Icon(Icons.add),
                  onTap: vehiculo.llantas.containsKey(posicion)
                      ? null
                      : () => _asignar(posicion),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
