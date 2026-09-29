import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bitacora_llantas/models/vehiculo.dart';
import 'package:bitacora_llantas/models/llanta.dart';
import 'package:bitacora_llantas/screens/vehiculos_screen.dart';

const vehiculo = Vehiculo(
  alias: 'Prueba',
  placa: 'ABC',
  kilometraje: 58000,
  llantas: {
    PosicionLlanta.delanteraIzquierda: Llanta(
      marca: 'Marca A',
      modelo: 'A',
      kilometrajeInstalacion: 58000,
    ),
    PosicionLlanta.delanteraDerecha: Llanta(
      marca: 'Marca B',
      modelo: 'B',
      kilometrajeInstalacion: 50000,
    ),
  },
);

void main() {
  Future<void> abrir(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: VehiculosScreen(vehiculos: [vehiculo])),
    );
    await tester.tap(find.text('Prueba'));
    await tester.pumpAndSettle();
  }

  testWidgets('De 58000 a 65000 recalcula llantas y conserva lista y detalle', (
    tester,
  ) async {
    await abrir(tester);
    expect(find.text('Recorridos: 0 km'), findsOneWidget);
    expect(find.text('Recorridos: 8000 km'), findsOneWidget);
    await tester.tap(find.text('Actualizar kilometraje'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '65000');
    await tester.tap(find.text('Guardar kilometraje'));
    await tester.pumpAndSettle();
    expect(find.text('Kilometraje: 65000 km'), findsOneWidget);
    expect(find.text('Recorridos: 7000 km'), findsOneWidget);
    expect(find.text('Recorridos: 15000 km'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Placa: ABC\n65000 km'), findsOneWidget);
    await tester.tap(find.text('Prueba'));
    await tester.pumpAndSettle();
    expect(find.text('Kilometraje: 65000 km'), findsOneWidget);
    expect(find.text('Recorridos: 7000 km'), findsOneWidget);
    expect(find.text('Recorridos: 15000 km'), findsOneWidget);
  });

  testWidgets(
    'Rechaza valores inválidos, cancelar conserva dato y admite igualdad',
    (tester) async {
      await abrir(tester);
      await tester.tap(find.text('Actualizar kilometraje'));
      await tester.pumpAndSettle();
      for (final valor in ['', '-1', '1.5', 'abc', '57999']) {
        await tester.enterText(find.byType(TextFormField), valor);
        await tester.tap(find.text('Guardar kilometraje'));
        await tester.pumpAndSettle();
        expect(find.byType(TextFormField), findsOneWidget);
        expect(
          find.text(
            valor.isEmpty
                ? 'Ingresa el kilometraje.'
                : valor == '57999'
                ? 'El kilometraje no puede ser menor a 58000 km.'
                : 'Ingresa un entero no negativo.',
          ),
          findsOneWidget,
        );
      }
      await tester.enterText(find.byType(TextFormField), '65000');
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Kilometraje: 58000 km'), findsOneWidget);
      await tester.tap(find.text('Actualizar kilometraje'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), '58000');
      await tester.tap(find.text('Guardar kilometraje'));
      await tester.pumpAndSettle();
      expect(find.byType(TextFormField), findsNothing);
      expect(find.text('Kilometraje: 58000 km'), findsOneWidget);
    },
  );
}
