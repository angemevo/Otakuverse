import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  InternalServerErrorException,
  Query,
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
    const { data, error } = await this.supabase.client
      .from('posts')
      .insert({
        user_id: userId,
        caption: dto.caption,
        media_urls: dto.media_urls,
        media_count: dto.media_urls.length,
        location: dto.location ?? null,
        allow_comments: dto.allow_comments ?? true,
      })
      .select()
      .single();

    if (error) throw new Error(error.message);
    return data;
  }

  // ============================================
  // RÉCUPÉRER TOUS LES POST
  // ============================================
  async getAllPosts(limit = 20, page = 1): Promise<Posts[]> {
    const from = (page - 1) * limit;
    const to = from + limit - 1;

    const { data, error } = await this.supabase.client
      .from('posts')
      .select('*')
      .order('created_at', { ascending: false })
      .range(from, to);

    if (error) {
      throw new InternalServerErrorException(error.message);
    }

    return data ?? [];
  }


  // ============================================
  // RÉCUPÉRER UN POST
  // ============================================
  async getPostById(postId: string): Promise<Posts> {
    const { data, error } = await this.supabase.client
      .from('posts')
      .select('*, user:users(id, username, display_name, avatar_url)')
      .eq('id', postId)
      .single();

    if (error || !data) throw new NotFoundException('Post introuvable');
    return data;
  }

  // ============================================
  // RÉCUPÉRER LES POSTS D'UN USER
  // ============================================
  async getPostsByUser(userId: string): Promise<Posts[]> {
    const { data, error } = await this.supabase.client
      .from('posts')
      .select('*, user:users!posts_user_id_fkey(id, username, display_name, avatar_url)')
      .eq('user_id', userId)
      .order('is_pinned', { ascending: false })
      .order('created_at', { ascending: false });

    if (error) throw new Error(error.message);
    return data;
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
  async deletePost(postId: string, userId: string): Promise<boolean> {
    await this._checkOwnership(postId, userId);

    const { error } = await this.supabase.client
      .from('posts')
      .delete()
      .eq('id', postId);

    if (error) throw new Error(error.message);
    return true;
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
  async toggleLike(postId: string, userId: string): Promise<{ liked: boolean }> {
    const { data: existing } = await this.supabase.client
      .from('likes')
      .select('id')
      .eq('target_id', postId)
      .eq('target_type', 'post')
      .eq('user_id', userId)
      .single();

    if (existing) {
      await this.supabase.client
        .from('likes')
        .delete()
        .eq('target_id', postId)
        .eq('target_type', 'post')
        .eq('user_id', userId);

      await this.supabase.client.rpc('decrement_counter', {
        table_name: 'posts',
        row_id: postId,
        column_name: 'likes_count',
      });

      return { liked: false };
    } else {
      await this.supabase.client
        .from('likes')
        .insert({
          target_id: postId,
          target_type: 'post',
          user_id: userId,
        });

      await this.supabase.client.rpc('increment_counter', {
        table_name: 'posts',
        row_id: postId,
        column_name: 'likes_count',
      });

      return { liked: true };
    }
  }

  // ============================================
  // HAS LIKED
  // ============================================
  async hasLiked(postId: string, userId: string): Promise<boolean> {
    const { data } = await this.supabase.client
      .from('likes')
      .select('id')
      .eq('target_id', postId)
      .eq('target_type', 'post')
      .eq('user_id', userId)
      .single();

    return !! data;
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
      .select('*, user:users(id, username, display_name, avatar_url)')
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