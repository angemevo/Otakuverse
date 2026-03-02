// src/profiles/profiles.service.ts

import { Injectable, NotFoundException } from '@nestjs/common';
import { SupabaseService } from '../database/supabase.service';
import { CreateProfileDto } from './dto/create-profile.dto';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { Profile } from './entities/profile.entity';

@Injectable()
export class ProfilesService {
  constructor(private readonly supabase: SupabaseService) {}

  // ============================================
  // RÉCUPÉRER MON PROFIL
  // ============================================
  async getMyProfile(userId: string): Promise<Profile> {
    const { data, error } = await this.supabase.client
      .from('profiles')
      .select('*')
      .eq('user_id', userId)
      .single();

    if (error || !data) {
      throw new NotFoundException('Profil introuvable');
    }

    return data;
  }

  // ============================================
  // RÉCUPÉRER UN PROFIL
  // ============================================
  async getProfile(userId: string): Promise<Profile> {
    const { data, error } = await this.supabase.client
      .from('profiles')
      .select('*')
      .eq('user_id', userId)
      .single();

    if (error || !data) {
      throw new NotFoundException('Profil introuvable');
    }

    return data;
  }

  // ============================================
  // CRÉER UN PROFIL
  // ============================================
  async createProfile(dto: CreateProfileDto): Promise<Profile> {
    const { data, error } = await this.supabase.client
      .from('profiles')
      .insert(dto)
      .select()
      .single();

    if (error) throw new Error(error.message);
    return data;
  }

  // ============================================
  // METTRE À JOUR UN PROFIL
  // ============================================
  async updateProfile(userId: string, dto: UpdateProfileDto): Promise<Profile> {
    console.log('🔵 Updating profile for user:', userId);
    console.log('📝 DTO:', dto);

    // 1. Mettre à jour profiles
    const { data: profileData, error: profileError } = await this.supabase.client
      .from('profiles')
      .update({
        display_name: dto.display_name,
        bio: dto.bio,
        avatar_url: dto.avatar_url,
        banner_url: dto.banner_url,
        birth_date: dto.birth_date,
        gender: dto.gender,
        website: dto.website,
        favorite_anime: dto.favorite_anime,
        favorite_manga: dto.favorite_manga,
        favorite_games: dto.favorite_games,
        favorite_genres: dto.favorite_genres,
        is_private: dto.is_private,
        updated_at: new Date(),
      })
      .eq('user_id', userId)
      .select()
      .single();

    if (profileError) {
      console.error('❌ Error updating profile:', profileError);
      throw new Error(profileError.message);
    }

    console.log('✅ Profile updated successfully');

    // 2. ✅ SYNCHRONISER avec users (backup si trigger échoue)
    console.log('🔵 Syncing with users table...');
    
    const userUpdate: any = {};
    
    if (dto.display_name !== undefined) {
      userUpdate.display_name = dto.display_name;
    }
    
    if (dto.avatar_url !== undefined) {
      userUpdate.avatar_url = dto.avatar_url;
    }

    if (Object.keys(userUpdate).length > 0) {
      const { error: userError } = await this.supabase.client
        .from('users')
        .update({
          ...userUpdate,
          updated_at: new Date(),
        })
        .eq('id', userId);

      if (userError) {
        console.error('⚠️ Warning: Could not sync with users table:', userError);
      } else {
        console.log('✅ Users table synchronized');
      }
    }

    return profileData;
  }

  // ============================================
  // COMPLÉTER LE PROFIL GOOGLE
  // ============================================
  async completeGoogleProfile(
    userId: string,
    birthDate: string,
    gender: string,
    favoriteAnime: string[],
    favoriteManga: string[],
    favoriteGenres: string[],
  ): Promise<Profile> {
    const { data, error } = await this.supabase.client
      .from('profiles')
      .update({
        birth_date: birthDate,
        gender: gender,
        favorite_anime: favoriteAnime,
        favorite_manga: favoriteManga,
        favorite_genres: favoriteGenres,
        updated_at: new Date(),
      })
      .eq('user_id', userId)
      .select()
      .single();

    if (error) throw new Error(error.message);
    return data;
  }

