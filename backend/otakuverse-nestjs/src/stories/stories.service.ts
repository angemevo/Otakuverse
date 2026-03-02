// src/stories/stories.service.ts

import { Injectable } from '@nestjs/common';
import { SupabaseService } from '../database/supabase.service';
import { CreateStoryDto } from './dto/create-story.dto';
import { Story, StoryView } from './entities/story.entity';

@Injectable()
export class StoriesService {
  constructor(private readonly supabase: SupabaseService) {}

  // ============================================
  // CRÉER UNE STORY
  // ============================================
  async createStory(userId: string, dto: CreateStoryDto): Promise<Story> {
    console.log('🎬 Creating story for user:', userId);

    const expiresAt = new Date();
    expiresAt.setHours(expiresAt.getHours() + 24);

    const { data, error } = await this.supabase.client
      .from('stories')
      .insert({
        user_id: userId,
        media_url: dto.media_url,
        media_type: dto.media_type,
        expires_at: expiresAt.toISOString(),
      })
      .select()
      .single();

    if (error) {
      console.error('❌ Error creating story:', error);
      throw new Error(error.message);
    }

    console.log('✅ Story created:', data.id);
    return data;
  }

  // ============================================
  // ✅ CORRECTION : RÉCUPÉRER TOUTES LES STORIES ACTIVES
  // ============================================
  async getAllActiveStories(): Promise<Story[]> {
    console.log('🔵 Getting all active stories');

    const { data, error } = await this.supabase.client
      .from('stories')
      .select(`
        *,
        user:users!stories_user_id_fkey(
          id,
          username,
          display_name,
          avatar_url
        )
      `)
      .gt('expires_at', new Date().toISOString())
      .order('created_at', { ascending: false });

    if (error) {
      console.error('❌ Error fetching stories:', error);
      throw new Error(error.message);
    }

    console.log(`✅ Retrieved ${data?.length || 0} stories`);
    return data ?? [];
  }

  // ============================================
  // ✅ CORRECTION : RÉCUPÉRER LES STORIES D'UN USER
  // ============================================
  async getUserStories(userId: string): Promise<Story[]> {
    console.log('🔵 Getting stories for user:', userId);

    const { data, error } = await this.supabase.client
      .from('stories')
      .select(`
        *,
        user:users!stories_user_id_fkey(
          id,
          username,
          display_name,
          avatar_url
        )
      `)
      .eq('user_id', userId)
      .gt('expires_at', new Date().toISOString())
      .order('created_at', { ascending: false });

    if (error) {
      console.error('❌ Error fetching user stories:', error);
      throw new Error(error.message);
    }

    console.log(`✅ Retrieved ${data?.length || 0} stories for user ${userId}`);
    return data ?? [];
  }

  // ============================================
  // ✅ CORRECTION : RÉCUPÉRER UNE STORY PAR ID
  // ============================================
  async getStoryById(storyId: string): Promise<Story> {
    console.log('🔵 Getting story:', storyId);

    const { data, error } = await this.supabase.client
      .from('stories')
      .select(`
        *,
        user:users!stories_user_id_fkey(
          id,
          username,
          display_name,
          avatar_url
        )
      `)
      .eq('id', storyId)
      .single();

    if (error) {
      console.error('❌ Error fetching story:', error);
      throw new Error(error.message);
    }

    console.log('✅ Story retrieved');
    return data;
  }

  // ============================================
  // MARQUER UNE STORY COMME VUE
  // ============================================
  async viewStory(storyId: string, userId: string): Promise<void> {
    console.log(`👁️ User ${userId} viewing story ${storyId}`);

    // Vérifier que l'utilisateur n'est pas le propriétaire
    const story = await this.getStoryById(storyId);
    if (story.user_id === userId) {
      console.log('⏭️ Skipping view - user is the owner');
      return;
    }

    // Vérifier si déjà vu
    const { data: existingView } = await this.supabase.client
      .from('story_views')
      .select('id')
      .eq('story_id', storyId)
      .eq('user_id', userId)
      .single();

    if (existingView) {
      console.log('⏭️ Story already viewed by this user');
      return;
    }

    // Ajouter la vue
    const { error } = await this.supabase.client
      .from('story_views')
      .insert({
        story_id: storyId,
        user_id: userId,
      });

    if (error) {
      console.error('❌ Error adding story view:', error);
      throw new Error(error.message);
    }

    console.log('✅ Story view recorded');
  }

