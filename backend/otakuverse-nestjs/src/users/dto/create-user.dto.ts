import { IsEmail, IsNumber, IsOptional, IsString, Max, MaxLength, Min, MinLength } from "class-validator";

export class CreateUserDto {
    @IsString()
    id: string

    @IsEmail()
    email: string;
    
    @IsString()
    @MinLength(3)
    @MaxLength(20)
    username: string;

    @IsString()
    @IsOptional()
    @MaxLength(30)
    displayName?: string;

    @IsNumber()
    phone?: string;
}
// - id: string
// - email: string
// - username: string
// - displayName?: string
