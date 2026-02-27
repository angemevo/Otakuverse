import { Injectable, NotFoundException } from '@nestjs/common';
import { SupabaseService } from '../database/supabase.service';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { Profile } from './entities/profile.entity';

@Injectable()
export class ProfilesService {
  constructor(private readonly supabase: SupabaseService) {}

  // ============================================
  // RÉCUPÉRER UN PROFIL
  // ============================================
  async getProfile(userId: string): Promise<Profile> {
    const { data, error } = await this.supabase.client
      .from('profiles')
      .select('*')
      .eq('user_id', userId)
      .single();

    if (error || !data) throw new NotFoundException('Profil introuvable');
    return data;
  }

  // ============================================
  // CRÉER UN PROFIL (à l'inscription)
  // ============================================
  async createProfile(userId: string, displayName?: string): Promise<Profile> {
    // Vérifier si un profil existe déjà pour éviter les doublons
    const { data: existing } = await this.supabase.client
      .from('profiles')
      .select('id')
      .eq('user_id', userId)
      .single();

    if (existing) return existing as Profile;

    const { data, error } = await this.supabase.client
      .from('profiles')
      .insert({
        user_id: userId,
        display_name: displayName ?? null,
        created_at: new Date(),
        updated_at: new Date(),
      })
      .select()
      .single();

    if (error) throw new Error(`Erreur création profil: ${error.message}`);
    return data;
  }

  // ============================================
  // MODIFIER UN PROFIL
  // ============================================
  async updateProfile(userId: string, dto: UpdateProfileDto): Promise<Profile> {
    const { data, error } = await this.supabase.client
      .from('profiles')
      .update({ ...dto, updated_at: new Date() })
      .eq('user_id', userId)
      .select()
      .single();

    if (error) throw new Error(`Erreur mise à jour profil: ${error.message}`);
    return data;
  }

  // ============================================
  // TOGGLE PRIVÉ / PUBLIC
  // ============================================
  async togglePrivacy(userId: string): Promise<boolean> {
    const profile = await this.getProfile(userId);
    const newPrivacy = !profile.is_private;

    const { error } = await this.supabase.client
      .from('profiles')
      .update({ is_private: newPrivacy, updated_at: new Date() })
      .eq('user_id', userId);

    if (error) throw new Error(`Erreur toggle privacy: ${error.message}`);
    return newPrivacy;
  }

  // ============================================
  // INCRÉMENTER POSTS COUNT
  // ============================================
  async incrementPostsCount(userId: string): Promise<void> {
    const profile = await this.getProfile(userId);
    const { error } = await this.supabase.client.rpc('increment_counter', {
      table_name: 'profiles',
      row_id: profile.id, // ✅ id réel de la table profiles
      column_name: 'posts_count',
    });
    if (error) throw new Error(error.message);
  }

  // ============================================
  // INCRÉMENTER FOLLOWERS
  // ============================================
  async incrementFollowers(userId: string): Promise<void> {
    const profile = await this.getProfile(userId);
    const { error } = await this.supabase.client.rpc('increment_counter', {
      table_name: 'profiles',
      row_id: profile.id, // ✅ id réel de la table profiles
      column_name: 'followers_count',
    });
    if (error) throw new Error(error.message);
  }

  // ============================================
  // INCRÉMENTER FOLLOWING
  // ============================================
  async incrementFollowing(userId: string): Promise<void> {
    const profile = await this.getProfile(userId);
    const { error } = await this.supabase.client.rpc('increment_counter', {
      table_name: 'profiles',
      row_id: profile.id,
      column_name: 'following_count',
    });
    if (error) throw new Error(error.message);
  }
}