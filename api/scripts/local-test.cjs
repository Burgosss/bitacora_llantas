// MongoDB real (mongod), no sustitutos de la colección ni del servidor HTTP.
const { MongoMemoryServer } = require('mongodb-memory-server');
const { spawn } = require('node:child_process');
const { once } = require('node:events');
const { mkdtemp, rm } = require('node:fs/promises');
const { tmpdir } = require('node:os');
const { join, resolve, dirname, basename } = require('node:path');
const assert = require('node:assert/strict');
const net = require('node:net');

async function freePort() {
  const server = net.createServer();
  server.listen(0, '127.0.0.1');
  await once(server, 'listening');
  const port = server.address().port;
  await new Promise(resolve => server.close(resolve));
  return port;
}
async function stop(child) {
  if (!child || child.exitCode !== null || child.signalCode !== null) return;
  const closed = once(child, 'exit');
  child.kill();
  await closed;
}
async function main() {
  const dbPath = await mkdtemp(join(tmpdir(), 'bitacora-api-test-'));
  let mongo, api;
  try {
    mongo = await MongoMemoryServer.create({
      binary: { version: '8.0.17' },
      instance: { dbPath, storageEngine: 'wiredTiger' },
    });
    const port = await freePort();
    const base = `http://127.0.0.1:${port}`;
    const start = async () => {
      api = spawn(process.execPath, ['dist/main.js'], {
        cwd: resolve(__dirname, '..'), stdio: ['ignore', 'ignore', 'inherit'],
        env: { ...process.env, PORT: String(port), MONGODB_URI: mongo.getUri('bitacora_test') },
      });
      for (let attempt = 0; attempt < 100; attempt++) {
        if (api.exitCode !== null) throw new Error('La API terminó antes de iniciar.');
        try { if ((await fetch(base + '/vehiculos')).ok) return; } catch {}
        await new Promise(resolve => setTimeout(resolve, 200));
      }
      throw new Error('La API no inició en 20 segundos.');
    };
    await start();
    const tests = spawn(process.execPath, ['--test', 'test/api.test.cjs'], {
      cwd: resolve(__dirname, '..'), stdio: 'inherit', env: { ...process.env, API_URL: base },
    });
    const [code] = await once(tests, 'exit');
    assert.equal(code, 0, 'Fallaron las pruebas HTTP.');
    const antes = await (await fetch(base + '/vehiculos')).json();
    assert.ok(antes.length >= 2);
    // Reinicia NestJS; mongod y su almacenamiento WiredTiger permanecen activos.
    await stop(api);
    await start();
    const despues = await (await fetch(base + '/vehiculos')).json();
    assert.deepEqual(despues, antes);
    console.log(`PERSISTENCIA OK: ${antes.length} vehículos, llantas e IDs idénticos tras reiniciar NestJS.`);
  } finally {
    await stop(api);
    await mongo?.stop();
    // Solo el directorio temporal creado por esta ejecución, nunca datos de Compose.
    const target = resolve(dbPath);
    assert.equal(dirname(target), resolve(tmpdir()));
    assert.ok(basename(target).startsWith('bitacora-api-test-'));
    await rm(target, { recursive: true, force: true });
  }
}
main().catch(error => { console.error(error); process.exitCode = 1; });
