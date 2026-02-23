import { Module } from '@nestjs/common';
import { PostsService } from './posts.service';
import { PostsController } from './posts.controller';
import { SupabaseService } from '../database/supabase.service'; // 👈

@Module({
  controllers: [PostsController],
  providers: [PostsService, SupabaseService], 
})
export class PostsModule {}
// - Import DatabaseModule
// - Provider PostsService
