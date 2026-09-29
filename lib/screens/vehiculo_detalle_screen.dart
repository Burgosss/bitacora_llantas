import 'package:flutter/material.dart';

import '../models/vehiculo.dart';
import '../models/llanta.dart';
import 'asignar_llanta_screen.dart';
import 'actualizar_kilometraje_screen.dart';

class VehiculoDetalleScreen extends StatefulWidget {
  const VehiculoDetalleScreen({
    super.key,
    required this.vehiculo,
    required this.onVehiculoActualizado,
  });

  final Vehiculo vehiculo;
  final ValueChanged<Vehiculo> onVehiculoActualizado;

  @override
  State<VehiculoDetalleScreen> createState() => _VehiculoDetalleScreenState();
}

class _VehiculoDetalleScreenState extends State<VehiculoDetalleScreen> {
  late Vehiculo vehiculo = widget.vehiculo;

  Future<void> _actualizarKilometraje() async {
    final nuevo = await Navigator.of(context).push<int>(
      MaterialPageRoute<int>(
        builder: (context) => ActualizarKilometrajeScreen(
          kilometrajeActual: vehiculo.kilometraje,
        ),
      ),
    );
    if (!mounted || nuevo == null) return;
    setState(() => vehiculo = vehiculo.actualizarKilometraje(nuevo));
    widget.onVehiculoActualizado(vehiculo);
  }

  Future<void> _asignar(PosicionLlanta posicion) async {
    final llanta = await Navigator.of(context).push<Llanta>(
      MaterialPageRoute<Llanta>(
        builder: (context) => AsignarLlantaScreen(
          posicion: posicion,
          kilometraje: vehiculo.kilometraje,
        ),
      ),
    );
    if (!mounted || llanta == null) return;
    setState(() => vehiculo = vehiculo.asignarLlanta(posicion, llanta));
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
