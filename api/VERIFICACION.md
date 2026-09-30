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
