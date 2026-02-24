export class Profile {
  id!: string;
  user_id!: string;
  display_name?: string;
  bio?: string;
  avatar_url?: string;
  banner_url?: string;
  birth_date?: string;
  gender?: 'male' | 'female' | 'other' | 'prefer_not_to_say';
  location?: string;
  website?: string;
  favorite_anime!: string[];
  favorite_manga: string[] = [];
  favorite_genres: string[] = [];
  followers_count!: number;
  following_count!: number;
  posts_count!: number;
  is_private: boolean = false;
  is_verified: boolean = false;
  created_at!: Date;
  updated_at!: Date;
}