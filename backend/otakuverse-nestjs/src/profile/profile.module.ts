import { Module } from '@nestjs/common';
import { SupabaseService } from '../database/supabase.service';
import { ProfilesController } from './profile.controller';
import { ProfilesService } from './profile.service';

@Module({
  controllers: [ProfilesController],
  providers: [ProfilesService, SupabaseService],
  exports: [ProfilesService],
})
export class ProfilesModule {}