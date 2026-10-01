# Bitácora de llantas

Flutter consulta una API NestJS/MongoDB para listar y crear vehículos, asignar llantas a cuatro posiciones y actualizar kilometraje. El recorrido es kilometraje actual menos kilometraje de instalación. Se conservan las validaciones. La lista muestra carga, vacío, error y reintento. No hay vehículos de ejemplo ni almacenamiento local de respaldo en la app.

## Dependencia del backend

Esta rama se creó desde `main` (`72b992f`). La API está en el [PR #6](https://github.com/Burgosss/bitacora_llantas/pull/6), todavía independiente de esta rama. Este PR debe integrarse después del #6; no incluye ni une sus commits. El contrato revisado está en [api/README.md del PR #6](https://github.com/Burgosss/bitacora_llantas/blob/feat/api-persistencia/api/README.md).

## Ejecutar en Android sin Docker (PowerShell)

Requisitos: Flutter, Node 22+, SDK Android y emulador iniciado. Desde `C:\Users\burgos\bitacora_llantas`, si la carpeta `api` del PR #6 ya está disponible:

```powershell
npm --prefix api ci
npm --prefix api run build
node tools/dev-api.cjs
```

El script inicia MongoDB **real 8.0.17** con WiredTiger y NestJS. Usa `.local/mongo` para conservar datos y el puerto local 27018 para MongoDB; no borra esa carpeta al terminar. Necesita descargar el binario oficial de MongoDB la primera vez. Detén los servicios con Ctrl+C. Es solo un servidor de desarrollo, sin autenticación.

Mientras el PR #6 no esté integrado, prepara su API sin cambiar la rama Flutter:

```powershell
git fetch origin
New-Item -ItemType Directory -Force .local/backend | Out-Null
git archive --format=tar --output=.local/api-pr6.tar origin/feat/api-persistencia api
tar -xf .local/api-pr6.tar -C .local/backend
npm --prefix .local/backend/api ci
npm --prefix .local/backend/api run build
$env:API_DIR = (Resolve-Path .local/backend/api).Path
node tools/dev-api.cjs
```

En otra terminal, inicia Flutter con el comando exacto para este emulador:

```powershell
flutter pub get
flutter run -d emulator-5554 --dart-define=API_URL=http://10.0.2.2:3000
```

`10.0.2.2` accede al host desde el emulador Android. Consulta `http://127.0.0.1:3000/vehiculos` desde Windows. Si funciona Docker, también puedes usar la API con Compose. La URL se configura al compilar, sin credenciales. Sin `API_URL`, la app muestra un error de configuración.

Android declara INTERNET en el manifiesto principal y rechaza HTTP por defecto. Solo `src/debug` permite HTTP a `10.0.2.2`, `127.0.0.1` y `localhost`. El cliente también rechaza HTTP fuera de debug. Release y profile requieren HTTPS; no se desactiva la validación de certificados. Este incremento se prueba en Android; no se habilitó CORS para Flutter web.

## Flujo y fuente de datos

1. Agrega un vehículo con 58000 km.
2. Asigna una llanta a la delantera izquierda a los 58000 km.
3. Actualiza a 65000 km: el detalle muestra 7000 km recorridos.
4. Cierra y abre Flutter: la lista se obtiene nuevamente desde MongoDB a través de la API.

`lib/data/vehiculos_api.dart` concentra las cuatro peticiones HTTP y convierte JSON a `Vehiculo` con ID y llantas. La lista mantiene una copia para mostrar. Los formularios llaman una función asíncrona, esperan confirmación y devuelven el vehículo recibido con `Navigator.pop`. El detalle usa ese resultado, informa a la lista y ambos se redibujan con `setState`. La lista identifica vehículos por ID. `GuardarCambios` impide doble envío y volver atrás durante el guardado, muestra progreso y conserva campos para reintentar. Si una respuesta se pierde después de guardar, vuelve a la lista y usa Actualizar lista para consultar el estado confirmado antes de repetir un alta.

## Verificaciones

```powershell
dart format lib test integration_test
flutter analyze
flutter test
```

Con los servicios activos, ejecuta las dos fases Android con la **misma placa**, nueva para cada ejecución completa:

```powershell
flutter test integration_test/api_flujo_test.dart -d emulator-5554 --dart-define=API_URL=http://10.0.2.2:3000 --dart-define=DEMO_PLACA=ANDROID-DEMO-UNICA
flutter test integration_test/api_flujo_test.dart -d emulator-5554 --dart-define=API_URL=http://10.0.2.2:3000 --dart-define=DEMO_PLACA=ANDROID-DEMO-UNICA --dart-define=VERIFICAR_REAPERTURA=true
```

Son dos ejecuciones separadas de la app: la primera crea, asigna y actualiza; la segunda solo consulta y comprueba los datos desde una instancia nueva. El vehículo queda en MongoDB para inspección. Las pruebas de widgets usan una API inyectada; los ejemplos existen únicamente en `test/fake_api.dart`.
