// src/auth/auth.controller.ts

import {
  Controller,
  Post,
  Get,
  Body,
  UseGuards,
  Request,
} from '@nestjs/common';
import { AuthService } from './auth.service';
import { UsersService } from '../users/users.service';
import { SignupDto } from './dto/signup.dto';
import { SigninDto } from './dto/signin.dto';
import { OnboardingDto } from './dto/onboarding.dto';
import { GoogleSignInDto } from './dto/google-signin.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';

@Controller('auth')
export class AuthController {
  constructor(
    private readonly authService: AuthService,
    private readonly usersService: UsersService,
  ) {}

  /**
   * POST /auth/signup
   * Inscription avec email/password
   */
  @Post('signup')
  async signup(@Body() signupDto: SignupDto) {
    return this.authService.signup(signupDto);
  }

  /**
   * POST /auth/signin
   * Connexion avec email/password
   */
  @Post('signin')
  async signin(@Body() signinDto: SigninDto) {
    return this.authService.signin(signinDto);
  }

  /**
   * POST /auth/google
   * Connexion avec Google
   */
  @Post('google')
  async googleSignIn(@Body() googleSignInDto: GoogleSignInDto) {
    return this.authService.signInWithGoogle(googleSignInDto);
  }

  /**
   * POST /auth/onboarding
   * Enregistrer les préférences après inscription
   */
  @Post('onboarding')
  @UseGuards(JwtAuthGuard)
  async onboarding(@Request() req, @Body() onboardingDto: OnboardingDto) {
    return this.authService.updateOnboarding(req.user.userId, onboardingDto);
  }

  /**
   * GET /auth/me
   * Récupérer les infos de l'utilisateur connecté
   */
  @Get('me')
  @UseGuards(JwtAuthGuard)
  async getMe(@Request() req) {
    const user = await this.usersService.findById(req.user.userId);

    return {
      user: {
        id: user.id,
        email: user.email,
        username: user.username,
        display_name: user.display_name,
        avatar_url: user.avatar_url,
        date_of_birth: user.date_of_birth,
        gender: user.gender,
        location: user.location,
        favorite_animes: user.favorite_animes,
        favorite_games: user.favorite_games,
        created_at: user.created_at,
      },
    };
  }
}