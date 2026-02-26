import { Injectable, BadRequestException, NotFoundException, ForbiddenException } from '@nestjs/common';
import { SupabaseService } from '../database/supabase.service';
import { CreateConversationDto } from './dto/create-conversation.dto';
import { Conversation, Message } from './entities/conversation.entity';
import { AddParticipantsDto } from './dto/add-participants.dto';
import { SendMessageDto } from './dto/send-message.dto';

@Injectable()
export class ConversationsService {
  constructor(private readonly supabaseService: SupabaseService) {}

  /**
   * Créer une nouvelle conversation
   */
  async createConversation(userId: string, createDto: CreateConversationDto) {
    console.log('💬 Création conversation');
    console.log('Type:', createDto.type);
    console.log('Participants:', createDto.participant_ids.length);

    // Validation
    if (createDto.type === 'group' && !createDto.title) {
      throw new BadRequestException('Le titre est requis pour les conversations de groupe');
    }

    if (createDto.type === 'individual' && createDto.participant_ids.length !== 1) {
      throw new BadRequestException('Une conversation individuelle doit avoir exactement 1 participant');
    }

    // Vérifier si conversation individuelle existe déjà
    if (createDto.type === 'individual') {
      const existingConv = await this.findIndividualConversation(
        userId,
        createDto.participant_ids[0],
      );

      if (existingConv) {
        console.log('✅ Conversation existante retournée');
        return existingConv;
      }
    }

    // Préparer les participants (array pour JSONB)
    const allParticipants = [userId, ...createDto.participant_ids];

    // Créer la conversation
    const { data: conversation, error: convError } = await this.supabaseService
      .getClient()
      .from('conversations')
      .insert({
        conversation_type: createDto.type,
        title: createDto.title,
        avatar_url: createDto.avatar_url,
        participants: allParticipants, // JSONB
        last_message_at: new Date().toISOString(),
      })
      .select()
      .single();

    if (convError) {
      console.error('❌ Erreur création conversation:', convError);
      throw new BadRequestException('Erreur lors de la création de la conversation');
    }

    console.log('✅ Conversation créée:', conversation.id);

    // Ajouter les participants dans la table séparée
    const participants = allParticipants.map(uid => ({
      conversation_id: conversation.id,
      user_id: uid,
      role: uid === userId ? 'admin' : 'member',
    }));

    const { error: partError } = await this.supabaseService
      .getClient()
      .from('conversation_participants')
      .insert(participants);

    if (partError) {
      console.error('❌ Erreur ajout participants:', partError);
      // Continue quand même, JSONB est la source de vérité
    }

    console.log('✅ Participants ajoutés');

    return await this.findOne(conversation.id, userId);
  }

  /**
   * Trouver une conversation individuelle existante
   */
  private async findIndividualConversation(user1Id: string, user2Id: string) {
    // Utiliser JSONB pour la recherche
    const { data: conversations } = await this.supabaseService
      .getClient()
      .from('conversations')
      .select('*')
      .eq('conversation_type', 'individual')
      .contains('participants', [user1Id])
      .contains('participants', [user2Id]);

    if (!conversations || conversations.length === 0) return null;

    // Vérifier que c'est exactement ces 2 users
    const exactMatch = conversations.find(conv => {
      const parts = Array.isArray(conv.participants) ? conv.participants : [];
      return parts.length === 2 && parts.includes(user1Id) && parts.includes(user2Id);
    });

    return exactMatch || null;
  }

  /**
   * Récupérer toutes les conversations d'un utilisateur
   */
  async findAll(userId: string) {
    console.log('📥 Récupération conversations pour:', userId);

    // Utiliser JSONB participants pour filtrer
    const { data: conversations, error } = await this.supabaseService
      .getClient()
      .from('conversations')
      .select(`
        *,
        participant_details:conversation_participants(
          *,
          user:users(id, username, display_name, avatar_url)
        )
      `)
      .contains('participants', [userId])
      .order('last_message_at', { ascending: false, nullsFirst: false });

    if (error) {
      console.error('❌ Erreur récupération conversations:', error);
      throw new BadRequestException('Erreur lors de la récupération des conversations');
    }

    if (!conversations) return [];

    // Pour chaque conversation, récupérer le dernier message et unread count
    const conversationsWithMessages = await Promise.all(
      conversations.map(async (conv) => {
        const lastMessage = await this.getLastMessage(conv.id);
        const unreadCount = await this.getUnreadCount(conv.id, userId);

        return {
          ...conv,
          last_message: lastMessage,
          unread_count: unreadCount,
        };
      }),
    );

    console.log(`✅ ${conversationsWithMessages.length} conversations récupérées`);

    return conversationsWithMessages;
  }

