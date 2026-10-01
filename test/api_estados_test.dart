import 'dart:async';

import 'package:bitacora_llantas/main.dart';
import 'package:bitacora_llantas/models/vehiculo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_api.dart';

class ApiPendiente extends FakeApi {
  final respuesta = Completer<List<Vehiculo>>();
  @override
  Future<List<Vehiculo>> listar() => respuesta.future;
}

void main() {
  testWidgets('Carga, error y reintento sin datos de ejemplo', (tester) async {
    final api = ApiPendiente();
    await tester.pumpWidget(BitacoraLlantasApp(api: api));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Auto familiar'), findsNothing);
    api.respuesta.complete([]);
    await tester.pumpAndSettle();
    expect(
      find.text('Todavía no hay vehículos. Agrega el primero.'),
      findsOneWidget,
    );
    final falla = FakeApi([])..error = 'Sin conexión';
    await tester.pumpWidget(BitacoraLlantasApp(key: UniqueKey(), api: falla));
    await tester.pumpAndSettle();
    expect(find.text('Sin conexión'), findsOneWidget);
    expect(find.text('Auto familiar'), findsNothing);
    falla.error = null;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(
      find.text('Todavía no hay vehículos. Agrega el primero.'),
      findsOneWidget,
    );
  });

  testWidgets('Fallo al guardar conserva campos y permite reintentar', (
    tester,
  ) async {
    final api = FakeApi([]);
    await tester.pumpWidget(BitacoraLlantasApp(api: api));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Agregar vehículo'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Persistente');
    await tester.enterText(fields.at(1), 'API-1');
    await tester.enterText(fields.at(2), '58000');
    api.error = 'La API no responde';
    await tester.tap(find.text('Guardar vehículo'));
    await tester.pumpAndSettle();
    expect(find.text('La API no responde'), findsOneWidget);
    expect(find.text('Persistente'), findsOneWidget);
    expect(api.datos, isEmpty);
    api.error = null;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(find.text('Placa: API-1\n58000 km'), findsOneWidget);
    expect(api.datos.length, 1);
  });
}
