import {
  Controller,
  Get,
  Put,
  Delete,
  Param,
  Body,
  UseGuards,
  ForbiddenException,
} from '@nestjs/common';
import { UsersService } from './users.service';
import { UpdateUserDto } from './dto/update-user.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';

@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get(':id')
  async getUser(@Param('id') id: string) {
    console.log(`\n📋 GET /users/${id}`);
    const user = await this.usersService.findById(id);
    
    return { user };
  }

  @Put(':id')
  @UseGuards(JwtAuthGuard)
  async updateUser(
    @Param('id') id: string,
    @Body() updateUserDto: UpdateUserDto,
    @CurrentUser() user: any,
  ) {
    console.log(`\n✏️  PUT /users/${id}`);

    if (user.userId !== id) {
      throw new ForbiddenException('Vous ne pouvez modifier que votre propre profil');
    }

    const updatedUser = await this.usersService.update(id, updateUserDto);
    
    return { user: updatedUser };
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard)
  async deleteUser(@Param('id') id: string, @CurrentUser() user: any) {
    console.log(`\n🗑️  DELETE /users/${id}`);

    if (user.userId !== id) {
      throw new ForbiddenException('Vous ne pouvez supprimer que votre propre compte');
    }

    await this.usersService.remove(id);
    
    return {
      success: true,
      message: 'Compte supprimé avec succès',
    };
  }
}