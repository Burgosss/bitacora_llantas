import 'package:bitacora_llantas/data/vehiculos_api.dart';
import 'package:bitacora_llantas/models/vehiculo.dart';
import 'package:bitacora_llantas/models/llanta.dart';

const vehiculosDeEjemplo = [
  Vehiculo(
    id: 'uno',
    alias: 'Auto familiar',
    placa: 'ABC-123-A',
    kilometraje: 45200,
  ),
  Vehiculo(
    id: 'dos',
    alias: 'Camioneta de trabajo',
    placa: 'XYZ-789-B',
    kilometraje: 87350,
  ),
];

class FakeApi extends VehiculosApi {
  FakeApi([List<Vehiculo> iniciales = vehiculosDeEjemplo])
    : datos = List.of(iniciales);
  final List<Vehiculo> datos;
  String? error;
  @override
  Future<List<Vehiculo>> listar() async {
    if (error != null) throw ApiException(error!);
    return List.of(datos);
  }

  @override
  Future<Vehiculo> crear(Vehiculo v) async {
    if (error != null) throw ApiException(error!);
    final nuevo = Vehiculo(
      id: '${datos.length}',
      alias: v.alias,
      placa: v.placa,
      kilometraje: v.kilometraje,
    );
    datos.add(nuevo);
    return nuevo;
  }

  @override
  Future<Vehiculo> actualizarKilometraje(String id, int kilometraje) async {
    if (error != null) throw ApiException(error!);
    final i = datos.indexWhere((v) => v.id == id);
    return datos[i] = datos[i].actualizarKilometraje(kilometraje);
  }

  @override
  Future<Vehiculo> asignar(
    String id,
    PosicionLlanta posicion,
    Llanta llanta,
  ) async {
    if (error != null) throw ApiException(error!);
    final i = datos.indexWhere((v) => v.id == id);
    return datos[i] = datos[i].asignarLlanta(posicion, llanta);
  }
}