  // ============================================
  // METTRE À JOUR LES PRÉFÉRENCES D'ONBOARDING
  // ============================================
  async updateOnboardingPreferences(
    userId: string,
    favoriteAnime: string[],
    favoriteGames: string[],
  ): Promise<Profile> {
    const { data, error } = await this.supabase.client
      .from('profiles')
      .update({
        favorite_anime: favoriteAnime,
        favorite_games: favoriteGames,
        updated_at: new Date(),
      })
      .eq('user_id', userId)
      .select()
      .single();

    if (error) throw new Error(error.message);
    return data;
  }

  // ============================================
  // ✅ TOGGLE PRIVACY (MÉTHODE MANQUANTE)
  // ============================================
  async togglePrivacy(userId: string): Promise<{ is_private: boolean }> {
    console.log('🔵 Toggling privacy for user:', userId);

    // 1. Récupérer le profil actuel
    const profile = await this.getMyProfile(userId);

    // 2. Inverser is_private
    const newPrivacy = !profile.is_private;

    // 3. Mettre à jour
    const { data, error } = await this.supabase.client
      .from('profiles')
      .update({
        is_private: newPrivacy,
        updated_at: new Date(),
      })
      .eq('user_id', userId)
      .select('is_private')
      .single();

    if (error) {
      console.error('❌ Error toggling privacy:', error);
      throw new Error(error.message);
    }

    console.log(`✅ Privacy toggled to: ${newPrivacy}`);
    return { is_private: newPrivacy };
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
  // DÉCRÉMENTER POSTS COUNT
  // ============================================
  async decrementPostsCount(userId: string): Promise<void> {
    const { error } = await this.supabase.client.rpc('decrement_counter', {
      table_name: 'profiles',
      row_id: userId,
      column_name: 'posts_count',
    });

    if (error) throw new Error(error.message);
  }

  // ============================================
  // FOLLOW / UNFOLLOW
  // ============================================
  async follow(followerId: string, followingId: string): Promise<void> {
    const { error } = await this.supabase.client
      .from('follows')
      .insert({
        follower_id: followerId,
        following_id: followingId,
      });

    if (error) throw new Error(error.message);

    // Incrémenter les compteurs
    await this.incrementFollowingCount(followerId);
    await this.incrementFollowersCount(followingId);
  }

  async unfollow(followerId: string, followingId: string): Promise<void> {
    const { error } = await this.supabase.client
      .from('follows')
      .delete()
      .eq('follower_id', followerId)
      .eq('following_id', followingId);

    if (error) throw new Error(error.message);

    // Décrémenter les compteurs
    await this.decrementFollowingCount(followerId);
    await this.decrementFollowersCount(followingId);
  }

  // ============================================
  // HELPERS PRIVÉS
  // ============================================
  private async incrementFollowersCount(userId: string): Promise<void> {
    const { error } = await this.supabase.client.rpc('increment_counter', {
      table_name: 'profiles',
      row_id: userId,
      column_name: 'followers_count',
    });
    if (error) console.error('Error incrementing followers:', error);
  }

  private async decrementFollowersCount(userId: string): Promise<void> {
    const { error } = await this.supabase.client.rpc('decrement_counter', {
      table_name: 'profiles',
      row_id: userId,
      column_name: 'followers_count',
    });
    if (error) console.error('Error decrementing followers:', error);
  }

  private async incrementFollowingCount(userId: string): Promise<void> {
    const { error } = await this.supabase.client.rpc('increment_counter', {
      table_name: 'profiles',
      row_id: userId,
      column_name: 'following_count',
    });
    if (error) console.error('Error incrementing following:', error);
  }

  private async decrementFollowingCount(userId: string): Promise<void> {
    const { error } = await this.supabase.client.rpc('decrement_counter', {
      table_name: 'profiles',
      row_id: userId,
      column_name: 'following_count',
    });
    if (error) console.error('Error decrementing following:', error);
  }
}