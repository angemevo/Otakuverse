export interface User {
  id: string;
  email: string;
  username: string;
  display_name: string | null;
  avatar_url: string | null;
  bio: string | null;
  followers_count: number;
  following_count: number;
  posts_count: number;
  is_private: boolean;
  is_verified: boolean;
  created_at: Date;
  updated_at: Date;
}