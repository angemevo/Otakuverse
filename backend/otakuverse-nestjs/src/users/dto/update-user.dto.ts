import { IsOptional, IsString, IsUrl, MaxLength } from "class-validator";

export class UpdateUserDto {
    @IsString()
    @IsOptional()
    @MaxLength(30)
    displayName?: string;

    @IsUrl()
    @IsOptional()
    avatarUrl?: string;
    
    @IsString()
    @IsOptional()
    @MaxLength(160)
    bio?: string;
}
// - displayName?: string
// - avatarUrl?: string
// - bio?: string
