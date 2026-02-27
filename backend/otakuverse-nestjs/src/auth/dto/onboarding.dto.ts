import { IsArray, IsString, IsOptional, ArrayMaxSize } from 'class-validator';

export class OnboardingDto {
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  @ArrayMaxSize(50)
  favorite_animes: string[] = [];

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  @ArrayMaxSize(50)
  favorite_games: string[] = [];
}