import { Module } from '@nestjs/common';
import { UsersService } from './users.service';

@Module({
  providers: [UsersService],
  // Consumed by AuthModule only.
  exports: [UsersService],
})
export class UsersModule {}
