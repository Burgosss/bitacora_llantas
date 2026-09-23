enum PosicionLlanta {
  delanteraIzquierda('Delantera izquierda'),
  delanteraDerecha('Delantera derecha'),
  traseraIzquierda('Trasera izquierda'),
  traseraDerecha('Trasera derecha');

  const PosicionLlanta(this.etiqueta);
  final String etiqueta;
}

class Llanta {
  const Llanta({
    required this.marca,
    required this.modelo,
    required this.medida,
    required this.kilometrajeInstalacion,
  });

  final String marca;
  final String modelo;
  final String medida;
  final int kilometrajeInstalacion;
}
