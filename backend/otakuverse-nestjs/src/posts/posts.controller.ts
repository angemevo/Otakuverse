// src/posts/posts.controller.ts

import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Param,
  Body,
  Request,
  UseGuards,
  Query,
} from '@nestjs/common';
import { PostsService } from './posts.service';
import { CreatePostDto } from './dto/create-post.dto';
import { UpdatePostDto } from './dto/update-post.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { Posts } from './entities/post.entity';

@Controller('posts')
@UseGuards(JwtAuthGuard)
export class PostsController {
  constructor(private readonly postsService: PostsService) {}

  // ============================================
  // CREATE
  // ============================================
  @Post()
  create(@Request() req, @Body() dto: CreatePostDto) {
    console.log('🔵 CREATE POST - req.user:', req.user);
    console.log('🔵 userId:', req.user.userId);
    return this.postsService.createPost(req.user.userId, dto);
  }

  // ============================================
  // GET ALL
  // ============================================
  @Get()
  async getAllPosts(
    @Query('limit') limit = 20,
    @Query('page') page = 1,
  ): Promise<Posts[]> {
    return this.postsService.getAllPosts();
  }

  // ✅ IMPORTANT : Routes spécifiques AVANT routes avec :id
  
  // ============================================
  // GET LIKED POSTS (MOI)
  // ============================================
  @Get('liked/me')
  getLikedPosts(@Request() req) {
    return this.postsService.getLikedPosts(req.user.userId);
  }

  // ============================================
  // GET POSTS BY USER
  // ============================================
  @Get('user/:userId')
  findByUser(@Param('userId') userId: string) {
    return this.postsService.getUserPosts(userId);
  }

  // ============================================
  // HAS LIKED (doit être AVANT @Get(':id'))
  // ============================================
  @Get(':id/liked')
  hasLiked(@Param('id') id: string, @Request() req) {
    console.log(`🔵 hasLiked called - post: ${id}, user: ${req.user.userId}`);
    return this.postsService.hasLiked(id, req.user.userId);
  }

  // ============================================
  // GET POST BY ID (après les routes spécifiques)
  // ============================================
  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.postsService.getPostById(id);
  }

  // ============================================
  // UPDATE
  // ============================================
  @Patch(':id')
  update(@Param('id') id: string, @Request() req, @Body() dto: UpdatePostDto) {
    return this.postsService.updatePost(id, req.user.userId, dto);
  }

  // ============================================
  // DELETE
  // ============================================
  @Delete(':id')
  remove(@Param('id') id: string, @Request() req) {
    return this.postsService.deletePost(id, req.user.userId);
  }

  // ============================================
  // TOGGLE LIKE
  // ============================================
  @Post(':id/like')
  toggleLike(@Param('id') id: string, @Request() req) {
    return this.postsService.toggleLike(id, req.user.userId);
  }

  // ============================================
  // PIN POST
  // ============================================
  @Post(':id/pin')
  pin(@Param('id') id: string, @Request() req) {
    return this.postsService.pinPost(id, req.user.userId);
  }

  // ============================================
  // INCREMENT VIEWS
  // ============================================
  @Post(':id/views')
  incrementViews(@Param('id') id: string) {
    return this.postsService.incrementViews(id);
  }

  // ============================================
  // INCREMENT SHARES
  // ============================================
  @Post(':id/shares')
  incrementShares(@Param('id') id: string) {
    return this.postsService.incrementShares(id);
  }
}