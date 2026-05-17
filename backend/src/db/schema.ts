import { pgTable, uuid, varchar, text, timestamp, real } from 'drizzle-orm/pg-core';

export const expenses = pgTable('expenses', {
  id: uuid('id').defaultRandom().primaryKey(),
  userId: varchar('user_id', { length: 255 }).notNull(),
  amount: real('amount').notNull(),
  category: varchar('category', { length: 100 }).notNull(),
  note: text('note'),
  date: timestamp('date').notNull().defaultNow(),
  imageUrl: varchar('image_url', { length: 512 }),
  syncStatus: varchar('sync_status', { length: 50 }).default('synced'),
  createdAt: timestamp('created_at').defaultNow(),
  updatedAt: timestamp('updated_at').defaultNow(),
});
