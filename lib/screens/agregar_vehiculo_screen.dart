import 'package:flutter/material.dart';

import '../models/vehiculo.dart';

class AgregarVehiculoScreen extends StatefulWidget {
  const AgregarVehiculoScreen({super.key, required this.placasRegistradas});

  final Set<String> placasRegistradas;

  @override
  State<AgregarVehiculoScreen> createState() => _AgregarVehiculoScreenState();
}

class _AgregarVehiculoScreenState extends State<AgregarVehiculoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _alias = TextEditingController();
  final _placa = TextEditingController();
  final _kilometraje = TextEditingController();

  @override
  void dispose() {
    _alias.dispose();
    _placa.dispose();
    _kilometraje.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      Vehiculo(
        alias: _alias.text.trim(),
        placa: _placa.text.trim().toUpperCase(),
        kilometraje: int.parse(_kilometraje.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar vehículo')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _alias,
                decoration: const InputDecoration(labelText: 'Alias'),
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Ingresa un alias.'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _placa,
                decoration: const InputDecoration(labelText: 'Placa'),
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  final placa = (value ?? '').trim().toUpperCase();
                  if (placa.isEmpty) return 'Ingresa una placa.';
                  if (widget.placasRegistradas.any(
                    (registrada) => registrada.trim().toUpperCase() == placa,
                  )) {
                    return 'Ya existe un vehículo con esta placa.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _kilometraje,
                decoration: const InputDecoration(
                  labelText: 'Kilometraje',
                  suffixText: 'km',
                  helperText: 'Número entero igual o mayor que cero.',
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _guardar(),
                validator: (value) {
                  final texto = (value ?? '').trim();
                  if (texto.isEmpty) return 'Ingresa el kilometraje.';
                  if (!RegExp(r'^[0-9]+$').hasMatch(texto) ||
                      int.tryParse(texto) == null) {
                    return 'Ingresa un kilometraje entero no negativo.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _guardar,
                child: const Text('Guardar vehículo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
