// src/auth/auth.service.ts

import {
  Injectable,
  BadRequestException,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { v4 as uuidv4 } from 'uuid';
import { UsersService } from '../users/users.service';
import { SupabaseService } from '../database/supabase.service';
import { SignupDto } from './dto/signup.dto';
import { SigninDto } from './dto/signin.dto';
import { OnboardingDto } from './dto/onboarding.dto';
import { GoogleSignInDto } from './dto/google-signin.dto';
import { User } from '../users/entities/user.entity';
import { ProfilesService } from '@/profile/profile.service';
import { CreateProfileDto } from '@/profile/dto/create-profile.dto';

@Injectable()
export class AuthService {
  constructor(
    private readonly usersService: UsersService,
    private readonly profilesService: ProfilesService,
    private readonly jwtService: JwtService,
    private readonly supabaseService: SupabaseService,
  ) {}

  /**
   * Formater les données utilisateur pour la réponse
   */
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

  /**
   * Générer un token JWT
   */
  private generateToken(user: User): string {
    return this.jwtService.sign({
      sub: user.id,
      email: user.email,
      username: user.username,
    });
  }

  /**
   * Inscription avec email/password
   */
  async signup(signupDto: SignupDto) {
    console.log('📝 Début inscription');

    // 1. Vérifier unicité username
    const existingUsername = await this.usersService.findByUsername(
      signupDto.username,
    );
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
      throw new BadRequestException(
        `Échec de l'inscription: ${authError.message}`,
      );
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
      avatar_url: signupDto.avatar_url,
    });

    // 4. ✅ CORRIGÉ : Créer le profil avec CreateProfileDto complet
    const profileData: CreateProfileDto = {
      user_id: user.id,
      display_name: user.display_name ?? undefined,
      bio: undefined,
      avatar_url: user.avatar_url ?? undefined,
      banner_url: undefined,
      birth_date: user.date_of_birth ? user.date_of_birth.toISOString() : undefined,
      gender: user.gender ?? undefined,
      location: user.location ?? undefined,
      website: undefined,
      favorite_anime: [],
      favorite_manga: [],
      favorite_games: [],
      favorite_genres: [],
      is_private: false,
      is_verified: false,
    };

    await this.profilesService.createProfile(profileData);

    console.log('✅ Inscription réussie:', user.username);

    return {
      token: this.generateToken(user),
      user: this.formatUser(user),
    };
  }

  /**
   * Connexion avec email/password
   */
  async signin(signinDto: SigninDto) {
    console.log('🔐 Tentative de connexion:', signinDto.email);

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

    console.log('✅ Connexion réussie:', user.username);

    return {
      token: this.generateToken(user),
      user: this.formatUser(user),
    };
  }

  /**
   * Connexion avec Google
   */
  async signInWithGoogle(googleSignInDto: GoogleSignInDto) {
    console.log('🔵 === DÉBUT GOOGLE SIGNIN ===');
    console.log('📧 Email:', googleSignInDto.email);

    let user = await this.usersService.findByEmail(googleSignInDto.email);
    let isNewUser = false;

    if (!user) {
      console.log('➕ Création nouvel utilisateur Google');
      isNewUser = true;

      const username = await this.generateUsername(googleSignInDto.email);
      console.log('👤 Username généré:', username);

      // ✅ GÉNÉRER UN UUID au lieu d'utiliser Google sub
      const userId = uuidv4();
      console.log('🆔 UUID généré:', userId);

      user = await this.usersService.create({
        id: userId,  // ✅ UUID généré, pas Google sub
        email: googleSignInDto.email,
        username: username,
        display_name: googleSignInDto.displayName || username,
        avatar_url: googleSignInDto.photoUrl,
        location: googleSignInDto.location,
      });

      // ✅ CORRIGÉ : Créer le profil avec CreateProfileDto complet
      const profileData: CreateProfileDto = {
        user_id: user.id,
        display_name: user.display_name ?? undefined,
        bio: undefined,
        avatar_url: user.avatar_url ?? undefined,
        banner_url: undefined,
        birth_date: undefined,
        gender: undefined,
        location: user.location ?? undefined,
        website: undefined,
        favorite_anime: [],
        favorite_manga: [],
        favorite_games: [],
        favorite_genres: [],
        is_private: false,
        is_verified: false,
      };

      await this.profilesService.createProfile(profileData);

      console.log('✅ Utilisateur + profil créés');
    } else {
      console.log('✅ Utilisateur existant trouvé');
      isNewUser = false;

      // Mettre à jour l'avatar si changé
      if (
        googleSignInDto.photoUrl &&
        user.avatar_url !== googleSignInDto.photoUrl
      ) {
        await this.usersService.update(user.id, {
          avatar_url: googleSignInDto.photoUrl,
        });
        user.avatar_url = googleSignInDto.photoUrl;

        // ✅ AUSSI mettre à jour dans profiles
        await this.profilesService.updateProfile(user.id, {
          avatar_url: googleSignInDto.photoUrl,
        });
      }
    }

    const token = this.generateToken(user);

    console.log('✅ Token JWT généré');
    console.log('🎉 === GOOGLE SIGNIN RÉUSSI ===');

    return {
      token,
      user: this.formatUser(user),
      is_new_user: isNewUser,
    };
  }

  /**
   * Mettre à jour les préférences onboarding
   */
  async updateOnboarding(userId: string, onboardingDto: OnboardingDto) {
    console.log('🎮 Mise à jour onboarding pour:', userId);

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
      throw new BadRequestException(
        'Erreur lors de la mise à jour des préférences',
      );
    }

    console.log('✅ Préférences enregistrées');

    return {
      message: 'Préférences enregistrées avec succès',
      favorite_animes: data.favorite_animes,
      favorite_games: data.favorite_games,
    };
  }

  /**
   * Générer un username unique depuis un email
   */
  private async generateUsername(email: string): Promise<string> {
    const baseUsername = email
      .split('@')[0]
      .toLowerCase()
      .replace(/[^a-z0-9_]/g, '');

    if (!baseUsername || baseUsername.length < 3) {
      return this.generateRandomUsername();
    }

    let username = baseUsername;
    let counter = 1;

    while (await this.usersService.findByUsername(username)) {
      username = `${baseUsername}${counter}`;
      counter++;

      if (counter > 9999) {
        return this.generateRandomUsername();
      }
    }

    return username;
  }

  /**
   * Générer un username aléatoire (fallback)
   */
  private generateRandomUsername(): string {
    const prefix = 'user';
    const randomNumber = Math.floor(Math.random() * 1000000);
    return `${prefix}${randomNumber}`;
  }
}