import 'package:bitacora_llantas/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const placa = String.fromEnvironment(
    'DEMO_PLACA',
    defaultValue: 'ANDROID-DEMO',
  );
  const verificar = bool.fromEnvironment('VERIFICAR_REAPERTURA');
  testWidgets(
    verificar
        ? 'Reapertura conserva vehículo y llanta en MongoDB'
        : 'Alta, llanta y kilometraje contra API real',
    (tester) async {
      await tester.pumpWidget(const BitacoraLlantasApp());
      Future<void> esperar(Finder finder) async {
        for (var i = 0; i < 100 && finder.evaluate().isEmpty; i++) {
          await tester.pump(const Duration(milliseconds: 200));
        }
        expect(finder, findsOneWidget);
        await tester.pumpAndSettle();
      }

      await esperar(find.text('Mis vehículos'));
      for (
        var i = 0;
        i < 100 && find.byType(CircularProgressIndicator).evaluate().isNotEmpty;
        i++
      ) {
        await tester.pump(const Duration(milliseconds: 200));
      }
      if (!verificar) {
        await tester.tap(find.text('Agregar vehículo'));
        await tester.pumpAndSettle();
        final campos = find.byType(TextFormField);
        await tester.enterText(campos.at(0), placa);
        await tester.enterText(campos.at(1), placa);
        await tester.enterText(campos.at(2), '58000');
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
        await tester.tap(find.text('Guardar vehículo'));
        await esperar(find.text('Mis vehículos'));
      }
      await tester.tap(find.text(placa));
      await tester.pumpAndSettle();
      if (!verificar) {
        await tester.tap(find.text('Delantera izquierda'));
        await tester.pumpAndSettle();
        final campos = find.byType(TextFormField);
        await tester.enterText(campos.at(0), 'Michelin');
        await tester.enterText(campos.at(1), 'Primacy');
        await tester.enterText(campos.at(2), '58000');
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
        await tester.tap(find.text('Guardar llanta'));
        await esperar(find.text('Posiciones de llantas'));
        await tester.tap(find.text('Actualizar kilometraje'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextFormField), '65000');
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
        await tester.tap(find.text('Guardar kilometraje'));
        await esperar(find.text('Posiciones de llantas'));
      }
      expect(find.text('Kilometraje: 65000 km'), findsOneWidget);
      expect(find.text('Recorridos: 7000 km'), findsOneWidget);
      expect(
        find.text('Michelin · Primacy\nInstalada a los 58000 km'),
        findsOneWidget,
      );
      expect(find.text('Sin llanta asignada'), findsNWidgets(3));
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Placa: $placa\n65000 km'), findsOneWidget);
    },
  );
}
