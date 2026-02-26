import { IsString, MinLength, MaxLength, IsOptional } from 'class-validator';

export class SendMessageDto {
    @IsString()
    @MinLength(1)
    @MaxLength(5000)
    content!: string;

    @IsOptional()
    @IsString()
    media_url?: string; // Pour images/vidéos
}