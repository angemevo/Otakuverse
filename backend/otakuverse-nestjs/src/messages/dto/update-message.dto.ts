import { IsString, IsOptional, IsEnum, IsUrl, IsBoolean } from 'class-validator';

export class UpdateMessageDto {
  @IsOptional()
  @IsString()
  content?: string;

  @IsOptional()
  @IsEnum(['text', 'image', 'video', 'audio', 'file'])
  message_type?: 'text' | 'image' | 'video' | 'audio' | 'file';

  @IsOptional()
  @IsUrl()
  media_url?: string;

  @IsOptional()
  @IsBoolean()
  is_read?: boolean;

  @IsOptional()
  @IsBoolean()
  is_deleted?: boolean;
}
