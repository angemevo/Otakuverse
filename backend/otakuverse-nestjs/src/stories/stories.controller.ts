// src/stories/stories.controller.ts

import {
  Controller,
  Get,
  Post,
  Delete,
  Param,
  Body,
  Request,
  UseGuards,
} from '@nestjs/common';
import { StoriesService } from './stories.service';
import { CreateStoryDto } from './dto/create-story.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';

@Controller('stories')
@UseGuards(JwtAuthGuard)
export class StoriesController {
  constructor(private readonly storiesService: StoriesService) {}

  // ============================================
  // CRÉER UNE STORY
  // ============================================
  @Post()
  createStory(@Request() req, @Body() dto: CreateStoryDto) {
    return this.storiesService.createStory(req.user.userId, dto);
  }

  // ============================================
  // RÉCUPÉRER TOUTES LES STORIES ACTIVES
  // ============================================
  @Get()
  getAllStories(@Request() req) {
    return this.storiesService.getAllActiveStories();
  }

  // ============================================
  // RÉCUPÉRER MES STORIES
  // ============================================
  @Get('me')
  getMyStories(@Request() req) {
    return this.storiesService.getUserStories(req.user.userId);
  }

  // ============================================
  // RÉCUPÉRER LES STORIES D'UN USER
  // ============================================
  @Get('user/:userId')
  getUserStories(@Param('userId') userId: string) {
    return this.storiesService.getUserStories(userId);
  }

  // ============================================
  // RÉCUPÉRER UNE STORY
  // ============================================
  @Get(':id')
  getStory(@Param('id') id: string) {
    return this.storiesService.getStoryById(id);
  }

  // ============================================
  // MARQUER COMME VUE
  // ============================================
  @Post(':id/view')
  viewStory(@Param('id') id: string, @Request() req) {
    return this.storiesService.viewStory(id, req.user.userId);
  }

  // ============================================
  // RÉCUPÉRER LES VIEWERS
  // ============================================
  @Get(':id/viewers')
  getViewers(@Param('id') id: string, @Request() req) {
    return this.storiesService.getStoryViewers(id, req.user.userId);
  }

  // ============================================
  // LIKER UNE STORY
  // ============================================
  @Post(':id/like')
  async toggleLike(@Param('id') id: string, @Request() req) {
    const isLiked = await this.storiesService.toggleLikeStory(id, req.user.userId);
    return { liked: isLiked };
  }

  // ============================================
  // RÉPONDRE À UNE STORY
  // ============================================
  @Post(':id/reply')
  async replyToStory(
    @Param('id') id: string,
    @Request() req,
    @Body() body: { message: string },
  ) {
    await this.storiesService.replyToStory(id, req.user.userId, body.message);
    return { message: 'Reply sent' };
  }

  // ============================================
  // PARTAGER UNE STORY (REPOST)
  // ============================================
  @Post(':id/repost')
  async repostStory(@Param('id') id: string, @Request() req) {
    return this.storiesService.repostStory(id, req.user.userId);
  }

  // ============================================
  // SUPPRIMER UNE STORY
  // ============================================
  @Delete(':id')
  deleteStory(@Param('id') id: string, @Request() req) {
    return this.storiesService.deleteStory(id, req.user.userId);
  }
}