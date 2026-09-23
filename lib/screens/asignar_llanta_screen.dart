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
  final _medida = TextEditingController();

  @override
  void dispose() {
    _marca.dispose();
    _modelo.dispose();
    _medida.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      Llanta(
        marca: _marca.text.trim(),
        modelo: _modelo.text.trim(),
        medida: _medida.text.trim(),
        kilometrajeInstalacion: widget.kilometraje,
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
              Text('Kilometraje de instalación: ${widget.kilometraje} km'),
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
                controller: _medida,
                decoration: const InputDecoration(
                  labelText: 'Medida',
                  hintText: 'Ejemplo: 205/55 R16',
                ),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _guardar(),
                validator: (value) =>
                    (value ?? '').trim().isEmpty ? 'Ingresa la medida.' : null,
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
