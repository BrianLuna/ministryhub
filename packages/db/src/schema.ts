import { pgTable, serial, text, timestamp } from 'drizzle-orm/pg-core';

export const users = pgTable('users', {
  id: serial('id').primaryKey(),
  clerkId: text('clerk_id').notNull().unique(),
  email: text('email').notNull().unique(),
  name: text('name').notNull(),
  photoUrl: text('photo_url'),
  lastSignInAt: timestamp('last_sign_in_at'),
  createdAt: timestamp('created_at').defaultNow().notNull(),
  createdBy: text('created_by').notNull(),
  updatedAt: timestamp('updated_at').defaultNow().notNull(),
  updatedBy: text('updated_by').notNull(),
});