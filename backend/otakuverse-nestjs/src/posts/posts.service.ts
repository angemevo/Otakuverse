// src/posts/posts.service.ts

import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  InternalServerErrorException,
  BadRequestException,
} from '@nestjs/common';
import { SupabaseService } from '../database/supabase.service';
import { CreatePostDto } from './dto/create-post.dto';
import { UpdatePostDto } from './dto/update-post.dto';
import { Posts } from './entities/post.entity';

@Injectable()
export class PostsService {
  constructor(private readonly supabase: SupabaseService) {}

  // ============================================
  // CRÉER UN POST
  // ============================================
  async createPost(userId: string, dto: CreatePostDto): Promise<Posts> {
    console.log('🔵 Creating post...');
    console.log('Caption:', dto.caption);
    console.log('Media URLs:', dto.media_urls);
    console.log('Location:', dto.location);

    // ✅ VALIDATION : Au moins une caption OU des médias
    if (!dto.caption && (!dto.media_urls || dto.media_urls.length === 0)) {
      throw new BadRequestException(
        'Un post doit avoir au moins une caption ou des médias',
      );
    }

    // ✅ Si caption vide mais il y a des médias, c'est OK
    // ✅ Si caption présente sans médias, c'est OK aussi

    const { data, error } = await this.supabase.client
      .from('posts')
      .insert({
        user_id: userId,
        caption: dto.caption || '',
        media_urls: dto.media_urls || [], // ✅ Tableau vide par défaut
        location: dto.location,
        likes_count: 0,
        comments_count: 0,
      })
      .select(`
        *,
        user:users!posts_user_id_fkey(
          id,
          username,
          display_name,
          avatar_url
        )
      `)
      .single();

    if (error) {
      console.error('❌ Error creating post:', error);
      throw new Error(error.message);
    }

    console.log('✅ Post created:', data.id);
    return data;
  }

  // ============================================
  // RÉCUPÉRER TOUS LES POSTS
  // ============================================
  async getAllPosts(): Promise<Posts[]> {
    console.log('🔵 Getting all posts');

    const { data, error } = await this.supabase.client
      .from('posts')
      .select(`
        *,
        user:users!posts_user_id_fkey(
          id,
          username,
          display_name,
          avatar_url
        )
      `)
      .order('created_at', { ascending: false });

    if (error) {
      console.error('❌ Error fetching posts:', error);
      throw new Error(error.message);
    }

    console.log(`✅ Retrieved ${data?.length || 0} posts`);
    return data ?? [];
  }

  // ============================================
  // RÉCUPÉRER UN POST
  // ============================================
  async getPostById(postId: string): Promise<Posts> {
    const { data, error } = await this.supabase.client
      .from('posts')
      .select('*, user:users!posts_user_id_fkey(id, username, display_name, avatar_url)')
      .eq('id', postId)
      .single();

    if (error || !data) throw new NotFoundException('Post introuvable');
    return data;
  }

  // ============================================
  // RÉCUPÉRER LES POSTS D'UN USER
  // ============================================
  async getUserPosts(userId: string): Promise<Posts[]> {
    console.log('🔵 Getting posts for user:', userId);

    const { data, error } = await this.supabase.client
      .from('posts')
      .select(`
        *,
        user:users!posts_user_id_fkey(
          id,
          username,
          display_name,
          avatar_url
        )
      `)
      .eq('user_id', userId)
      .order('created_at', { ascending: false });

    if (error) {
      console.error('❌ Error fetching user posts:', error);
      throw new Error(error.message);
    }

    console.log(`✅ Retrieved ${data?.length || 0} posts for user ${userId}`);
    return data ?? [];
  }

  // ============================================
  // MODIFIER UN POST
  // ============================================
  async updatePost(
    postId: string,
    userId: string,
    dto: UpdatePostDto,
  ): Promise<Posts> {
    await this._checkOwnership(postId, userId);

    const { data, error } = await this.supabase.client
      .from('posts')
      .update({ ...dto, updated_at: new Date() })
      .eq('id', postId)
      .select()
      .single();

    if (error) throw new Error(error.message);
    return data;
  }

  // ============================================
  // SUPPRIMER UN POST
  // ============================================
  async deletePost(postId: string, userId: string): Promise<void> {
    console.log('🗑️ Deleting post:', postId);

    // Vérifier que l'utilisateur est le propriétaire
    const { data: post } = await this.supabase.client
      .from('posts')
      .select('user_id')
      .eq('id', postId)
      .single();

    if (!post || post.user_id !== userId) {
      throw new BadRequestException('Non autorisé à supprimer ce post');
    }

    const { error } = await this.supabase.client
      .from('posts')
      .delete()
      .eq('id', postId);

    if (error) {
      console.error('❌ Error deleting post:', error);
      throw new Error(error.message);
    }

    console.log('✅ Post deleted');
  }

