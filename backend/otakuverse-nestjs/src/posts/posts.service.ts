import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { SupabaseService } from '../database/supabase.service';
import { CreatePostDto } from './dto/create-post.dto';
import { UpdatePostDto } from './dto/update-post.dto';
import { Post } from './entities/post.entity';


@Injectable()
export class PostsService {
  constructor(private readonly supabase: SupabaseService) {}

  // ============================================
  // CRÉER UN POST
  // ============================================
  async createPost(userId: string, dto: CreatePostDto): Promise<Post> {
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
  // RÉCUPÉRER UN POST
  // ============================================
  async getPostById(postId: string): Promise<Post> {
    const { data, error } = await this.supabase.client
      .from('posts')
      .select('*, user:users(id, username, avatar_url)')
      .eq('id', postId)
      .single();

    if (error || !data) throw new NotFoundException('Post introuvable');
    return data;
  }

  // ============================================
  // RÉCUPÉRER LES POSTS D'UN USER
  // ============================================
  async getPostsByUser(userId: string): Promise<Post[]> {
    const { data, error } = await this.supabase.client
      .from('posts')
      .select('*')
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
  ): Promise<Post> {
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
  // INCRÉMENTER LES COMPTEURS
  // ============================================
  async incrementLikes(postId: string): Promise<void> {
    await this._incrementCounter(postId, 'likes_count');
  }

  async incrementComments(postId: string): Promise<void> {
    await this._incrementCounter(postId, 'comments_count');
  }

  async incrementShares(postId: string): Promise<void> {
    await this._incrementCounter(postId, 'shares_count');
  }

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