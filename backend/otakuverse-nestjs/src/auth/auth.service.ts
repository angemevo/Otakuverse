import {
  Injectable,
  BadRequestException,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { UsersService } from '../users/users.service';
import { SupabaseService } from '../database/supabase.service';
import { SignupDto } from './dto/signup.dto';
import { SigninDto } from './dto/signin.dto';
import { OnboardingDto } from './dto/onboarding.dto';
import { User } from '../users/entities/user.entity';
import { ProfilesService } from '@/profile/profile.service';

@Injectable()
export class AuthService {
  constructor(
    private readonly usersService: UsersService,
    private readonly profilesService: ProfilesService, // ✅ AJOUTÉ
    private readonly jwtService: JwtService,
    private readonly supabaseService: SupabaseService,
  ) {}

  private formatUser(user: User) {
    return {
      id: user.id,
      email: user.email,
      username: user.username,
      display_name: user.display_name,
      avatar_url: user.avatar_url,
      phone: user.phone,
      date_of_birth: user.date_of_birth,
      gender: user.gender,
      location: user.location,
      favorite_animes: user.favorite_animes ?? [],
      favorite_games: user.favorite_games ?? [],
      email_verified: user.email_verified ?? false,
      phone_verified: user.phone_verified ?? false,
      is_active: user.is_active ?? true,
      is_banned: user.is_banned ?? false,
      banned_until: user.banned_until ?? null,
      ban_reason: user.ban_reason ?? null,
      last_login: user.last_login ?? null,
      created_at: user.created_at,
      updated_at: user.updated_at,
    };
  }

  private generateToken(user: User): string {
    return this.jwtService.sign({
      sub: user.id,
      email: user.email,
      username: user.username,
    });
  }

  async signup(signupDto: SignupDto) {
    // 1. Vérifier unicité username
    const existingUsername = await this.usersService.findByUsername(signupDto.username);
    if (existingUsername) {
      throw new BadRequestException("Ce nom d'utilisateur est déjà pris");
    }

    // 2. Créer dans Supabase Auth
    const { data: authData, error: authError } = await this.supabaseService
      .getClient()
      .auth.signUp({
        email: signupDto.email,
        password: signupDto.password,
      });

    if (authError) {
      if (authError.message.includes('already registered')) {
        throw new BadRequestException('Cet email est déjà utilisé');
      }
      throw new BadRequestException(`Échec de l'inscription: ${authError.message}`);
    }

    if (!authData.user) {
      throw new BadRequestException("Erreur: utilisateur non créé");
    }

    // 3. Créer le user en BDD
    const user = await this.usersService.create({
      id: authData.user.id,
      email: signupDto.email,
      username: signupDto.username,
      display_name: signupDto.username,
      phone: signupDto.phone,
      date_of_birth: signupDto.date_of_birth,
      gender: signupDto.gender,
      location: signupDto.location,
      avatar_url: signupDto.avatar_url
    });

    // 4. ✅ Créer le profil associé
    await this.profilesService.createProfile(user.id, user.username);

    return {
      token: this.generateToken(user),
      user: this.formatUser(user),
    };
  }

  async signin(signinDto: SigninDto) {
    // 1. Authentifier avec Supabase Auth
    const { data: authData, error: authError } = await this.supabaseService
      .getClient()
      .auth.signInWithPassword({
        email: signinDto.email,
        password: signinDto.password,
      });

    if (authError) {
      throw new UnauthorizedException('Email ou mot de passe incorrect');
    }

    // 2. Récupérer le user complet
    const user = await this.usersService.findById(authData.user.id);

    return {
      token: this.generateToken(user),
      user: this.formatUser(user),
    };
  }

  async updateOnboarding(userId: string, onboardingDto: OnboardingDto) {
    const { data, error } = await this.supabaseService
      .getClient()
      .from('users')
      .update({
        favorite_animes: onboardingDto.favorite_animes,
        favorite_games: onboardingDto.favorite_games,
      })
      .eq('id', userId)
      .select()
      .single();

    if (error) {
      console.error('❌ Erreur Supabase:', error.message);
      throw new BadRequestException('Erreur lors de la mise à jour des préférences');
    }

    return {
      message: 'Préférences enregistrées avec succès',
      favorite_animes: data.favorite_animes,
      favorite_games: data.favorite_games,
    };
  }

  async signInWithGoogle(googleData: {
    sub: string;
    email: string;
    displayName?: string;
    photoUrl?: string;
    location?: string;
  }) {
    let user = await this.usersService.findByEmail(googleData.email);

    if (!user) {
      // Générer un username unique
      const base = googleData.email
        .split('@')[0]
        .toLowerCase()
        .replace(/[^a-z0-9_]/g, '');
      let username = base;
      let counter = 1;

      while (await this.usersService.findByUsername(username)) {
        username = `${base}${counter}`;
        counter++;
      }

      user = await this.usersService.create({
        id: googleData.sub,
        email: googleData.email,
        username,
        display_name: googleData.displayName ?? username,
        avatar_url: googleData.photoUrl,
        location: googleData.location,
      });

      // ✅ Créer le profil pour les users Google aussi
      await this.profilesService.createProfile(user.id, user.display_name ?? user.username);
    }

    return {
      token: this.generateToken(user),
      user: this.formatUser(user),
    };
  }
}