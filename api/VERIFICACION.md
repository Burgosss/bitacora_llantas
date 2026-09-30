# Verificación de API — 2026-09-30

Rama: `feat/api-persistencia`, creada desde `main` actualizado (`72b992f`).

| Comprobación | Resultado |
| --- | --- |
| `npm --prefix api run build` | TypeScript compila sin errores |
| `npm --prefix api run test:local` | 8 resultados aprobados (7 escenarios HTTP y su prueba contenedora), 0 fallos |
| Reinicio de NestJS dentro de `test:local` | 2 vehículos con mismos IDs, campos y llantas después del reinicio |
| `docker compose config --quiet` | Configuración válida |
| `flutter analyze` | Sin problemas |
| `flutter test` | 10 pruebas aprobadas |
| Diff de `lib/`, `test/` y archivos pubspec | Sin cambios |

La prueba local inicia MongoDB **8.0.17 real**, almacenamiento WiredTiger y una API NestJS en un proceso separado. Entre otros casos valida 58000 → 65000, instalación a los 58000 (recorrido derivado: 7000), duplicados, posiciones independientes y solicitudes concurrentes.

Limitación: no fue posible ejecutar los contenedores. Docker Desktop se cerró al iniciar con el error `initializing Inference manager` / socket `dockerInference` (`The file cannot be accessed by the system`). No se restableció Docker ni se borraron sus datos. El Dockerfile y el volumen de Compose requieren verificación de ejecución con un motor operativo; la persistencia comprobada corresponde al reinicio real del proceso NestJS con MongoDB local.

Para repetir con Docker operativo: `docker compose up --build -d --wait`, `npm --prefix api test` y `npm --prefix api run test:persistencia`.

## Revisión del PR #6 y Docker en Linux

[GitHub Actions: ejecución aprobada](https://github.com/Burgosss/bitacora_llantas/actions/runs/36764711390), commit `55bce3c`: construcción y arranque de Compose, consulta HTTP, 7 escenarios de contrato/validación y persistencia tras reiniciar solo API. El script comprueba que cambió el inicio de API y que MongoDB no se reinició.

Las cuatro rutas, códigos HTTP, campos JSON y errores coinciden con api/README.md. Duplicados y posición ocupada: 409; kilometraje decreciente: 400. Se añadieron aserciones de estructura JSON. No se encontraron defectos funcionales en estos puntos. La ejecución inicial mostró un aviso de Node 20 en acciones auxiliares; se actualizaron a v5 (runtime Node 24).

El escaneo por patrones de claves privadas, tokens, contraseñas y URI con credenciales en todos los commits accesibles no encontró coincidencias. Tampoco hay archivos de claves o .env versionados. Esto no equivale a una garantía absoluta de ausencia de secretos.

Sigue sin probarse Docker Desktop en Windows, la recuperación después de reiniciar MongoDB o recrear contenedores y la integración Flutter/API (fuera del alcance). Flutter no cambió en esta revisión; no se repitieron sus pruebas, cuyos resultados anteriores figuran arriba.
