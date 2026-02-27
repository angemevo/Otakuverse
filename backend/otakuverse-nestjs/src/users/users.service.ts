import {
  Injectable,
  NotFoundException,
  ConflictException,
} from '@nestjs/common';
import { SupabaseService } from '../database/supabase.service';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { User } from './entities/user.entity';

@Injectable()
export class UsersService {
  constructor(private supabaseService: SupabaseService) {}

  async findById(id: string): Promise<User> {
    const { data, error } = await this.supabaseService
      .getClient()
      .from('users')
      .select('*')
      .eq('id', id)
      .single();

    if (error || !data) {
      throw new NotFoundException(`User with ID ${id} not found`);
    }

    return data;
  }

  async findByEmail(email: string): Promise<User | null> {
    const { data, error } = await this.supabaseService
      .getClient()
      .from('users')
      .select('*')
      .eq('email', email)
      .single();

    if (error) return null;

    return data;
  }

  async findByUsername(username: string): Promise<User | null> {
    const { data, error } = await this.supabaseService
      .getClient()
      .from('users')
      .select('*')
      .eq('username', username)
      .single();

    if (error) return null;

    return data;
  }

  async create(createUserDto: CreateUserDto): Promise<User> {
    const existingEmail = await this.findByEmail(createUserDto.email);
    if (existingEmail) {
      throw new ConflictException('Email already exists');
    }

    const existingUsername = await this.findByUsername(createUserDto.username);
    if (existingUsername) {
      throw new ConflictException('Username already taken');
    }

    const { data, error } = await this.supabaseService
      .getClient()
      .from('users')
      .insert({
        id: createUserDto.id,
        email: createUserDto.email,
        username: createUserDto.username,
        display_name: createUserDto.display_name ?? createUserDto.username,
        avatar_url: createUserDto.avatar_url ?? null,
        phone: createUserDto.phone ?? null,
        date_of_birth: createUserDto.date_of_birth ?? null,
        gender: createUserDto.gender ?? null,
        location: createUserDto.location ?? null,
      })
      .select()
      .single();

    if (error) {
      throw new Error(`Failed to create user: ${error.message}`);
    }

    return data;
  }

  async update(id: string, updateUserDto: UpdateUserDto): Promise<User> {
    const { data, error } = await this.supabaseService
      .getClient()
      .from('users')
      .update(updateUserDto)
      .eq('id', id)
      .select()
      .single();

    if (error) {
      throw new Error(`Failed to update user: ${error.message}`);
    }

    return data;
  }

  async remove(id: string): Promise<void> {
    const { error } = await this.supabaseService
      .getClient()
      .from('users')
      .delete()
      .eq('id', id);

    if (error) {
      throw new Error(`Failed to delete user: ${error.message}`);
    }
  }
}