import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Query,
  UseGuards,
  Request,
} from '@nestjs/common';
import { ConversationsService } from './conversations.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CreateConversationDto } from './dto/create-conversation.dto';
import { SendMessageDto } from './dto/send-message.dto';
import { AddParticipantsDto } from './dto/add-participants.dto';

@Controller('conversations')
@UseGuards(JwtAuthGuard)
export class ConversationsController {
  constructor(private readonly conversationsService: ConversationsService) {}

  /**
   * POST /conversations
   * Créer une nouvelle conversation
   */
  @Post()
  async create(@Request() req, @Body() createDto: CreateConversationDto) {
    return this.conversationsService.createConversation(req.user.userId, createDto);
  }

  /**
   * GET /conversations
   * Liste des conversations de l'utilisateur
   */
  @Get()
  async findAll(@Request() req) {
    return this.conversationsService.findAll(req.user.userId);
  }

  /**
   * GET /conversations/:id
   * Détails d'une conversation
   */
  @Get(':id')
  async findOne(@Request() req, @Param('id') id: string) {
    return this.conversationsService.findOne(id, req.user.userId);
  }

  /**
   * POST /conversations/:id/messages
   * Envoyer un message
   */
  @Post(':id/messages')
  async sendMessage(
    @Request() req,
    @Param('id') id: string,
    @Body() sendMessageDto: SendMessageDto,
  ) {
    return this.conversationsService.sendMessage(id, req.user.userId, sendMessageDto);
  }

  /**
   * GET /conversations/:id/messages
   * Liste des messages
   */
  @Get(':id/messages')
  async getMessages(
    @Request() req,
    @Param('id') id: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    const pageNum = page ? parseInt(page, 10) : 1;
    const limitNum = limit ? parseInt(limit, 10) : 50;

    return this.conversationsService.getMessages(
      id,
      req.user.userId,
      pageNum,
      limitNum,
    );
  }

  /**
   * POST /conversations/:id/read
   * Marquer les messages comme lus
   */
  @Post(':id/read')
  async markAsRead(@Request() req, @Param('id') id: string) {
    return this.conversationsService.markAsRead(id, req.user.userId);
  }

  /**
   * POST /conversations/:id/participants
   * Ajouter des participants (groupes uniquement)
   */
  @Post(':id/participants')
  async addParticipants(
    @Request() req,
    @Param('id') id: string,
    @Body() addParticipantsDto: AddParticipantsDto,
  ) {
    return this.conversationsService.addParticipants(
      id,
      req.user.userId,
      addParticipantsDto,
    );
  }

  /**
   * POST /conversations/:id/leave
   * Quitter une conversation
   */
  @Post(':id/leave')
  async leave(@Request() req, @Param('id') id: string) {
    return this.conversationsService.leaveConversation(id, req.user.userId);
  }
}