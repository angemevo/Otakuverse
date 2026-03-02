export interface StoryReply {
  id: string;
  story_id: string;
  sender_id: string;
  message: string;
  created_at: Date;
  
  // Relations
  sender?: {
    id: string;
    username: string;
    display_name: string;
    avatar_url: string;
  };
}