  /**
   * Récupérer une conversation spécifique
   */
  async findOne(conversationId: string, userId: string) {
    console.log('🔍 Récupération conversation:', conversationId);

    // Vérifier que l'utilisateur est participant
    await this.checkParticipant(conversationId, userId);

    const { data: conversation, error } = await this.supabaseService
      .getClient()
      .from('conversations')
      .select(`
        *,
        participant_details:conversation_participants(
          *,
          user:users(id, username, display_name, avatar_url)
        )
      `)
      .eq('id', conversationId)
      .single();

    if (error || !conversation) {
      throw new NotFoundException('Conversation non trouvée');
    }

    const lastMessage = await this.getLastMessage(conversationId);
    const unreadCount = await this.getUnreadCount(conversationId, userId);

    return {
      ...conversation,
      last_message: lastMessage,
      unread_count: unreadCount,
    };
  }

  /**
   * Envoyer un message
   */
  async sendMessage(
    conversationId: string,
    userId: string,
    sendMessageDto: SendMessageDto,
  ) {
    console.log('📤 Envoi message dans conversation:', conversationId);

    // Vérifier que l'utilisateur est participant
    await this.checkParticipant(conversationId, userId);

    // Récupérer la conversation pour avoir les participants
    const conversation = await this.findOne(conversationId, userId);

    // Déterminer le receiver_id (pour compatibilité avec ancienne structure)
    let receiverId: string | null = null;
    if (conversation.conversation_type === 'individual') {
      const participants = Array.isArray(conversation.participants) 
        ? conversation.participants 
        : [];
      receiverId = participants.find(p => p !== userId) || null;
    }

    // Créer le message
    const { data: message, error } = await this.supabaseService
      .getClient()
      .from('messages')
      .insert({
        conversation_id: conversationId, // ✅ Nouveau champ
        sender_id: userId,
        receiver_id: receiverId, // Pour compatibilité
        text: sendMessageDto.content,
        image_url: sendMessageDto.media_url, // Map media_url → image_url
      })
      .select(`
        *,
        sender:users(id, username, display_name, avatar_url)
      `)
      .single();

    if (error) {
      console.error('❌ Erreur envoi message:', error);
      throw new BadRequestException('Erreur lors de l\'envoi du message');
    }

    // Mettre à jour la conversation
    await this.supabaseService
      .getClient()
      .from('conversations')
      .update({
        last_message_id: message.id,
        last_message_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      })
      .eq('id', conversationId);

    console.log('✅ Message envoyé:', message.id);

    return message;
  }

  /**
   * Récupérer les messages d'une conversation
   */
  async getMessages(
    conversationId: string,
    userId: string,
    page: number = 1,
    limit: number = 50,
  ) {
    console.log('📥 Récupération messages:', conversationId);

    // Vérifier que l'utilisateur est participant
    await this.checkParticipant(conversationId, userId);

    const offset = (page - 1) * limit;

    const { data: messages, error } = await this.supabaseService
      .getClient()
      .from('messages')
      .select(`
        *,
        sender:users(id, username, display_name, avatar_url)
      `)
      .eq('conversation_id', conversationId)
      .order('created_at', { ascending: false })
      .range(offset, offset + limit - 1);

    if (error) {
      console.error('❌ Erreur récupération messages:', error);
      throw new BadRequestException('Erreur lors de la récupération des messages');
    }

    console.log(`✅ ${messages?.length || 0} messages récupérés`);

    // Retourner dans l'ordre chronologique
    return messages?.reverse() || [];
  }

  /**
   * Marquer les messages comme lus
   */
  async markAsRead(conversationId: string, userId: string) {
    console.log('✅ Marquage messages comme lus:', conversationId);

    // Vérifier que l'utilisateur est participant
    await this.checkParticipant(conversationId, userId);

    // Marquer tous les messages non lus comme lus
    const { error } = await this.supabaseService
      .getClient()
      .from('messages')
      .update({ 
        is_read: true, 
        read_at: new Date().toISOString() 
      })
      .eq('conversation_id', conversationId)
      .neq('sender_id', userId) // Pas ses propres messages
      .eq('is_read', false);

    if (error) {
      console.error('❌ Erreur marquage lecture:', error);
      throw new BadRequestException('Erreur lors du marquage comme lu');
    }

    // Mettre à jour last_read_at du participant
    await this.supabaseService
      .getClient()
      .from('conversation_participants')
      .update({ last_read_at: new Date().toISOString() })
      .eq('conversation_id', conversationId)
      .eq('user_id', userId);

    console.log('✅ Messages marqués comme lus');

    return { success: true };
  }

