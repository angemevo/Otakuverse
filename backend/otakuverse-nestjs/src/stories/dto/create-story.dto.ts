import { IsNotEmpty, IsString, IsEnum } from 'class-validator';

export class CreateStoryDto {
    @IsNotEmpty()
    @IsString()
    media_url!: string;

    @IsNotEmpty()
    @IsEnum(['image', 'video'])
    media_type!: 'image' | 'video';
}