# API de Bitácora de llantas

API mínima independiente en NestJS 11 y MongoDB. Flutter **todavía no está conectado**: sus datos siguen en memoria. La API empieza sin vehículos de ejemplo y guarda sus propios registros en MongoDB.

## Levantar los servicios

Requisitos: Docker Desktop iniciado con contenedores Linux y Docker Compose. Desde la raíz del repositorio:

```powershell
docker compose up --build -d --wait
docker compose ps
```

API: `http://127.0.0.1:3000`. MongoDB solo es accesible dentro de la red de Compose. El volumen `mongo-data` conserva los registros. La API espera a que MongoDB esté saludable y crea un índice único de placas antes de escuchar solicitudes.

```powershell
docker compose logs api
docker compose restart api
docker compose down
```

`down` conserva el volumen; `down -v` lo elimina junto con todos los datos. Para otro puerto, establece `$env:API_PORT='3001'` antes de levantar los servicios. Esta configuración es una demo local sin autenticación; solo publica el puerto en localhost y no está preparada para exposición pública.

## Endpoints

Todas las solicitudes y respuestas usan JSON. Los kilometrajes son números enteros no negativos, no cadenas. Por precisión de JavaScript se acepta hasta `9007199254740991` (MAX_SAFE_INTEGER). No se convierten tipos implícitamente y se rechazan campos no documentados.

| Método y ruta | Cuerpo | Resultado |
| --- | --- | --- |
| `GET /vehiculos` | Ninguno | `200`, arreglo de vehículos |
| `POST /vehiculos` | `alias`, `placa`, `kilometraje` | `201`, vehículo creado |
| `PATCH /vehiculos/:id/kilometraje` | `kilometraje` | `200`, vehículo actualizado |
| `POST /vehiculos/:id/llantas/:posicion` | `marca`, `modelo`, `kilometrajeInstalacion` | `201`, vehículo con la llanta asignada |

Las posiciones coinciden con el enum de Flutter: `delanteraIzquierda`, `delanteraDerecha`, `traseraIzquierda`, `traseraDerecha`.

Reglas:

- Alias, placa, marca y modelo son textos obligatorios; se eliminan espacios exteriores. Una cadena formada solo por espacios no es válida.
- Las placas se guardan en mayúsculas y no pueden repetirse, incluso con solicitudes concurrentes.
- Al actualizar kilometraje se permite igualdad, pero nunca disminuirlo.
- La instalación debe estar entre 0 y el kilometraje actual, inclusive.
- Solo se asignan posiciones vacías. Las cuatro posiciones y los vehículos son independientes; no hay edición ni retiro de llantas.
- Cada actualización se realiza atómicamente en MongoDB con sus condiciones. No se reemplaza el mapa completo al asignar una llanta.

Respuesta de ejemplo:

```json
{
  "id": "507f1f77bcf86cd799439011",
  "alias": "Auto demo",
  "placa": "DEMO-123",
  "kilometraje": 65000,
  "llantas": {
    "delanteraIzquierda": {
      "marca": "Marca demo",
      "modelo": "Modelo A",
      "kilometrajeInstalacion": 58000
    }
  }
}
```

Una posición vacía no aparece en `llantas`; al crear un vehículo el mapa es `{}`. El recorrido se deriva restando instalación a kilometraje actual (en el ejemplo, 7000 km); no se almacena como otro campo.

Errores: `400` para cuerpo, ID o posición inválidos, kilometraje decreciente o instalación superior al actual; `404` para ID válido inexistente; `409` para placa duplicada o posición ocupada. Nest devuelve JSON con `statusCode`, `message` y `error` en estos casos; `message` puede ser un arreglo de errores de validación.

## Ejemplo en PowerShell

Con los servicios activos:

