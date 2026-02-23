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
        media_count: dto.media_urls!.length,
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
            .select('*, user:users!posts_user_id_fkey(id, username, display_name, avatar_url)') // 👈 nom de la FK
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
    async toggleLike(postId: string, userId: string): Promise<{ liked: boolean }> {
        // Vérifie si le like existe déjà
        const { data: existing } = await this.supabase.client
            .from('likes')
            .select('id')
            .eq('post_id', postId)
            .eq('user_id', userId)
            .single();

        if (existing) {
            // ❌ Déjà liké → on retire le like
            await this.supabase.client
            .from('likes')
            .delete()
            .eq('post_id', postId)
            .eq('user_id', userId);

            await this.supabase.client
            .from('posts')
            .update({ likes_count: this.supabase.client.rpc('decrement', { x: 1 }) })
            .eq('id', postId);

            // Décrémente le compteur
            await this.supabase.client.rpc('decrement_counter', {
            table_name: 'posts',
            row_id: postId,
            column_name: 'likes_count',
            });

            return { liked: false };
        } else {
            // ✅ Pas encore liké → on ajoute le like
            await this.supabase.client
            .from('likes')
            .insert({ post_id: postId, user_id: userId });

            await this.supabase.client.rpc('increment_counter', {
            table_name: 'posts',
            row_id: postId,
            column_name: 'likes_count',
            });

            return { liked: true };
        }
    }

    // Vérifie si un user a liké un post
    async hasLiked(postId: string, userId: string): Promise<boolean> {
        const { data } = await this.supabase.client
            .from('likes')
            .select('id')
            .eq('post_id', postId)
            .eq('user_id', userId)
            .single();

        return !!data;
    }

    // Récupérer les post likés
    async getLikedPosts(userId: string): Promise<Post[]> {
        const { data, error } = await this.supabase.client
            .from('likes')
            .select('post:posts(*)')
            .eq('user_id', userId)
            .order('created_at', { ascending: false });

        if (error) throw new Error(error.message);
        return data.map((item: any) => item.post);
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
// - findAll(query): liste avec pagination
// - findOne(id): trouver par ID
// - findByUser(userId): posts d'un utilisateur
// - create(userId, dto): créer post
// - update(id, dto): modifier post
// - remove(id): supprimer post
// - getFeed(userId): feed personnalisé
