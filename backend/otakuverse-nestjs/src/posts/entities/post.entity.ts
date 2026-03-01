export class Posts {
  id!: string;
  user_id!: string;
  caption!: string;

  media_urls: string[] = [];
  media_count: number = 0;

  location?: string;

  is_pinned: boolean = false;
  allow_comments: boolean = true;

  likes_count: number = 0;
  comments_count: number = 0;
  shares_count: number = 0;
  views_count: number = 0;

  created_at: Date = new Date();
  updated_at: Date = new Date();
}
