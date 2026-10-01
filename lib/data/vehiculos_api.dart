import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/llanta.dart';
import '../models/vehiculo.dart';

class ApiException implements Exception {
  const ApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

class VehiculosApi {
  VehiculosApi({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? const String.fromEnvironment('API_URL');

  final http.Client _client;
  final String _baseUrl;

  Future<dynamic> _request(String method, String path, [Object? body]) async {
    final base = Uri.tryParse(_baseUrl);
    if (base == null ||
        !base.hasAuthority ||
        !['http', 'https'].contains(base.scheme)) {
      throw const ApiException(
        'Configura API_URL para conectar con el servidor.',
      );
    }
    if (base.scheme == 'http' &&
        (!kDebugMode ||
            !['10.0.2.2', '127.0.0.1', 'localhost'].contains(base.host))) {
      throw const ApiException(
        'Usa HTTPS; HTTP local solo está permitido en desarrollo.',
      );
    }
    final uri = Uri.parse('${_baseUrl.replaceAll(RegExp(r"/+$"), "")}$path');
    try {
      final request = http.Request(method, uri);
      request.headers['Content-Type'] = 'application/json';
      if (body != null) request.body = jsonEncode(body);
      final response = await (() async {
        return http.Response.fromStream(await _client.send(request));
      })().timeout(const Duration(seconds: 10));
      final dynamic data = jsonDecode(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final message = data is Map ? data['message'] : null;
        throw ApiException(
          message is List
              ? message.join('\n')
              : message is String
              ? message
              : 'El servidor rechazó la operación.',
        );
      }
      return data;
    } on TimeoutException {
      throw const ApiException(
        'La API no respondió a tiempo. Reintenta la operación.',
      );
    } on http.ClientException {
      throw const ApiException(
        'No se pudo conectar con la API. Revisa la conexión y reintenta.',
      );
    } on FormatException {
      throw const ApiException('La API devolvió una respuesta inválida.');
    }
  }

  Future<List<Vehiculo>> listar() async =>
      (await _request('GET', '/vehiculos') as List)
          .map((v) => Vehiculo.fromJson(v as Map<String, dynamic>))
          .toList();

  Future<Vehiculo> crear(Vehiculo v) async => Vehiculo.fromJson(
    await _request('POST', '/vehiculos', {
      'alias': v.alias,
      'placa': v.placa,
      'kilometraje': v.kilometraje,
    }) as Map<String, dynamic>,
  );

  Future<Vehiculo> actualizarKilometraje(String id, int kilometraje) async =>
      Vehiculo.fromJson(
        await _request(
          'PATCH',
          '/vehiculos/${Uri.encodeComponent(id)}/kilometraje',
          {'kilometraje': kilometraje},
        ) as Map<String, dynamic>,
      );

  Future<Vehiculo> asignar(
    String id,
    PosicionLlanta posicion,
    Llanta llanta,
  ) async => Vehiculo.fromJson(
    await _request(
      'POST',
      '/vehiculos/${Uri.encodeComponent(id)}/llantas/${posicion.name}',
      {
        'marca': llanta.marca,
        'modelo': llanta.modelo,
        'kilometrajeInstalacion': llanta.kilometrajeInstalacion,
      },
    ) as Map<String, dynamic>,
  );

  void close() => _client.close();
}
