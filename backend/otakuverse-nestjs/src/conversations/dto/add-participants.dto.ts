import { IsArray, IsUUID } from 'class-validator';

export class AddParticipantsDto {
    @IsArray()
    @IsUUID('4', { each: true })
    user_ids!: string[];
}