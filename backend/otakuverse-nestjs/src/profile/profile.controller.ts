import {
  Controller,
  Get,
  Patch,
  Param,
  Body,
  Request,
  UseGuards,
} from '@nestjs/common';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { ProfilesService } from './profile.service';

@Controller('profiles')
@UseGuards(JwtAuthGuard)
export class ProfilesController {
  constructor(private readonly profilesService: ProfilesService) {}

  // Mon profil
  @Get('me')
  getMyProfile(@Request() req) {
    return this.profilesService.getProfile(req.user.id);
  }

  // Profil d'un autre user
  @Get(':userId')
  getProfile(@Param('userId') userId: string) {
    return this.profilesService.getProfile(userId);
  }

  // Modifier mon profil
  @Patch('me')
  updateProfile(@Request() req, @Body() dto: UpdateProfileDto) {
    return this.profilesService.updateProfile(req.user.id, dto);
  }

  // Toggle privé/public
  @Patch('me/privacy')
  togglePrivacy(@Request() req) {
    return this.profilesService.togglePrivacy(req.user.id);
  }
}