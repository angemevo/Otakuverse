import { IsString, MaxLength, IsOptional, IsUrl } from 'class-validator';

export class UpdateUserDto {
  @IsString()
  @IsOptional()
  @MaxLength(100)
  display_name?: string;

  @IsUrl()
  @IsOptional()
  avatar_url?: string;

  @IsString()
  @IsOptional()
  @MaxLength(500)
  bio?: string;
}
// - displayName?: string
// - avatarUrl?: string
// - bio?: string
