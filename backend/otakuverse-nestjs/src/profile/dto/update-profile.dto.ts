// src/profiles/dto/update-profile.dto.ts

import { IsOptional, IsString, IsArray, IsBoolean } from 'class-validator';

export class UpdateProfileDto {
  @IsOptional()
  @IsString()
  display_name?: string;

  @IsOptional()
  @IsString()
  bio?: string;

  @IsOptional()
  @IsString()
  avatar_url?: string;

  @IsOptional()
  @IsString()
  banner_url?: string;

  @IsOptional()
  @IsString()
  birth_date?: string;

  @IsOptional()
  @IsString()
  gender?: string;

  @IsOptional()
  @IsString()
  location?: string;

  @IsOptional()
  @IsString()
  website?: string;

  @IsOptional()
  @IsArray()
  favorite_anime?: string[];

  @IsOptional()
  @IsArray()
  favorite_manga?: string[];

  @IsOptional()
  @IsArray()
  favorite_games?: string[];

  @IsOptional()
  @IsArray()
  favorite_genres?: string[];

  @IsOptional()
  @IsBoolean()
  is_private?: boolean;
}