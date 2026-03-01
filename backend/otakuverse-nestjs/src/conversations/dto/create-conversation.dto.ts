import { IsString, IsEnum, IsOptional, IsArray, IsUUID, ValidateIf } from 'class-validator';

export class CreateConversationDto {
    @IsEnum(['individual', 'group'])
    type: 'individual' | 'group' = "individual";

    @ValidateIf(o => o.type === 'group')
    @IsString()
    title?: string;

    @IsOptional()
    @IsString()
    avatar_url?: string;

    @IsArray()
    @IsUUID('4', { each: true })
    participant_ids: string[] = []; // IDs des participants (sans l'utilisateur actuel)
}