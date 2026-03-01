import { IsString, IsOptional, IsEnum, IsUUID, IsUrl } from 'class-validator';

export class CreateMessageDto {
    @IsUUID()
    conversation_id!: string;

    @IsUUID()
    sender_id!: string;

    @IsString()
    content!: string;

    @IsEnum(['text', 'image', 'video', 'audio', 'file'])
    message_type!: 'text' | 'image' | 'video' | 'audio' | 'file';

    @IsOptional()
    @IsUrl()
    media_url?: string;

    @IsOptional()
    @IsUUID()
    reply_to_id?: string;
}
