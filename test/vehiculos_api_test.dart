import 'dart:convert';

import 'package:bitacora_llantas/data/vehiculos_api.dart';
import 'package:bitacora_llantas/models/vehiculo.dart';
import 'package:bitacora_llantas/models/llanta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('Contrato HTTP: rutas, cuerpos, id y llantas', () async {
    final requests = <http.Request>[];
    final json = {
      'id': 'abc',
      'alias': 'Auto',
      'placa': 'A',
      'kilometraje': 65000,
      'llantas': {
        'delanteraIzquierda': {
          'marca': 'M',
          'modelo': 'X',
          'kilometrajeInstalacion': 58000,
        },
      },
    };
    final api = VehiculosApi(
      baseUrl: 'http://localhost:3000',
      client: MockClient((r) async {
        requests.add(r);
        return http.Response(
          jsonEncode(r.method == 'GET' ? [json] : json),
          200,
        );
      }),
    );
    final listado = await api.listar();
    expect(listado.single.id, 'abc');
    expect(
      listado
          .single
          .llantas[PosicionLlanta.delanteraIzquierda]!
          .kilometrajeInstalacion,
      58000,
    );
    await api.crear(
      const Vehiculo(alias: 'Auto', placa: 'A', kilometraje: 58000),
    );
    await api.actualizarKilometraje('abc', 65000);
    await api.asignar(
      'abc',
      PosicionLlanta.delanteraIzquierda,
      const Llanta(marca: 'M', modelo: 'X', kilometrajeInstalacion: 58000),
    );
    expect(requests.map((r) => '${r.method} ${r.url.path}'), [
      'GET /vehiculos',
      'POST /vehiculos',
      'PATCH /vehiculos/abc/kilometraje',
      'POST /vehiculos/abc/llantas/delanteraIzquierda',
    ]);
    expect(jsonDecode(requests[1].body), {
      'alias': 'Auto',
      'placa': 'A',
      'kilometraje': 58000,
    });
    expect(jsonDecode(requests[2].body), {'kilometraje': 65000});
    expect(jsonDecode(requests[3].body), {
      'marca': 'M',
      'modelo': 'X',
      'kilometrajeInstalacion': 58000,
    });
    api.close();
  });
  test(
    'Propaga errores de Nest y de conexión sin inventar resultados',
    () async {
      for (final status in [400, 409]) {
        final api = VehiculosApi(
          baseUrl: 'http://localhost',
          client: MockClient(
            (r) async => http.Response(
              jsonEncode({
                'message': ['Rechazado'],
              }),
              status,
            ),
          ),
        );
        await expectLater(
          api.listar(),
          throwsA(
            isA<ApiException>().having(
              (e) => e.message,
              'message',
              'Rechazado',
            ),
          ),
        );
        api.close();
      }
      final api = VehiculosApi(
        baseUrl: 'http://localhost',
        client: MockClient((r) async => throw http.ClientException('offline')),
      );
      await expectLater(api.listar(), throwsA(isA<ApiException>()));
      api.close();
    },
  );
}
