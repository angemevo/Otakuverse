import { IsEmail, IsString, MinLength, MaxLength, IsOptional } from 'class-validator';

export class CreateUserDto {
  @IsString()
  id: string;

  @IsEmail()
  email: string;

  @IsString()
  @MinLength(3)
  @MaxLength(30)
  username: string;

  @IsString()
  @IsOptional()
  @MaxLength(100)
  display_name?: string;
}
// - id: string
// - email: string
// - username: string
// - displayName?: string
