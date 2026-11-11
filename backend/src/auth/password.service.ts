import { Injectable } from '@nestjs/common';
import { randomBytes, scrypt as scryptCallback, timingSafeEqual } from 'crypto';
import { promisify } from 'util';

const scrypt = promisify(scryptCallback) as (
  password: string,
  salt: Buffer,
  keyLength: number,
) => Promise<Buffer>;

const KEY_LENGTH = 64;
const SALT_LENGTH = 16;

// Password hashing using Node's built-in scrypt — a memory-hard key
// derivation function designed to make large-scale password cracking
// expensive. Zero extra dependencies. Stored format is
// "<salt hex>:<hash hex>", so the salt travels with the hash and every user
// gets a different one (identical passwords never produce identical hashes).
@Injectable()
export class PasswordService {
  async hash(password: string): Promise<string> {
    const salt = randomBytes(SALT_LENGTH);
    const derived = await scrypt(password, salt, KEY_LENGTH);
    return `${salt.toString('hex')}:${derived.toString('hex')}`;
  }

  async verify(password: string, stored: string): Promise<boolean> {
    const [saltHex, hashHex] = stored.split(':');
    if (!saltHex || !hashHex) return false;

    const expected = Buffer.from(hashHex, 'hex');
    const derived = await scrypt(
      password,
      Buffer.from(saltHex, 'hex'),
      expected.length,
    );

    // timingSafeEqual compares in constant time, so response timing can't
    // leak how many leading bytes of a guess were correct.
    return timingSafeEqual(derived, expected);
  }
}
