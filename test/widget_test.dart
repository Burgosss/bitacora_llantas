import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:bitacora_llantas/main.dart';

void main() {
  Future<void> abrirAlta(WidgetTester tester) async {
    await tester.pumpWidget(const BitacoraLlantasApp());
    await tester.tap(find.text('Agregar vehículo'));
    await tester.pumpAndSettle();
  }

  testWidgets('Guarda un vehículo normalizado y permite consultar su detalle', (
    tester,
  ) async {
    await abrirAlta(tester);
    final campos = find.byType(TextFormField);
    await tester.enterText(campos.at(0), '  Mi auto  ');
    await tester.enterText(campos.at(1), '  nueva-123  ');
    await tester.enterText(campos.at(2), '0');
    await tester.tap(find.text('Guardar vehículo'));
    await tester.pumpAndSettle();
    expect(find.text('Mi auto'), findsOneWidget);
    expect(find.text('Placa: NUEVA-123\n0 km'), findsOneWidget);
    expect(find.text('Auto familiar'), findsOneWidget);
    await tester.tap(find.text('Mi auto'));
    await tester.pumpAndSettle();
    expect(find.text('Placa: NUEVA-123'), findsOneWidget);
    expect(find.text('Kilometraje: 0 km'), findsOneWidget);
    expect(find.text('Sin llanta asignada'), findsNWidgets(4));
  });

  testWidgets('Valida campos vacíos, placas repetidas y kilometraje inválido', (
    tester,
  ) async {
    await abrirAlta(tester);
    await tester.tap(find.text('Guardar vehículo'));
    await tester.pumpAndSettle();
    expect(find.text('Ingresa un alias.'), findsOneWidget);
    expect(find.text('Ingresa una placa.'), findsOneWidget);
    expect(find.text('Ingresa el kilometraje.'), findsOneWidget);
    final campos = find.byType(TextFormField);
    await tester.enterText(campos.at(0), '   ');
    await tester.enterText(campos.at(1), '  abc-123-a  ');
    for (final invalido in [
      '-1',
      '1.5',
      'abc',
      '999999999999999999999999999999',
    ]) {
      await tester.enterText(campos.at(2), invalido);
      await tester.tap(find.text('Guardar vehículo'));
      await tester.pumpAndSettle();
      expect(find.text('Ingresa un alias.'), findsOneWidget);
      expect(
        find.text('Ya existe un vehículo con esta placa.'),
        findsOneWidget,
      );
      expect(
        find.text('Ingresa un kilometraje entero no negativo.'),
        findsOneWidget,
      );
    }
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(ListTile), findsNWidgets(2));
  });

  testWidgets('Lista vehículos y abre el detalle del vehículo seleccionado', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BitacoraLlantasApp());

    expect(find.text('Bitácora de llantas'), findsOneWidget);
    for (final vehiculo in vehiculosDeEjemplo) {
      expect(find.text(vehiculo.alias), findsOneWidget);
      expect(
        find.text('Placa: ${vehiculo.placa}\n${vehiculo.kilometraje} km'),
        findsOneWidget,
      );
    }

    for (final vehiculo in vehiculosDeEjemplo) {
      await tester.tap(find.text(vehiculo.alias));
      await tester.pumpAndSettle();

      expect(find.text(vehiculo.alias), findsOneWidget);
      expect(find.text('Placa: ${vehiculo.placa}'), findsOneWidget);
      expect(
        find.text('Kilometraje: ${vehiculo.kilometraje} km'),
        findsOneWidget,
      );
      expect(find.text('Delantera izquierda'), findsOneWidget);
      expect(find.text('Delantera derecha'), findsOneWidget);
      expect(find.text('Trasera izquierda'), findsOneWidget);
      expect(find.text('Trasera derecha'), findsOneWidget);
      expect(find.text('Sin llanta asignada'), findsNWidgets(4));

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Mis vehículos'), findsOneWidget);
    }
  });
}
