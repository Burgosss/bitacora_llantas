import 'guardar_cambios.dart';
import '../models/vehiculo.dart';

import 'package:flutter/material.dart';

class ActualizarKilometrajeScreen extends StatefulWidget {
  const ActualizarKilometrajeScreen({
    super.key,
    required this.kilometrajeActual,
    required this.guardar,
  });

  final int kilometrajeActual;
  final Future<Vehiculo> Function(int kilometraje) guardar;

  @override
  State<ActualizarKilometrajeScreen> createState() =>
      _ActualizarKilometrajeScreenState();
}

class _ActualizarKilometrajeScreenState
    extends State<ActualizarKilometrajeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _kilometraje = TextEditingController();

  @override
  void dispose() {
    _kilometraje.dispose();
    super.dispose();
  }

  Future<Vehiculo?> _guardar() async {
    if (!_formKey.currentState!.validate()) return null;
    return widget.guardar(int.parse(_kilometraje.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Actualizar kilometraje')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Kilometraje actual: ${widget.kilometrajeActual} km'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _kilometraje,
                decoration: const InputDecoration(
                  labelText: 'Nuevo kilometraje',
                  suffixText: 'km',
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,

                validator: (value) {
                  final texto = (value ?? '').trim();
                  if (texto.isEmpty) return 'Ingresa el kilometraje.';
                  final numero = int.tryParse(texto);
                  if (!RegExp(r'^[0-9]+$').hasMatch(texto) || numero == null) {
                    return 'Ingresa un entero no negativo.';
                  }
                  if (numero < widget.kilometrajeActual) {
                    return 'El kilometraje no puede ser menor a ${widget.kilometrajeActual} km.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              GuardarCambios(guardar: _guardar, label: 'Guardar kilometraje'),
            ],
          ),
        ),
      ),
    );
  }
}
