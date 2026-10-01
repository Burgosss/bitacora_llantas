# Verificación Flutter/API — 2026-09-30

Rama `feat/conectar-flutter-api`, creada desde `main` actualizado (`72b992f`). El backend probado corresponde al PR #6 (`a0ba1c1`), que aún no estaba integrado en main. No se modificó el backend.

| Verificación | Resultado |
| --- | --- |
| `dart format lib test integration_test` | Correcto |
| `flutter analyze` | No issues found |
| `flutter test` | 14 pruebas aprobadas |
| Android: alta, asignación y actualización | Prueba de integración aprobada |
| Cerrar proceso y volver a ejecutar Flutter | Prueba de reapertura aprobada |
| `:app:processReleaseMainManifest` | BUILD SUCCESSFUL |
| `git diff --check` | Sin errores |

Emulador `emulator-5554`: Android 16/API 36, x86_64. NestJS en Windows en puerto 3000 y MongoDB real 8.0.17/WiredTiger en puerto 27018, con datos en `.local/mongo`; Docker Desktop no intervino. El cliente Android usó `http://10.0.2.2:3000`.

Primera ejecución de `integration_test/api_flujo_test.dart`: placa `ANDROID-20260930-API`, alta a 58000 km, llanta Michelin/Primacy delantera izquierda instalada a 58000, actualización a 65000 y recorrido visible de 7000. Las otras tres posiciones permanecieron vacías. Lista y detalle mostraron 65000.

Se cerró el proceso con `adb -s emulator-5554 shell am force-stop com.example.bitacora_llantas` y se ejecutó de nuevo la prueba con `--dart-define=VERIFICAR_REAPERTURA=true`. Esta segunda fase no crea ni modifica vehículos: una nueva instancia de Flutter consulta la API y comprueba los mismos datos. Ambas fases terminaron con `All tests passed!`.

Consulta independiente a `GET http://127.0.0.1:3000/vehiculos`: ID `6abd63abc9dd0c88841eb11d`, placa `ANDROID-20260930-API`, 65000 km, instalación 58000. Este vehículo se dejó guardado para inspección.

Los tests de widgets cubren validaciones existentes, carga, vacío, error sin ejemplos, reintento y conservación de campos si falla el guardado. Los tests del cliente comprueban métodos, rutas, cuerpos, deserialización y errores 400/409/conexión. Los manifiestos debug y release fueron generados: INTERNET en ambos; configuración de HTTP local solo en debug, usesCleartextTraffic=false en release. Gradle emitió avisos de deprecación Java/Kotlin ya presentes en el entorno, sin impedir las pruebas.

No se probaron un servidor HTTPS de producción, iOS, Flutter web, ni recuperación después de una caída completa de MongoDB. No se corrigió Docker Desktop. La prueba de persistencia solicitada cubre cerrar y reabrir Flutter contra NestJS y MongoDB que continúan ejecutándose.
