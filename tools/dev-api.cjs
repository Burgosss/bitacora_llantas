// Requiere la API del PR #6 compilada: npm --prefix api ci && npm --prefix api run build.
const { spawn } = require('node:child_process');
const { mkdirSync } = require('node:fs');
const { resolve } = require('node:path');
const apiDir = resolve(process.env.API_DIR || resolve(__dirname, '../api'));
const { MongoMemoryServer } = require(resolve(apiDir, 'node_modules/mongodb-memory-server'));

async function main() {
  const dbPath = resolve(__dirname, '../.local/mongo');
  mkdirSync(dbPath, { recursive: true });
  const mongo = await MongoMemoryServer.create({
    binary: { version: '8.0.17' },
    instance: { dbPath, port: 27018, ip: '127.0.0.1', storageEngine: 'wiredTiger' },
  });
  const api = spawn(process.execPath, [resolve(apiDir, 'dist/main.js')], {
    env: { ...process.env, MONGODB_URI: mongo.getUri('bitacora_llantas_dev'), PORT: '3000' },
    stdio: 'inherit', windowsHide: true,
  });
  let cerrando = false;
  async function cerrar() {
    if (cerrando) return;
    cerrando = true;
    api.kill();
    await mongo.stop({ doCleanup: false });
  }
  process.on('SIGINT', cerrar);
  process.on('SIGTERM', cerrar);
  api.on('exit', async code => { await cerrar(); process.exitCode = code || 0; });
  console.log(`MongoDB real en ${dbPath}; los datos se conservan al detener este script.`);
}
main().catch(error => { console.error(error); process.exitCode = 1; });
