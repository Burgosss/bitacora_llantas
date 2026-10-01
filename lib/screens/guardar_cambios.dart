import 'package:flutter/material.dart';

import '../data/vehiculos_api.dart';
import '../models/vehiculo.dart';

/// Mantiene los campos y la ruta abiertos hasta que el servidor confirma.
class GuardarCambios extends StatefulWidget {
  const GuardarCambios({super.key, required this.label, required this.guardar});
  final String label;
  final Future<Vehiculo?> Function() guardar;
  @override
  State<GuardarCambios> createState() => _GuardarCambiosState();
}

class _GuardarCambiosState extends State<GuardarCambios> {
  bool _guardando = false;
  String? _error;
  Future<void> _guardar() async {
    if (_guardando) return;
    setState(() {
      _guardando = true;
      _error = null;
    });
    try {
      final resultado = await widget.guardar();
      if (!mounted) return;
      setState(() => _guardando = false);
      if (resultado != null) Navigator.of(context).pop(resultado);
    } catch (error) {
      if (mounted) {
        setState(() {
          _guardando = false;
          _error = error is ApiException
              ? error.message
              : 'No se pudo guardar. Reintenta.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_guardando,
    child: Column(
      children: [
        if (_error != null) Semantics(liveRegion: true, child: Text(_error!)),
        if (_guardando) const LinearProgressIndicator(),
        FilledButton(
          onPressed: _guardando ? null : _guardar,
          child: Text(_guardando ? 'Guardando…' : widget.label),
        ),
        if (_error != null)
          TextButton(onPressed: _guardar, child: const Text('Reintentar')),
      ],
    ),
  );
}
