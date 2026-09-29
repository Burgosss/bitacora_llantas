import 'llanta.dart';

class Vehiculo {
  const Vehiculo({
    required this.alias,
    required this.placa,
    required this.kilometraje,
    this.llantas = const {},
  });

  final String alias;
  final String placa;
  final int kilometraje;
  final Map<PosicionLlanta, Llanta> llantas;

  Vehiculo actualizarKilometraje(int nuevoKilometraje) {
    if (nuevoKilometraje < 0 || nuevoKilometraje < kilometraje) {
      throw ArgumentError('El kilometraje no puede disminuir.');
    }
    return Vehiculo(
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
      alias: alias,
      placa: placa,
      kilometraje: kilometraje,
      llantas: Map.unmodifiable({...llantas, posicion: llanta}),
    );
  }
}
