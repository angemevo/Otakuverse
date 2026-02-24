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
    const { data, error } = await this.supabase.client
      .from('profiles')
      .insert({ user_id: userId, display_name: displayName })
      .select()
      .single();

    if (error) throw new Error(error.message);
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

    if (error) throw new Error(error.message);
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

    if (error) throw new Error(error.message);
    return newPrivacy;
  }

  // ============================================
  // INCRÉMENTER POSTS COUNT
  // ============================================
  async incrementPostsCount(userId: string): Promise<void> {
    const { error } = await this.supabase.client.rpc('increment_counter', {
      table_name: 'profiles',
      row_id: userId,
      column_name: 'posts_count',
    });
    if (error) throw new Error(error.message);
  }

  // ============================================
  // INCRÉMENTER FOLLOWERS
  // ============================================
  async incrementFollowers(userId: string): Promise<void> {
    const { error } = await this.supabase.client.rpc('increment_counter', {
      table_name: 'profiles',
      row_id: userId,
      column_name: 'followers_count',
    });
    if (error) throw new Error(error.message);
  }
}