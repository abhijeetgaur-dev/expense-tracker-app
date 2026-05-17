import { db } from '../db';
import { expenses } from '../db/schema';
import { eq, desc, and } from 'drizzle-orm';

export const createExpense = async (data: any) => {
  const result = await db.insert(expenses).values(data).returning();
  return result[0];
};

export const getExpensesByUser = async (userId: string) => {
  const result = await db
    .select()
    .from(expenses)
    .where(eq(expenses.userId, userId))
    .orderBy(desc(expenses.date));
  return result;
};

export const deleteExpense = async (id: string, userId: string) => {
  const result = await db
    .delete(expenses)
    .where(and(eq(expenses.id, id), eq(expenses.userId, userId)))
    .returning();
  return result[0];
};
