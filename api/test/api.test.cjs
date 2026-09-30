const { test } = require('node:test');
const assert = require('node:assert/strict');
const { randomUUID } = require('node:crypto');
const base = process.env.API_URL ?? 'http://127.0.0.1:3000';
async function request(method, path, body, status) {
  const res = await fetch(base + path, {
    method, headers: { 'Content-Type': 'application/json' },
    body: body === undefined ? undefined : JSON.stringify(body),
  });
  const data = await res.json();
  assert.equal(res.status, status, JSON.stringify(data));
  return data;
}

test('API con MongoDB real', async t => {
  const placa = `TEST-${randomUUID()}`;
  let vehiculo;
  await t.test('crea, normaliza, lista y rechaza duplicados', async () => {
    vehiculo = await request('POST', '/vehiculos', { alias: ' Auto test ', placa: ` ${placa.toLowerCase()} `, kilometraje: 58000 }, 201);
    assert.equal(vehiculo.alias, 'Auto test');
    assert.equal(vehiculo.placa, placa.toUpperCase());
    assert.deepEqual(vehiculo.llantas, {});
    assert.ok((await request('GET', '/vehiculos', undefined, 200)).some(v => v.id === vehiculo.id));
    await request('POST', '/vehiculos', { alias: 'Otro', placa, kilometraje: 0 }, 409);
  });
  const path = `/vehiculos/${vehiculo.id}`;
  await t.test('rechaza campos vacíos, tipos incorrectos y campos extra', async () => {
    for (const body of [
      {}, { alias: ' ', placa: 'P', kilometraje: 0 },
      { alias: 'A', placa: ' ', kilometraje: 0 },
      ...[-1, 1.5, '100', null, true, 1e20].map(kilometraje => ({ alias: 'A', placa: 'P', kilometraje })),
      { alias: 'A', placa: 'P', kilometraje: 0, llantas: {} },
    ]) await request('POST', '/vehiculos', body, 400);
  });
  await t.test('valida instalación, posición e identificador', async () => {
    for (const body of [
      {}, { marca: ' ', modelo: 'A', kilometrajeInstalacion: 0 },
      { marca: 'A', modelo: ' ', kilometrajeInstalacion: 0 },
      ...[-1, 58001, 1.2, '0', null].map(kilometrajeInstalacion => ({ marca: 'A', modelo: 'B', kilometrajeInstalacion })),
    ]) await request('POST', path + '/llantas/delanteraIzquierda', body, 400);
    const llanta = { marca: 'A', modelo: 'B', kilometrajeInstalacion: 0 };
    await request('POST', path + '/llantas/invalida', llanta, 400);
    await request('PATCH', '/vehiculos/no-id/kilometraje', { kilometraje: 1 }, 400);
    await request('PATCH', '/vehiculos/000000000000000000000000/kilometraje', { kilometraje: 1 }, 404);
    await request('POST', '/vehiculos/000000000000000000000000/llantas/traseraDerecha', llanta, 404);
  });
  await t.test('asigna cuatro posiciones independientes y no reemplaza', async () => {
    const posiciones = ['delanteraIzquierda', 'delanteraDerecha', 'traseraIzquierda', 'traseraDerecha'];
    for (const [i, posicion] of posiciones.entries()) {
      const v = await request('POST', path + '/llantas/' + posicion, {
        marca: ` Marca ${i} `, modelo: ` Modelo ${i} `, kilometrajeInstalacion: i === 0 ? 58000 : 0,
      }, 201);
      assert.equal(Object.keys(v.llantas).length, i + 1);
      assert.equal(v.llantas[posicion].marca, `Marca ${i}`);
    }
    await request('POST', path + '/llantas/delanteraIzquierda', { marca: 'Otra', modelo: 'Otro', kilometrajeInstalacion: 0 }, 409);
  });
  await t.test('58000 a 65000 conserva llantas y permite igualdad', async () => {
    for (const kilometraje of [-1, 57999, 65000.5, '65000', null]) {
      await request('PATCH', path + '/kilometraje', { kilometraje }, 400);
    }
    const v = await request('PATCH', path + '/kilometraje', { kilometraje: 65000 }, 200);
    assert.equal(v.kilometraje - v.llantas.delanteraIzquierda.kilometrajeInstalacion, 7000);
    assert.equal(Object.keys(v.llantas).length, 4);
    await request('PATCH', path + '/kilometraje', { kilometraje: 65000 }, 200);
    const guardado = (await request('GET', '/vehiculos', undefined, 200)).find(v => v.id === vehiculo.id);
    assert.deepEqual(guardado, v);
  });
  await t.test('asignaciones concurrentes no se sobrescriben y vehículos son independientes', async () => {
    const otro = await request('POST', '/vehiculos', { alias: 'Concurrencia', placa: `TEST-${randomUUID()}`, kilometraje: 0 }, 201);
    const url = `/vehiculos/${otro.id}/llantas/delanteraIzquierda`;
    const results = await Promise.all(['A', 'B'].map(marca => fetch(base + url, {
      method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ marca, modelo: 'M', kilometrajeInstalacion: 0 }),
    })));
    assert.deepEqual(results.map(r => r.status).sort(), [201, 409]);
    const listado = await request('GET', '/vehiculos', undefined, 200);
    assert.equal(Object.keys(listado.find(v => v.id === otro.id).llantas).length, 1);
    assert.equal(Object.keys(listado.find(v => v.id === vehiculo.id).llantas).length, 4);
  });
  await t.test('actualizaciones concurrentes nunca reducen el valor final', async () => {
    const results = await Promise.all([70000, 80000].map(kilometraje => fetch(base + path + '/kilometraje', {
      method: 'PATCH', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ kilometraje }),
    })));
    assert.ok(results.every(r => [200, 400].includes(r.status)));
    const final = (await request('GET', '/vehiculos', undefined, 200)).find(v => v.id === vehiculo.id);
    assert.equal(final.kilometraje, 80000);
  });
});
