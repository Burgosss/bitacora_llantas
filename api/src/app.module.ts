import { Body, Controller, Get, Module, Param, Patch, Post } from '@nestjs/common';
import { AsignarLlantaDto, CrearVehiculoDto, KilometrajeDto } from './vehiculos.dto';
import { VehiculosService } from './vehiculos.service';

@Controller('vehiculos')
class VehiculosController {
  constructor(private readonly vehiculos: VehiculosService) {}

  @Get()
  listar() { return this.vehiculos.listar(); }

  @Post()
  crear(@Body() dto: CrearVehiculoDto) { return this.vehiculos.crear(dto); }

  @Patch(':id/kilometraje')
  actualizar(@Param('id') id: string, @Body() dto: KilometrajeDto) {
    return this.vehiculos.actualizarKilometraje(id, dto.kilometraje);
  }

  @Post(':id/llantas/:posicion')
  asignar(@Param('id') id: string, @Param('posicion') posicion: string, @Body() dto: AsignarLlantaDto) {
    return this.vehiculos.asignar(id, posicion, dto);
  }
}

@Module({ controllers: [VehiculosController], providers: [VehiculosService] })
export class AppModule {}
