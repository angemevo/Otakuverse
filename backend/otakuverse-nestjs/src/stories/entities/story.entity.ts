export interface Story {
  id: string;
  user_id: string;
  media_url: string;
  media_type: 'image' | 'video';
  views_count: number;
  created_at: Date;
  expires_at: Date;
  
  // Relations (optionnelles, depuis jointures)
  user?: {
    id: string;
    username: string;
    display_name: string;
    avatar_url: string;
  };
}

export interface StoryView {
  id: string;
  story_id: string;
  user_id: string;
  viewed_at: Date;
  
  // Relations
  user?: {
    id: string;
    username: string;
    display_name: string;
    avatar_url: string;
  };
}