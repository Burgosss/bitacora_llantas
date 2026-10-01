import 'llanta.dart';

class Vehiculo {
  const Vehiculo({
    this.id = '',
    required this.alias,
    required this.placa,
    required this.kilometraje,
    this.llantas = const {},
  });

  final String alias;
  final String id;

  factory Vehiculo.fromJson(Map<String, dynamic> json) => Vehiculo(
    id: json['id'] as String,
    alias: json['alias'] as String,
    placa: json['placa'] as String,
    kilometraje: json['kilometraje'] as int,
    llantas: Map.unmodifiable(
      (json['llantas'] as Map<String, dynamic>).map(
        (posicion, valor) => MapEntry(
          PosicionLlanta.values.byName(posicion),
          Llanta(
            marca: valor['marca'] as String,
            modelo: valor['modelo'] as String,
            kilometrajeInstalacion: valor['kilometrajeInstalacion'] as int,
          ),
        ),
      ),
    ),
  );
  final String placa;
  final int kilometraje;
  final Map<PosicionLlanta, Llanta> llantas;

  Vehiculo actualizarKilometraje(int nuevoKilometraje) {
    if (nuevoKilometraje < 0 || nuevoKilometraje < kilometraje) {
      throw ArgumentError('El kilometraje no puede disminuir.');
    }
    return Vehiculo(
      id: id,
      alias: alias,
      placa: placa,
      kilometraje: nuevoKilometraje,
      llantas: llantas,
    );
  }

  Vehiculo asignarLlanta(PosicionLlanta posicion, Llanta llanta) {
    if (llantas.containsKey(posicion)) {
      throw StateError('La posición ya tiene una llanta asignada.');
    }
    return Vehiculo(
      id: id,
      alias: alias,
      placa: placa,
      kilometraje: kilometraje,
      llantas: Map.unmodifiable({...llantas, posicion: llanta}),
    );
  }
}
