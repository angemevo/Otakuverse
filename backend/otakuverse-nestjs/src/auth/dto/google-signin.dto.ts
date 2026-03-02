import { IsString, IsOptional } from "class-validator";

// src/auth/dto/google-signin.dto.ts
export class GoogleSignInDto {
    @IsString()
    sub!: string;  // ✅ Google user ID

    @IsString()
    email!: string;

    @IsOptional()
    @IsString()
    displayName?: string;

    @IsOptional()
    @IsString()
    photoUrl?: string;

    @IsOptional()
    @IsString()
    location?: string;
}