  // ============================================
  // ✅ CORRECTION : RÉCUPÉRER LES VIEWERS D'UNE STORY
  // ============================================
  async getStoryViewers(storyId: string, ownerId: string): Promise<StoryView[]> {
    console.log('🔵 Getting viewers for story:', storyId);

    // Vérifier que l'utilisateur est le propriétaire
    const story = await this.getStoryById(storyId);
    if (story.user_id !== ownerId) {
      throw new Error('Not authorized to view story viewers');
    }

    const { data, error } = await this.supabase.client
      .from('story_views')
      .select(`
        *,
        user:users!story_views_user_id_fkey(
          id,
          username,
          display_name,
          avatar_url
        )
      `)
      .eq('story_id', storyId)
      .order('viewed_at', { ascending: false });

    if (error) {
      console.error('❌ Error fetching viewers:', error);
      throw new Error(error.message);
    }

    console.log(`✅ Retrieved ${data?.length || 0} viewers`);
    return data ?? [];
  }

  // ============================================
  // SUPPRIMER UNE STORY
  // ============================================
  async deleteStory(storyId: string, userId: string): Promise<void> {
    console.log('🗑️ Deleting story:', storyId);

    // Vérifier que l'utilisateur est le propriétaire
    const story = await this.getStoryById(storyId);
    if (story.user_id !== userId) {
      throw new Error('Not authorized to delete this story');
    }

    const { error } = await this.supabase.client
      .from('stories')
      .delete()
      .eq('id', storyId);

    if (error) {
      console.error('❌ Error deleting story:', error);
      throw new Error(error.message);
    }

    console.log('✅ Story deleted');
  }

  // ============================================
  // NETTOYER LES STORIES EXPIRÉES (CRON)
  // ============================================
  async cleanupExpiredStories(): Promise<void> {
    console.log('🧹 Cleaning up expired stories...');

    const { data, error } = await this.supabase.client
      .from('stories')
      .delete()
      .lt('expires_at', new Date().toISOString())
      .select('id');

    if (error) {
      console.error('❌ Error cleaning up:', error);
      return;
    }

    const count = data?.length || 0;
    if (count > 0) {
      console.log(`✅ Deleted ${count} expired stories`);
    } else {
      console.log('✅ No expired stories to delete');
    }
  }

  // ============================================
  // LIKER UNE STORY
  // ============================================
  async toggleLikeStory(storyId: string, userId: string): Promise<boolean> {
    console.log(`👍 User ${userId} toggling like on story ${storyId}`);

    const { data: existingLike } = await this.supabase.client
      .from('story_likes')
      .select('id')
      .eq('story_id', storyId)
      .eq('user_id', userId)
      .single();

    if (existingLike) {
      // Unlike
      await this.supabase.client
        .from('story_likes')
        .delete()
        .eq('id', existingLike.id);
      
      console.log('✅ Story unliked');
      return false;
    } else {
      // Like
      await this.supabase.client
        .from('story_likes')
        .insert({
          story_id: storyId,
          user_id: userId,
        });
      
      console.log('✅ Story liked');
      return true;
    }
  }

  // ============================================
  // RÉPONDRE À UNE STORY
  // ============================================
  async replyToStory(storyId: string, senderId: string, message: string): Promise<void> {
    console.log(`💬 Reply to story ${storyId} from ${senderId}`);

    const { error } = await this.supabase.client
      .from('story_replies')
      .insert({
        story_id: storyId,
        sender_id: senderId,
        message: message,
      });

    if (error) throw new Error(error.message);
    
    console.log('✅ Reply sent');
  }

  // ============================================
  // PARTAGER UNE STORY (REPOST)
  // ============================================
  async repostStory(storyId: string, userId: string): Promise<Story> {
    console.log(`🔄 Reposting story ${storyId} by ${userId}`);

    const originalStory = await this.getStoryById(storyId);

    const expiresAt = new Date();
    expiresAt.setHours(expiresAt.getHours() + 24);

    const { data, error } = await this.supabase.client
      .from('stories')
      .insert({
        user_id: userId,
        media_url: originalStory.media_url,
        media_type: originalStory.media_type,
        expires_at: expiresAt.toISOString(),
        is_repost: true,
        original_story_id: storyId,
      })
      .select()
      .single();

    if (error) throw new Error(error.message);

    console.log('✅ Story reposted');
    return data;
  }
}