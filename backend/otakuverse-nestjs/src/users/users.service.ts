import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { SupabaseService } from '../database/supabase.service';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { User } from './entities/user.entity';

@Injectable()
export class UsersService {
  constructor(private supabaseService: SupabaseService) {}

  async findById(id: string): Promise<User> {
    console.log(`🔍 Searching for user with ID: ${id}`);
    
    const { data, error } = await this.supabaseService
      .getClient()
      .from('users')
      .select('*')
      .eq('id', id)
      .single();

    if (error || !data) {
      console.error('❌ User not found:', error?.message);
      throw new NotFoundException(`User with ID ${id} not found`);
    }

    console.log('✅ User found:', data.username);
    return data;
  }

  async findByEmail(email: string): Promise<User | null> {
    console.log(`🔍 Searching for user with email: ${email}`);
    
    const { data, error } = await this.supabaseService
      .getClient()
      .from('users')
      .select('*')
      .eq('email', email)
      .single();

    if (error) {
      console.log('ℹ️  User not found by email');
      return null;
    }
    
    console.log('✅ User found by email:', data.username);
    return data;
  }

  async findByUsername(username: string): Promise<User | null> {
    console.log(`🔍 Searching for user with username: ${username}`);
    
    const { data, error } = await this.supabaseService
      .getClient()
      .from('users')
      .select('*')
      .eq('username', username)
      .single();

    if (error) {
      console.log('ℹ️  User not found by username');
      return null;
    }

    console.log('✅ User found by username:', data.username);
    return data;
  }

  async create(createUserDto: CreateUserDto): Promise<User> {
    console.log(`📝 Creating user: ${createUserDto.username}`);

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
        display_name: createUserDto.display_name || createUserDto.username,
      })
      .select()
      .single();

    if (error) {
      console.error('❌ Failed to create user:', error.message);
      throw new Error(`Failed to create user: ${error.message}`);
    }

    console.log('✅ User created successfully:', data.username);
    return data;
  }

  async update(id: string, updateUserDto: UpdateUserDto): Promise<User> {
    console.log(`📝 Updating user: ${id}`);

    const { data, error } = await this.supabaseService
      .getClient()
      .from('users')
      .update(updateUserDto)
      .eq('id', id)
      .select()
      .single();

    if (error) {
      console.error('❌ Failed to update user:', error.message);
      throw new Error(`Failed to update user: ${error.message}`);
    }

    console.log('✅ User updated successfully');
    return data;
  }

  async remove(id: string): Promise<void> {
    console.log(`🗑️  Deleting user: ${id}`);

    const { error } = await this.supabaseService
      .getClient()
      .from('users')
      .delete()
      .eq('id', id);

    if (error) {
      console.error('❌ Failed to delete user:', error.message);
      throw new Error(`Failed to delete user: ${error.message}`);
    }

    console.log('✅ User deleted successfully');
  }
}
// - findById(id): trouver par ID
// - findByEmail(email): trouver par email
// - findByUsername(username): trouver par username
// - create(dto): créer utilisateur
// - update(id, dto): modifier utilisateur
// - remove(id): supprimer utilisateur
