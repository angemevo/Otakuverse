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
} from '@nestjs/common';
import { PostsService } from './posts.service';
import { CreatePostDto } from './dto/create-post.dto';
import { UpdatePostDto } from './dto/update-post.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';

@Controller('posts')
@UseGuards(JwtAuthGuard)
export class PostsController {
    constructor(private readonly postsService: PostsService) {}

    @Post()
    create(@Request() req, @Body() dto: CreatePostDto) {
        return this.postsService.createPost(req.user.id, dto);
    }

    @Get(':id')
    findOne(@Param('id') id: string) {
        return this.postsService.getPostById(id);
    }

    @Get('user/:userId')
    findByUser(@Param('userId') userId: string) {
        return this.postsService.getPostsByUser(userId);
    }

    @Patch(':id')
    update(@Param('id') id: string, @Request() req, @Body() dto: UpdatePostDto) {
        return this.postsService.updatePost(id, req.user.id, dto);
    }

    @Delete(':id')
    remove(@Param('id') id: string, @Request() req) {
        return this.postsService.deletePost(id, req.user.id);
    }

    @Get('liked/:userId')
    getLikedPosts(@Param('userId') userId: string) {
    return this.postsService.getLikedPosts(userId);
    }

    @Patch(':id/pin')
    pin(@Param('id') id: string, @Request() req) {
        return this.postsService.pinPost(id, req.user.id);
    }

    @Post(':id/like')
    toggleLike(@Param('id') id: string, @Request() req) {
        return this.postsService.toggleLike(id, req.user.id);
    }

    @Post(':id/comment')
    incrementComment(@Param('id') id: string) {
    return this.postsService.incrementComments(id);
    }
}
// - GET /posts (public, with pagination)
// - GET /posts/:id (public)
// - POST /posts (protected)
// - PUT /posts/:id (protected, owner only)
// - DELETE /posts/:id (protected, owner only)
// - GET /posts/feed (protected)
