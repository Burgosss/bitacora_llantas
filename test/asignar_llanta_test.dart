import 'package:bitacora_llantas/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Asigna llantas, conserva posiciones al reabrir y aísla vehículos',
    (tester) async {
      await tester.pumpWidget(const BitacoraLlantasApp());
      await tester.tap(find.text('Auto familiar'));
      await tester.pumpAndSettle();
      final posiciones = [
        'Delantera izquierda',
        'Delantera derecha',
        'Trasera izquierda',
        'Trasera derecha',
      ];
      for (var i = 0; i < posiciones.length; i++) {
        await tester.ensureVisible(find.text(posiciones[i]));
        await tester.tap(find.text(posiciones[i]));
        await tester.pumpAndSettle();
        final campos = find.byType(TextFormField);
        await tester.enterText(campos.at(0), '  Marca $i  ');
        await tester.enterText(campos.at(1), ' Modelo $i ');
        await tester.enterText(campos.at(2), ' 205/55 R16 ');
        await tester.tap(find.text('Guardar llanta'));
        await tester.pumpAndSettle();
        expect(
          find.text(
            'Marca $i · Modelo $i\nMedida: 205/55 R16\nInstalada a los 45200 km',
          ),
          findsOneWidget,
        );
      }
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Auto familiar'));
      await tester.pumpAndSettle();
      expect(find.text('Sin llanta asignada'), findsNothing);
      await tester.tap(find.text('Delantera izquierda'));
      await tester.pumpAndSettle();
      expect(find.text('Asignar llanta'), findsNothing);
      expect(
        find.text(
          'Marca 0 · Modelo 0\nMedida: 205/55 R16\nInstalada a los 45200 km',
        ),
        findsOneWidget,
      );
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Camioneta de trabajo'));
      await tester.pumpAndSettle();
      expect(find.text('Sin llanta asignada'), findsNWidgets(4));
    },
  );

  testWidgets('Valida datos obligatorios y cancelar deja vacía la posición', (
    tester,
  ) async {
    await tester.pumpWidget(const BitacoraLlantasApp());
    await tester.tap(find.text('Auto familiar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delantera izquierda'));
    await tester.pumpAndSettle();
    for (final campo in find.byType(TextFormField).evaluate().toList()) {
      await tester.enterText(find.byWidget(campo.widget), '   ');
    }
    await tester.tap(find.text('Guardar llanta'));
    await tester.pumpAndSettle();
    expect(find.text('Ingresa la marca.'), findsOneWidget);
    expect(find.text('Ingresa el modelo.'), findsOneWidget);
    expect(find.text('Ingresa la medida.'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Sin llanta asignada'), findsNWidgets(4));
  });
}
