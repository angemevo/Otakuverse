import { Controller, Post, Body, Get, UseGuards } from '@nestjs/common';
import { AuthService } from './auth.service';
import { SignupDto } from './dto/signup.dto';
import { SigninDto } from './dto/signin.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { UsersService } from '../users/users.service';

@Controller('auth')
export class AuthController {
  constructor(
    private readonly authService: AuthService,
    private readonly usersService: UsersService,
  ) {}

  @Post('signup')
  async signup(@Body() signupDto: SignupDto) {
    return this.authService.signup(signupDto);
  }

  @Post('signin')
  async signin(@Body() signinDto: SigninDto) {
    return this.authService.signin(signinDto);
  }

  @Get('me')
  @UseGuards(JwtAuthGuard)
  async getMe(@CurrentUser() user: any) {
    const userData = await this.usersService.findById(user.userId);
    return { user: userData };
  }

  @Get('test')
  test() {
    return {
      success: true,
      message: 'Auth module fonctionne !',
      routes: [
        'POST /auth/signup',
        'POST /auth/signin',
        'GET /auth/me',
      ],
    };
  }
}
// - POST /auth/signup
// - POST /auth/signin
// - GET /auth/me (protected)
