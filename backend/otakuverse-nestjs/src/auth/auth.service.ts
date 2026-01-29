import { Injectable, UnauthorizedException, ConflictException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { SupabaseService } from '../database/supabase.service';
import { UsersService } from '../users/users.service';
import { SignupDto } from './dto/signup.dto';
import { SigninDto } from './dto/signin.dto';

@Injectable()
export class AuthService {
  constructor(
    private supabaseService: SupabaseService,
    private usersService: UsersService,
    private jwtService: JwtService,
  ) {}

  async signup(signupDto: SignupDto) {
    console.log('\n🚀 === DÉBUT SIGNUP ===');
    console.log('📧 Email:', signupDto.email);
    console.log('👤 Username:', signupDto.username);

    try {
      // Vérifier si l'email existe
      console.log('\n1️⃣  Vérification email...');
      const existingEmail = await this.usersService.findByEmail(signupDto.email);
      if (existingEmail) {
        console.log('❌ Email déjà utilisé');
        throw new ConflictException('Cet email est déjà utilisé');
      }
      console.log('✅ Email disponible');

      // Vérifier si le username existe
      console.log('\n2️⃣  Vérification username...');
      const existingUsername = await this.usersService.findByUsername(signupDto.username);
      if (existingUsername) {
        console.log('❌ Username déjà pris');
        throw new ConflictException('Ce nom d\'utilisateur est déjà pris');
      }
      console.log('✅ Username disponible');

      // Créer l'utilisateur dans Supabase Auth
      console.log('\n3️⃣  Création dans Supabase Auth...');
      const { data: authData, error: authError } = await this.supabaseService
        .getClient()
        .auth.signUp({
          email: signupDto.email,
          password: signupDto.password,
        });

      if (authError || !authData.user) {
        console.error('❌ Erreur Supabase Auth:', authError?.message);
        throw new Error(`Échec de l'inscription: ${authError?.message}`);
      }
      console.log('✅ Utilisateur créé dans Supabase Auth');
      console.log('🆔 Auth ID:', authData.user.id);

      // Créer le profil utilisateur dans la table users
      console.log('\n4️⃣  Création du profil dans la table users...');
      const user = await this.usersService.create({
        id: authData.user.id,
        email: signupDto.email,
        username: signupDto.username,
        display_name: signupDto.display_name || signupDto.username,
      });
      console.log('✅ Profil créé:', user.username);

      // Générer le token JWT
      console.log('\n5️⃣  Génération du token JWT...');
      const token = this.generateJwt({
        sub: user.id,
        email: user.email,
      });
      console.log('✅ Token JWT généré');

      console.log('\n🎉 === SIGNUP RÉUSSI ===\n');

      return {
        token,
        user: {
          id: user.id,
          email: user.email,
          username: user.username,
          display_name: user.display_name,
        },
      };
    } catch (error) {
      console.error('\n❌ === ERREUR SIGNUP ===');
      console.error(error);
      throw error;
    }
  }

  async signin(signinDto: SigninDto) {
    console.log('\n🔑 === DÉBUT SIGNIN ===');
    console.log('📧 Email:', signinDto.email);

    try {
      // Authentifier avec Supabase
      console.log('\n1️⃣  Authentification Supabase...');
      const { data: authData, error: authError } = await this.supabaseService
        .getClient()
        .auth.signInWithPassword({
          email: signinDto.email,
          password: signinDto.password,
        });

      if (authError || !authData.user) {
        console.log('❌ Identifiants invalides');
        throw new UnauthorizedException('Email ou mot de passe incorrect');
      }
      console.log('✅ Authentification réussie');

      // Récupérer le profil utilisateur
      console.log('\n2️⃣  Récupération du profil...');
      const user = await this.usersService.findByEmail(signinDto.email);
      if (!user) {
        console.log('❌ Profil introuvable');
        throw new UnauthorizedException('Utilisateur non trouvé');
      }
      console.log('✅ Profil récupéré:', user.username);

      // Générer le token JWT
      console.log('\n3️⃣  Génération du token JWT...');
      const token = this.generateJwt({
        sub: user.id,
        email: user.email,
      });
      console.log('✅ Token JWT généré');

      console.log('\n🎉 === SIGNIN RÉUSSI ===\n');

      return {
        token,
        user: {
          id: user.id,
          email: user.email,
          username: user.username,
          display_name: user.display_name,
          avatar_url: user.avatar_url,
        },
      };
    } catch (error) {
      console.error('\n❌ === ERREUR SIGNIN ===');
      console.error(error);
      throw error;
    }
  }

  private generateJwt(payload: { sub: string; email: string }) {
    return this.jwtService.sign(payload);
  }
}
// - signup(dto): créer utilisateur + générer JWT
// - signin(dto): vérifier credentials + générer JWT
// - validateUser(email, password): vérifier credentials
// - generateJwt(payload): créer token JWT
