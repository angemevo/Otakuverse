import {
  Controller,
  Get,
  Patch,
  Post,
  Body,
  Param,
  Request,
  UseGuards,
} from '@nestjs/common';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { ProfilesService } from './profile.service';

@Controller('profiles')
@UseGuards(JwtAuthGuard)
export class ProfilesController {
  constructor(private readonly profilesService: ProfilesService) {}

  // ============================================
  // MON PROFIL
  // ============================================
  @Get('me')
  getMyProfile(@Request() req) {
    return this.profilesService.getMyProfile(req.user.userId);
  }

  // ============================================
  // METTRE À JOUR MON PROFIL
  // ============================================
  @Patch('me')
  updateMyProfile(@Request() req, @Body() dto: UpdateProfileDto) {
    return this.profilesService.updateProfile(req.user.userId, dto);
  }

  // ============================================
  // COMPLÉTER LE PROFIL GOOGLE
  // ============================================
  @Patch('me/complete')
  completeGoogleProfile(
    @Request() req,
    @Body() body: {
      birthDate: string;
      gender: string;
      favoriteAnime: string[];
      favoriteManga: string[];
      favoriteGenres: string[];
    },
  ) {
    return this.profilesService.completeGoogleProfile(
      req.user.userId,
      body.birthDate,
      body.gender,
      body.favoriteAnime,
      body.favoriteManga,
      body.favoriteGenres,
    );
  }

  // ============================================
  // METTRE À JOUR LES PRÉFÉRENCES D'ONBOARDING
  // ============================================
  @Patch('me/onboarding')
  updateOnboardingPreferences(
    @Request() req,
    @Body() body: {
      favoriteAnime: string[];
      favoriteGames: string[];
    },
  ) {
    return this.profilesService.updateOnboardingPreferences(
      req.user.userId,
      body.favoriteAnime,
      body.favoriteGames,
    );
  }

  // ============================================
  // ✅ TOGGLE PRIVACY
  // ============================================
  @Post('me/toggle-privacy')
  togglePrivacy(@Request() req) {
    return this.profilesService.togglePrivacy(req.user.userId);
  }

  // ============================================
  // PROFIL D'UN AUTRE USER
  // ============================================
  @Get(':userId')
  getProfile(@Param('userId') userId: string) {
    return this.profilesService.getProfile(userId);
  }

  // ============================================
  // FOLLOW / UNFOLLOW
  // ============================================
  @Post(':userId/follow')
  follow(@Request() req, @Param('userId') userId: string) {
    return this.profilesService.follow(req.user.userId, userId);
  }

  @Post(':userId/unfollow')
  unfollow(@Request() req, @Param('userId') userId: string) {
    return this.profilesService.unfollow(req.user.userId, userId);
  }
}