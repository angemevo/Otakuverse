export interface Conversation {
  id: string;
  conversation_type: 'individual' | 'group';
  title: string | null;
  avatar_url: string | null;
  participants: string[]; // JSONB array
  last_message_id: string | null;
  last_message_at: Date | null;
  is_muted: boolean;
  created_at: Date;
  updated_at: Date;
  
  // Relations (pas en BDD)
  participant_details?: ConversationParticipant[];
  last_message?: Message;
  unread_count?: number;
}

export interface ConversationParticipant {
  id: string;
  conversation_id: string;
  user_id: string;
  role: 'admin' | 'member';
  joined_at: Date;
  left_at: Date | null;
  last_read_at: Date | null;
  
  user?: {
    id: string;
    username: string;
    display_name: string;
    avatar_url: string | null;
  };
}

export interface Message {
  id: string;
  conversation_id: string;
  sender_id: string;
  receiver_id: string | null;
  text: string;
  image_url: string | null;
  is_read: boolean;
  read_at: Date | null;
  created_at: Date;
  
  sender?: {
    id: string;
    username: string;
    display_name: string;
    avatar_url: string | null;
  };
}