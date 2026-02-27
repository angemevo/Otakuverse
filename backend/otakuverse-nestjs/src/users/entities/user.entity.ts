export interface User {
  id: string;
  email: string;
  username: string;
  display_name: string | null;
  avatar_url: string | null;
  phone: string | null;
  date_of_birth: Date | null;
  gender: string | null;
  location: string | null;
  favorite_animes: string[];
  favorite_games: string[];
  email_verified: boolean;
  phone_verified: boolean;
  is_active: boolean;
  is_banned: boolean;
  banned_until: Date | null;
  ban_reason: string | null;
  last_login: Date | null;
  created_at: Date;
  updated_at: Date;
}