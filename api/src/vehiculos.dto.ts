import { Transform } from 'class-transformer';
import { IsInt, IsNotEmpty, IsString, Max, Min } from 'class-validator';

const trim = ({ value }: { value: unknown }) =>
  typeof value === 'string' ? value.trim() : value;

export class KilometrajeDto {
  @IsInt()
  @Min(0)
  @Max(Number.MAX_SAFE_INTEGER)
  kilometraje!: number;
}

export class CrearVehiculoDto extends KilometrajeDto {
  @Transform(trim)
  @IsString()
  @IsNotEmpty()
  alias!: string;

  @Transform(({ value }: { value: unknown }) =>
    typeof value === 'string' ? value.trim().toUpperCase() : value,
  )
  @IsString()
  @IsNotEmpty()
  placa!: string;
}

export class AsignarLlantaDto {
  @Transform(trim)
  @IsString()
  @IsNotEmpty()
  marca!: string;

  @Transform(trim)
  @IsString()
  @IsNotEmpty()
  modelo!: string;

  @IsInt()
  @Min(0)
  @Max(Number.MAX_SAFE_INTEGER)
  kilometrajeInstalacion!: number;
}
