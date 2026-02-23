import {
  IsString,
  IsArray,
  IsOptional,
  IsBoolean,
  MaxLength,
  ArrayMinSize,
  ArrayMaxSize,
  IsUrl,
} from 'class-validator';

export class CreatePostDto {
    @IsString()
    @MaxLength(2200)
    caption!: string;

    @IsArray()
    @ArrayMinSize(1)
    @ArrayMaxSize(10)
    @IsUrl({}, { each: true })
    media_urls!: string[];

    @IsOptional()
    @IsString()
    location?: string;

    @IsOptional()
    @IsBoolean()
    allow_comments?: boolean;
}