  /**
   * Ajouter des participants (groupes uniquement)
   */
  async addParticipants(
    conversationId: string,
    userId: string,
    addParticipantsDto: AddParticipantsDto,
  ) {
    console.log('➕ Ajout participants:', conversationId);

    // Vérifier que c'est un groupe
    const conversation = await this.findOne(conversationId, userId);
    if (conversation.conversation_type !== 'group') {
      throw new BadRequestException('On ne peut ajouter des participants qu\'aux groupes');
    }

    // Vérifier que l'utilisateur est admin
    const { data: participant } = await this.supabaseService
      .getClient()
      .from('conversation_participants')
      .select('role')
      .eq('conversation_id', conversationId)
      .eq('user_id', userId)
      .single();

    if (!participant || participant.role !== 'admin') {
      throw new ForbiddenException('Seuls les admins peuvent ajouter des participants');
    }

    // Mettre à jour le JSONB participants
    const currentParticipants = Array.isArray(conversation.participants) 
      ? conversation.participants 
      : [];
    const newParticipants = [...currentParticipants, ...addParticipantsDto.user_ids];

    await this.supabaseService
      .getClient()
      .from('conversations')
      .update({ participants: newParticipants })
      .eq('id', conversationId);

    // Ajouter dans la table séparée
    const participants = addParticipantsDto.user_ids.map(uid => ({
      conversation_id: conversationId,
      user_id: uid,
      role: 'member',
    }));

    await this.supabaseService
      .getClient()
      .from('conversation_participants')
      .insert(participants);

    console.log(`✅ ${participants.length} participants ajoutés`);

    return await this.findOne(conversationId, userId);
  }

  /**
   * Quitter une conversation
   */
  async leaveConversation(conversationId: string, userId: string) {
    console.log('👋 Quitter conversation:', conversationId);

    await this.checkParticipant(conversationId, userId);

    // Marquer comme quitté dans la table
    await this.supabaseService
      .getClient()
      .from('conversation_participants')
      .update({ left_at: new Date().toISOString() })
      .eq('conversation_id', conversationId)
      .eq('user_id', userId);

    // Retirer du JSONB participants
    const conversation = await this.findOne(conversationId, userId);
    const currentParticipants = Array.isArray(conversation.participants) 
      ? conversation.participants 
      : [];
    const newParticipants = currentParticipants.filter(p => p !== userId);

    await this.supabaseService
      .getClient()
      .from('conversations')
      .update({ participants: newParticipants })
      .eq('id', conversationId);

    console.log('✅ Conversation quittée');

    return { success: true };
  }

  // ============================================
  // MÉTHODES HELPERS
  // ============================================

  private async checkParticipant(conversationId: string, userId: string) {
    // Vérifier via JSONB (source de vérité)
    const { data: conversation } = await this.supabaseService
      .getClient()
      .from('conversations')
      .select('participants')
      .eq('id', conversationId)
      .single();

    if (!conversation) {
      throw new NotFoundException('Conversation non trouvée');
    }

    const participants = Array.isArray(conversation.participants) 
      ? conversation.participants 
      : [];

    if (!participants.includes(userId)) {
      throw new ForbiddenException('Vous n\'êtes pas participant de cette conversation');
    }
  }

  private async getLastMessage(conversationId: string) {
    const { data } = await this.supabaseService
      .getClient()
      .from('messages')
      .select(`
        *,
        sender:users(id, username, display_name, avatar_url)
      `)
      .eq('conversation_id', conversationId)
      .order('created_at', { ascending: false })
      .limit(1)
      .single();

    return data || null;
  }

  private async getUnreadCount(conversationId: string, userId: string) {
    const { count } = await this.supabaseService
      .getClient()
      .from('messages')
      .select('*', { count: 'exact', head: true })
      .eq('conversation_id', conversationId)
      .neq('sender_id', userId)
      .eq('is_read', false);

    return count || 0;
  }
}