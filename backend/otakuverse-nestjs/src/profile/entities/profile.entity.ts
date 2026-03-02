// src/profiles/entities/profile.entity.ts

export interface Profile {
  id: string;
  user_id: string;
  display_name?: string;
  bio?: string;
  avatar_url?: string;
  banner_url?: string;
  birth_date?: string;
  gender?: string;
  location?: string;
  website?: string;
  favorite_anime: string[];
  favorite_manga: string[];
  favorite_games: string[];
  favorite_genres: string[];
  followers_count: number;
  following_count: number;
  posts_count: number;
  is_private: boolean;
  is_verified: boolean;
  created_at: Date;
  updated_at: Date;
}