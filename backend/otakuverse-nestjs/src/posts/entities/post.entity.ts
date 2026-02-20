export class Post {
  id: string;
  user_id: string;
  caption: string;
  media_urls: string[];
  media_count: number;
  location?: string;
  is_pinned: boolean;
  allow_comments: boolean;
  likes_count: number;
  comments_count: number;
  shares_count: number;
  views_count: number;
  created_at: Date;
  updated_at: Date;
}