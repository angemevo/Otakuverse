import { IsEmail, IsString, MinLength, MaxLength, IsOptional } from 'class-validator';

export class SignupDto {
  @IsEmail({}, { message: 'Email invalide' })
  email: string;

  @IsString()
  @MinLength(8, { message: 'Le mot de passe doit faire au moins 8 caractères' })
  password: string;

  @IsString()
  @MinLength(3, { message: 'Le nom d\'utilisateur doit faire au moins 3 caractères' })
  @MaxLength(30, { message: 'Le nom d\'utilisateur ne peut pas dépasser 30 caractères' })
  username: string;

  @IsString()
  @IsOptional()
  @MaxLength(100)
  display_name?: string;
}
// - email: string (IsEmail)
// - password: string (MinLength(8))
// - username: string (MinLength(3))
// - displayName?: string (optional)
