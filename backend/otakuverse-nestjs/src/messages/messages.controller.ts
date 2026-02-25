import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, Req } from '@nestjs/common';
import { MessagesService } from './messages.service';
import { CreateMessageDto } from './dto/create-message.dto';
import { UpdateMessageDto } from './dto/update-message.dto';
import { JwtAuthGuard } from '@/auth/jwt-auth.guard';
import { Message } from './entities/message.entity';

@Controller('messages')
export class MessagesController {
  constructor(private readonly messagesService: MessagesService) {}

  @Post()
  @UseGuards(JwtAuthGuard)
  async sendMessage(
    @Param('conversationId') conversationId: string,
    @Body() dto: CreateMessageDto,
    @Req() req
  ): Promise<Message> {
    const senderId = req.user.id;
    return this.messagesService.sendMessage(conversationId, senderId, dto)
  }

  @Patch('mark-as-read')
  @UseGuards(JwtAuthGuard)
  async markAsRead(
    @Body('messageIds') messageIds: string[],
    @Req() req,
  ): Promise<Message[]> {
    const userId = req.user.id;
    return this.messagesService.markAsRead(messageIds, userId)
  }

  @Delete()
  @UseGuards(JwtAuthGuard)
  async deleteMessage(
    @Body('messageIds') messageIds: string[]
  ): Promise<Message[]> {
    return this.messagesService.deleteMessage(messageIds)
  }

  @Post(':message/reply')
  async replyMessage(
    @Param('messageId') messageId: string,
    @Body() dto: CreateMessageDto,
    @Req() req
  ): Promise<Message> {
    const userId = req.user.id;
    return this.messagesService.replyToMessage(messageId, userId, dto)
  }

  @Patch(':id')
  async updateMessage(
    @Param('id') messageIds: string[], 
    @Body() dto: UpdateMessageDto,
    @Req() req,
  ): Promise<Message[]> {
    const userId = req.user.id
    return this.messagesService.updateMessage(messageIds, userId, dto);
  }
}
