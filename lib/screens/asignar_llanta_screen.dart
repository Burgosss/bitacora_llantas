import 'package:flutter/material.dart';

import '../models/llanta.dart';

class AsignarLlantaScreen extends StatefulWidget {
  const AsignarLlantaScreen({
    super.key,
    required this.posicion,
    required this.kilometraje,
  });

  final PosicionLlanta posicion;
  final int kilometraje;

  @override
  State<AsignarLlantaScreen> createState() => _AsignarLlantaScreenState();
}

class _AsignarLlantaScreenState extends State<AsignarLlantaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _marca = TextEditingController();
  final _modelo = TextEditingController();
  final _kilometraje = TextEditingController();

  @override
  void dispose() {
    _marca.dispose();
    _modelo.dispose();
    _kilometraje.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      Llanta(
        marca: _marca.text.trim(),
        modelo: _modelo.text.trim(),
        kilometrajeInstalacion: int.parse(_kilometraje.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Asignar llanta')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                widget.posicion.etiqueta,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text('Kilometraje actual: ${widget.kilometraje} km'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _marca,
                decoration: const InputDecoration(labelText: 'Marca'),
                textInputAction: TextInputAction.next,
                validator: (value) =>
                    (value ?? '').trim().isEmpty ? 'Ingresa la marca.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _modelo,
                decoration: const InputDecoration(labelText: 'Modelo'),
                textInputAction: TextInputAction.next,
                validator: (value) =>
                    (value ?? '').trim().isEmpty ? 'Ingresa el modelo.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _kilometraje,
                decoration: const InputDecoration(
                  labelText: 'Kilometraje de instalación',
                  suffixText: 'km',
                ),
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.number,
                onFieldSubmitted: (_) => _guardar(),
                validator: (value) {
                  final texto = (value ?? '').trim();
                  if (texto.isEmpty) {
                    return 'Ingresa el kilometraje de instalación.';
                  }
                  final kilometraje = int.tryParse(texto);
                  if (!RegExp(r'^[0-9]+$').hasMatch(texto) ||
                      kilometraje == null ||
                      kilometraje > widget.kilometraje) {
                    return 'Ingresa un entero entre 0 y ${widget.kilometraje}.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _guardar,
                child: const Text('Guardar llanta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
