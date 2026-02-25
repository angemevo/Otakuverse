import { Injectable, InternalServerErrorException, NotFoundException } from '@nestjs/common';
import { CreateMessageDto } from './dto/create-message.dto';
import { UpdateMessageDto } from './dto/update-message.dto';
import { SupabaseService } from '@/database/supabase.service';
import { Message } from './entities/message.entity';
import { NotFoundError } from 'rxjs';

@Injectable()
export class MessagesService {
  constructor(private readonly supabase: SupabaseService) {}

  // ============================================
  // ENVOYER UN MESSAGE
  // ============================================
  async sendMessage(conversationId: string, senderId: string, dto: CreateMessageDto): Promise<Message> {
    const { data, error } = await this.supabase.client
      .from('messages')
      .insert({
        conversation_id: conversationId,
        sender_id: senderId,
        content: dto.content,
        message_type: dto.message_type,
        media_url: dto.media_url,
        reply_to_id: dto.reply_to_id,
        is_read: false,
        is_deleted: false,
      })
      .select()
      .single();

    if (error) throw new InternalServerErrorException(error.message);

    return data as Message;
  }

  // ============================================
  // MARQUER UN MESSAGE COMME LU
  // ============================================
  async markAsRead(messageIds: string[], userId: String): Promise<Message[]> {
    const { data, error } = await this.supabase.client
      .from('messages')
      .update({
        is_read: true,
        read_at: new Date(),
      })
      .in('id', messageIds)
      .eq('sender_id', userId)
      .select();

    if (error) throw new InternalServerErrorException(error.message);
    if (!data || data.length === 0) throw new NotFoundException('Message Introuvables')
      
    return data as Message[];
  }

  // ============================================
  // SUPPRIMER UN OU PLUSIEURS MESSAGES
  // ============================================
  async deleteMessage(messageIds: string[]): Promise<Message[]> {
    const { data, error } = await this.supabase.client
      .from('messages')
      .delete()
      .in('id', messageIds)
      .select();

    if (error) throw new InternalServerErrorException(error.message);
    if (!data || data.length === 0) throw new NotFoundException('Messages introuvables');

    return data as Message[];
  }

  // ============================================
  // MODIFIER UN MESSAGES
  // ============================================
  async updateMessage(messageIds: string[], userId: string, dto: UpdateMessageDto): Promise<Message[]> {
    const { data, error } = await this.supabase.client
      .from('messages')
      .update({
        ...dto,
        updated_at: new Date()
      })
      .in('id', messageIds)
      .eq('sender_id', userId)
      .select();

    if (error) throw new InternalServerErrorException(error.message);
    if (!data || data.length === 0) throw new NotFoundException('Messages introuvables');

    return data as Message[];
  }

  // ============================================
  // REPONDRE A UN MESSAGES
  // ============================================
  async replyToMessage(messageId: string, userId: string, dto: CreateMessageDto): Promise<Message> {
    
    // Vérifier si le message existe 
    const { data: originalMessage, error: findError } = await this.supabase.client
      .from('messages')
      .select('*')
      .eq('id', userId)
      .single();

    if (findError || !originalMessage) {
      throw new NotFoundException('Message original introuvale');
    }

    // Créer la reponse 
    const { data, error } = await this.supabase.client
      .from('messages')
      .insert({
        conversation_id: originalMessage.conversation_id,
        sender_id: userId,
        content: dto.content,
        message_type: dto.message_type,
        media_url: dto.media_url,
        reply_to_id: messageId,
        is_read: false,
        is_delete: false,
      })
      .select()
      .single()
    
    if (error) throw new InternalServerErrorException(error.message);

    return data as Message;
  }
}
