import { Module } from '@nestjs/common';
import { UsersService } from './users.service';
import { UsersController } from './users.controller';  // ← AJOUTER

@Module({
  controllers: [UsersController],  // ← IMPORTANT
  providers: [UsersService],
  exports: [UsersService],
})
export class UsersModule {}
// - Import DatabaseModule
// - Provider UsersService
// - Export UsersService
