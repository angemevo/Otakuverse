import {
  IsEmail,
  IsString,
  MinLength,
  MaxLength,
  IsOptional,
  IsDateString,
  IsEnum,
  IsPhoneNumber,
} from 'class-validator';

export class SignupDto {
  @IsEmail()
  email!: string;

  @IsString()
  @MinLength(8)
  password!: string;

  @IsString()
  @MinLength(3)
  @MaxLength(30)
  username!: string;

  @IsDateString()
  date_of_birth!: string;

  @IsEnum(['male', 'female', 'other', 'prefer_not_to_say'])
  gender!: string;

  @IsOptional()
  @IsString()
  avatar_url?: string;

  @IsOptional()
  @IsPhoneNumber()
  phone?: string;

  @IsOptional()
  @IsString()
  location?: string;
}