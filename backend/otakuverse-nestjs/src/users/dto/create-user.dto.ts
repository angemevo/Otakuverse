import {
  IsEmail,
  IsString,
  IsOptional,
  IsDateString,
  IsEnum,
  IsPhoneNumber,
} from 'class-validator';

export class CreateUserDto {
  @IsString()
  id!: string;

  @IsEmail()
  email!: string;

  @IsString()
  username!: string;

  @IsOptional()
  @IsString()
  display_name?: string;

  @IsOptional()
  @IsString()
  avatar_url?: string;

  @IsOptional()
  @IsPhoneNumber()
  phone?: string;

  @IsOptional()
  @IsDateString()
  date_of_birth?: string;

  @IsOptional()
  @IsEnum(['male', 'female', 'other', 'prefer_not_to_say'])
  gender?: string;

  @IsOptional()
  @IsString()
  location?: string;
}