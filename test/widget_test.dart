import 'package:flutter_test/flutter_test.dart';

import 'package:bitacora_llantas/main.dart';

void main() {
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
