import {
  BadRequestException, ConflictException, Injectable, NotFoundException,
  OnModuleDestroy, OnModuleInit,
} from '@nestjs/common';
import { Collection, MongoClient, MongoServerError, ObjectId } from 'mongodb';
import { AsignarLlantaDto, CrearVehiculoDto } from './vehiculos.dto';

export const posiciones = [
  'delanteraIzquierda', 'delanteraDerecha', 'traseraIzquierda', 'traseraDerecha',
] as const;
type Posicion = typeof posiciones[number];
interface Vehiculo {
  _id: ObjectId;
  alias: string;
  placa: string;
  kilometraje: number;
  llantas: Partial<Record<Posicion, AsignarLlantaDto>>;
}

@Injectable()
export class VehiculosService implements OnModuleInit, OnModuleDestroy {
  private client!: MongoClient;
  private vehiculos!: Collection<Vehiculo>;

  async onModuleInit() {
    if (!process.env.MONGODB_URI) throw new Error('Falta MONGODB_URI');
    this.client = new MongoClient(process.env.MONGODB_URI, { serverSelectionTimeoutMS: 10000 });
    try {
      await this.client.connect();
      this.vehiculos = this.client.db().collection<Vehiculo>('vehiculos');
      await this.vehiculos.createIndex({ placa: 1 }, { unique: true });
    } catch (error) {
      await this.client.close();
      throw error;
    }
  }

  async onModuleDestroy() { await this.client?.close(); }

  private id(value: string) {
    if (!/^[a-fA-F0-9]{24}$/.test(value)) throw new BadRequestException('ID inválido.');
    return new ObjectId(value);
  }

  private respuesta(vehiculo: Vehiculo) {
    const { _id, ...datos } = vehiculo;
    return { id: _id.toHexString(), ...datos };
  }

  async listar() {
    return (await this.vehiculos.find().sort({ _id: 1 }).toArray()).map(v => this.respuesta(v));
  }

  async crear(dto: CrearVehiculoDto) {
    const vehiculo: Vehiculo = { _id: new ObjectId(), ...dto, llantas: {} };
    try {
      await this.vehiculos.insertOne(vehiculo);
    } catch (error) {
      if (error instanceof MongoServerError && error.code === 11000) {
        throw new ConflictException('Ya existe un vehículo con esta placa.');
      }
      throw error;
    }
    return this.respuesta(vehiculo);
  }

  async actualizarKilometraje(id: string, kilometraje: number) {
    const _id = this.id(id);
    // La condición y el cambio ocurren juntos: nunca se puede retroceder.
    const actualizado = await this.vehiculos.findOneAndUpdate(
      { _id, kilometraje: { $lte: kilometraje } },
      { $set: { kilometraje } }, { returnDocument: 'after' },
    );
    if (actualizado) return this.respuesta(actualizado);
    if (!await this.vehiculos.findOne({ _id })) throw new NotFoundException('Vehículo no encontrado.');
    throw new BadRequestException('El kilometraje no puede disminuir.');
  }

  async asignar(id: string, posicion: string, llanta: AsignarLlantaDto) {
    const _id = this.id(id);
    if (!posiciones.includes(posicion as Posicion)) throw new BadRequestException('Posición inválida.');
    const campo = `llantas.${posicion}`;
    // Solo se escribe una posición; asignaciones concurrentes no se sobrescriben.
    const actualizado = await this.vehiculos.findOneAndUpdate(
      { _id, kilometraje: { $gte: llanta.kilometrajeInstalacion }, [campo]: { $exists: false } },
      { $set: { [campo]: llanta } }, { returnDocument: 'after' },
    );
    if (actualizado) return this.respuesta(actualizado);
    const vehiculo = await this.vehiculos.findOne({ _id });
    if (!vehiculo) throw new NotFoundException('Vehículo no encontrado.');
    if (vehiculo.llantas[posicion as Posicion]) throw new ConflictException('La posición ya tiene una llanta asignada.');
    throw new BadRequestException('La instalación no puede superar el kilometraje actual.');
  }
}
