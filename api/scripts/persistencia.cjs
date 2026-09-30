const assert = require('node:assert/strict');
const { randomUUID } = require('node:crypto');
const { execFileSync } = require('node:child_process');
const { resolve } = require('node:path');
const base = process.env.API_URL ?? 'http://127.0.0.1:3000';

async function main() {
  const res = await fetch(base + '/vehiculos', {
    method: 'POST', headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ alias: 'Prueba persistencia', placa: `PERSIST-${randomUUID()}`, kilometraje: 58000 }),
  });
  assert.equal(res.status, 201);
  const antes = await res.json();
  console.log('Creado antes del reinicio:', antes.id, antes.placa);
  execFileSync('docker', ['compose', 'restart', 'api'], { cwd: resolve(__dirname, '../..'), stdio: 'inherit' });
  const limite = Date.now() + 60000;
  while (Date.now() < limite) {
    try {
      const respuesta = await fetch(base + '/vehiculos', { signal: AbortSignal.timeout(3000) });
      if (respuesta.ok) {
        const despues = (await respuesta.json()).find(v => v.id === antes.id);
        assert.deepEqual(despues, antes);
        console.log('Persistencia verificada: mismo ID y contenido después de reiniciar API.');
        return;
      }
    } catch (error) {
      if (error.code === 'ERR_ASSERTION') throw error;
    }
    await new Promise(resolve => setTimeout(resolve, 1000));
  }
  throw new Error('La API no volvió a estar disponible en 60 segundos.');
}
main().catch(error => { console.error(error); process.exitCode = 1; });