```powershell
$base = 'http://127.0.0.1:3000'
$vehiculo = Invoke-RestMethod -Method Post -Uri "$base/vehiculos" -ContentType 'application/json' -Body '{"alias":"Auto demo","placa":"DEMO-123","kilometraje":58000}'
Invoke-RestMethod -Method Post -Uri "$base/vehiculos/$($vehiculo.id)/llantas/delanteraIzquierda" -ContentType 'application/json' -Body '{"marca":"Marca demo","modelo":"Modelo A","kilometrajeInstalacion":58000}'
Invoke-RestMethod -Method Patch -Uri "$base/vehiculos/$($vehiculo.id)/kilometraje" -ContentType 'application/json' -Body '{"kilometraje":65000}'
Invoke-RestMethod -Uri "$base/vehiculos"
```

Cambia la placa si repites el ejemplo, porque la primera ya estará guardada.

## Compilar y probar

Para las herramientas locales usa Node.js 22 o superior. Desde la raíz, después de levantar Compose:

```powershell
npm --prefix api ci
npm --prefix api run build
npm --prefix api test
npm --prefix api run test:persistencia
```

`npm test` realiza solicitudes HTTP contra la API y MongoDB reales: valida campos/tipos, duplicados, límites, posiciones, concurrencia, IDs y el cambio 58000 → 65000. No usa un sustituto de MongoDB. Las pruebas crean vehículos con placas únicas `TEST-...` y `PERSIST-...`; los dejan guardados para inspección. No borran datos existentes.

La prueba de persistencia crea un registro, ejecuta `docker compose restart api`, espera su regreso y comprueba que el mismo ID y todos sus campos siguen en `GET /vehiculos`. Requiere Docker CLI y la API de este Compose. Si cambias el puerto, establece también `$env:API_URL='http://127.0.0.1:3001'` para los scripts.

Para ejecutar Nest fuera de Docker con una instancia MongoDB accesible, configura `MONGODB_URI` (incluyendo nombre de base de datos) y ejecuta `npm --prefix api start` tras compilar. Compose ya configura esa variable para el contenedor.

### Prueba local independiente de Docker

```powershell
npm --prefix api run test:local
```

Esta alternativa compila TypeScript, descarga/inicia un **mongod 8.0.17 real** con WiredTiger en una carpeta temporal e inicia NestJS como proceso separado. Ejecuta las mismas pruebas HTTP, detiene y vuelve a iniciar únicamente NestJS, y compara todos los vehículos, IDs y llantas antes/después. Al terminar cierra ambos procesos y elimina solo la carpeta temporal que creó. No modifica datos de Compose. La primera ejecución necesita acceso a la descarga oficial de MongoDB.

En la verificación de este PR, Docker Desktop falló durante su inicio con un error del socket local `dockerInference`. Se validó `docker compose config --quiet`; la prueba local permite verificar la API y el reinicio real sin simular MongoDB. La ejecución con Docker Compose y la persistencia tras reiniciar solo la API ya se comprobaron en GitHub Actions sobre Linux; consulta VERIFICACION.md. Docker Desktop en Windows sigue sin comprobarse.

## Archivos

### GitHub Actions

El workflow `API Docker Compose` (`.github/workflows/api-compose.yml`) corre en Ubuntu para cada pull request hacia `main`. Construye y levanta los servicios con Docker Compose, consulta `GET /vehiculos`, ejecuta las pruebas HTTP y crea un vehículo para verificar su persistencia después de reiniciar solo la API. También comprueba que MongoDB no se reinició. Los logs se muestran incluso si falla; al terminar se eliminan únicamente los servicios y el volumen del runner temporal. No requiere secretos ni Docker Desktop en Windows.

- `src/vehiculos.dto.ts`: validación y normalización de entrada.
- `src/vehiculos.service.ts`: conexión, índice único y operaciones atómicas.
- `src/app.module.ts`: rutas HTTP y registro de dependencias.
- `src/main.ts`: arranque, validación global y cierre de conexiones.
- `../compose.yaml`: API, MongoDB, salud y volumen persistente.

Referencias: [validación de NestJS](https://docs.nestjs.com/techniques/validation), [orden de arranque de Compose](https://docs.docker.com/compose/how-tos/startup-order/).
