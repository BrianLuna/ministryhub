import { describe, it, expect, beforeEach } from '@jest/globals';
import { db } from '../../src/db';
import { users } from '../../src/schema';
import { eq } from 'drizzle-orm';

describe('User Model', () => {
  beforeEach(async () => {
    // Clean up the database before each test
    await db.delete(users);
  });

  it('should create a new user', async () => {
    const newUser = {
      email: 'test@example.com',
      name: 'Test User',
      password: 'hashedpassword',
      createdBy: 'system',
      updatedBy: 'system'
    };

    const [user] = await db.insert(users).values(newUser).returning();
    
    expect(user).toBeDefined();
    expect(user.email).toBe(newUser.email);
    expect(user.name).toBe(newUser.name);
  });

  it('should find user by email', async () => {
    const testUser = {
      email: 'find@example.com',
      name: 'Find User',
      password: 'hashedpassword',
      createdBy: 'system',
      updatedBy: 'system'
    };

    await db.insert(users).values(testUser);
    const [foundUser] = await db
      .select()
      .from(users)
      .where(eq(users.email, testUser.email));

    expect(foundUser).toBeDefined();
    expect(foundUser.email).toBe(testUser.email);
  });
}); 