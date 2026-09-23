# Bitácora de llantas

Aplicación Flutter para llevar el seguimiento de las llantas de cada vehículo.

## Implementado

- Dos vehículos de ejemplo con alias, placa y kilometraje.
- Alta de vehículos y actualización inmediata de la lista.
- Alias y placa obligatorios; espacios exteriores eliminados y placas en mayúsculas.
- Placas únicas (sin distinguir mayúsculas) y kilometraje entero no negativo.
- Detalle con cuatro posiciones: toca una vacía para asignar una llanta.
- Marca, modelo y medida obligatorios; kilometraje de instalación tomado del vehículo.
- Las asignaciones se conservan al navegar; las posiciones ocupadas muestran sus datos.
- Datos únicamente en memoria: al reiniciar la app se restablecen los ejemplos.

## Planeado, en este orden

1. Actualizar kilometraje y mostrar distancia recorrida.
2. Guardar datos entre sesiones.

## Ejecutar y verificar

Con Flutter instalado y un dispositivo disponible:

```sh
flutter pub get
flutter run
flutter analyze
flutter test
```

## Flujo de trabajo

- `main`: versión funcional con análisis y pruebas aprobados.
- Una rama por tarea: `feat/alta-vehiculos`, `fix/descripcion` o `docs/descripcion`.
- Commits pequeños con prefijos `feat:`, `fix:`, `docs:` o `test:`.
- Subir la rama y abrir un pull request hacia `main`, explicando cambios y pruebas.
- Revisar el diff y comprobar la función antes de unir el pull request.
- Antes de la siguiente rama, actualizar `main` con `git pull --ff-only origin main`.

## Estructura y navegación

`Vehiculo` es un modelo inmutable. La lista mantiene una copia mutable de los
vehículos en su `State`. El formulario usa `Form` y `TextFormField` para validar
los datos; al guardar devuelve un `Vehiculo` con `Navigator.pop`. La lista espera
el resultado, agrega el vehículo con `setState` y pasa ese mismo objeto al detalle
por su constructor. Cancelar el formulario no modifica la lista.

El formulario de llantas devuelve una Llanta al detalle. El detalle genera un
Vehiculo actualizado y notifica a la lista mediante un callback, por lo que la
asignación se conserva al reabrirlo. No se permite reemplazar una posición ocupada
en este incremento. La medida es texto obligatorio, sin validación de formato.