  // ============================================
  // ÉPINGLER / DÉSÉPINGLER UN POST
  // ============================================
  async pinPost(postId: string, userId: string): Promise<boolean> {
    await this._checkOwnership(postId, userId);

    const post = await this.getPostById(postId);
    const newPinned = !post.is_pinned;

    const { error } = await this.supabase.client
      .from('posts')
      .update({ is_pinned: newPinned, updated_at: new Date() })
      .eq('id', postId);

    if (error) throw new Error(error.message);
    return newPinned;
  }

  // ============================================
  // TOGGLE LIKE
  // ============================================
  async toggleLike(postId: string, userId: string) {
    // Vérifier si déjà liké
    const { data: existingLike } = await this.supabase.client
      .from('post_likes')
      .select('id')
      .eq('post_id', postId)
      .eq('user_id', userId)
      .single();

    if (existingLike) {
      // Unlike
      await this.supabase.client
        .from('post_likes')
        .delete()
        .eq('id', existingLike.id);
      
      // Décrémenter le count
      const { data: post } = await this.supabase.client
        .from('posts')
        .select('likes_count')
        .eq('id', postId)
        .single();
      
      const newCount = Math.max(0, (post?.likes_count || 1) - 1);
      
      await this.supabase.client
        .from('posts')
        .update({ likes_count: newCount })
        .eq('id', postId);
      
      return { liked: false, count: newCount };
    } else {
      // Like
      await this.supabase.client
        .from('post_likes')
        .insert({
          post_id: postId,
          user_id: userId,
        });
      
      // Incrémenter le count
      const { data: post } = await this.supabase.client
        .from('posts')
        .select('likes_count')
        .eq('id', postId)
        .single();
      
      const newCount = (post?.likes_count || 0) + 1;
      
      await this.supabase.client
        .from('posts')
        .update({ likes_count: newCount })
        .eq('id', postId);
      
      return { liked: true, count: newCount };
    }
  }

  // ============================================
  // HAS LIKED
  // ============================================
  async hasLiked(postId: string, userId: string): Promise<boolean> {
    console.log(`🔵 Checking if user ${userId} liked post ${postId}`);
    
    const { data } = await this.supabase.client
      .from('likes')
      .select('id')
      .eq('target_id', postId)
      .eq('target_type', 'post')
      .eq('user_id', userId)
      .single();

    const liked = !!data;
    console.log(`✅ User ${userId} ${liked ? 'has' : 'has not'} liked post ${postId}`);
    
    return liked;
  }

  // ============================================
  // GET LIKED POSTS
  // ============================================
  async getLikedPosts(userId: string): Promise<Posts[]> {
    const { data: likesData, error: likesError } = await this.supabase.client
      .from('likes')
      .select('target_id')
      .eq('user_id', userId)
      .eq('target_type', 'post')
      .order('created_at', { ascending: false });

    if (likesError) throw new Error(likesError.message);
    if (!likesData || likesData.length === 0) return [];

    const postIds = likesData.map((l: any) => l.target_id);

    const { data: posts, error: postsError } = await this.supabase.client
      .from('posts')
      .select('*, user:users!posts_user_id_fkey(id, username, display_name, avatar_url)')
      .in('id', postIds);

    if (postsError) throw new Error(postsError.message);
    return posts;
  }

  // ============================================
  // INCRÉMENTER COMMENTAIRES
  // ============================================
  async incrementComments(postId: string): Promise<void> {
    await this._incrementCounter(postId, 'comments_count');
  }

  // ============================================
  // INCRÉMENTER PARTAGES
  // ============================================
  async incrementShares(postId: string): Promise<void> {
    await this._incrementCounter(postId, 'shares_count');
  }

  // ============================================
  // INCRÉMENTER VUES
  // ============================================
  async incrementViews(postId: string): Promise<void> {
    await this._incrementCounter(postId, 'views_count');
  }

  // ============================================
  // HELPERS PRIVÉS
  // ============================================
  private async _checkOwnership(postId: string, userId: string): Promise<void> {
    const post = await this.getPostById(postId);
    if (post.user_id !== userId) {
      throw new ForbiddenException('Action non autorisée');
    }
  }

  private async _incrementCounter(
    postId: string,
    field: 'likes_count' | 'comments_count' | 'shares_count' | 'views_count',
  ): Promise<void> {
    const { error } = await this.supabase.client.rpc('increment_counter', {
      table_name: 'posts',
      row_id: postId,
      column_name: field,
    });

    if (error) throw new Error(error.message);
  }
}