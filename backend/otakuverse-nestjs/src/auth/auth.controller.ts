import {
  Controller,
  Post,
  Get,
  Body,
  UseGuards,
  Request,
} from '@nestjs/common';
import { AuthService } from './auth.service';
import { SignupDto } from './dto/signup.dto';
import { SigninDto } from './dto/signin.dto';
import { OnboardingDto } from './dto/onboarding.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';

@Controller('auth')
export class AuthController {
  [x: string]: any;
  constructor(private readonly authService: AuthService) {}

  /**
   * POST /auth/signup
   * ✅ MODIFIÉ : sans display_name et bio
   */
  @Post('signup')
  async signup(@Body() signupDto: SignupDto) {
    return this.authService.signup(signupDto);
  }

  /**
   * POST /auth/signin
   * ✅ Inchangé
   */
  @Post('signin')
  async signin(@Body() signinDto: SigninDto) {
    return this.authService.signin(signinDto);
  }

  /**
   * POST /auth/onboarding
   * ✅ NOUVEAU : Enregistrer les préférences
   */
  @Post('onboarding')
  @UseGuards(JwtAuthGuard)
  async onboarding(@Request() req, @Body() onboardingDto: OnboardingDto) {
    return this.authService.updateOnboarding(req.user.userId, onboardingDto);
  }

  /**
   * GET /auth/me
   * ✅ Inchangé
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
        bio: user.bio,
        date_of_birth: user.date_of_birth,
        gender: user.gender,
        location: user.location,
        favorite_animes: user.favorite_animes,  // ✅ Nouveau
        favorite_games: user.favorite_games,    // ✅ Nouveau
        created_at: user.created_at,
      },
    };
  }

  /**
   * POST /auth/google
   * ✅ Inchangé
   */
  @Post('google')
  async googleSignIn(@Body() googleData: any) {
    return this.authService.signInWithGoogle(googleData);
  }
}