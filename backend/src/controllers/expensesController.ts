import { Request, Response } from 'express';
import { AuthRequest } from '../middlewares/auth';
import * as expenseService from '../services/expenseService';
import * as storageService from '../services/storageService';

export const getExpenses = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const userId = req.user?.uid;
    if (!userId) {
      res.status(401).json({ error: 'Unauthorized' });
      return;
    }

    const userExpenses = await expenseService.getExpensesByUser(userId);
    res.json(userExpenses);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Failed to fetch expenses' });
  }
};

export const createExpense = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const userId = req.user?.uid;
    if (!userId) {
      res.status(401).json({ error: 'Unauthorized' });
      return;
    }

    const { amount, category, note, date, id } = req.body;
    let imageUrl = '';

    if (req.file) {
      imageUrl = await storageService.uploadImage(req.file.buffer, req.file.mimetype);
    }

    const newExpense = await expenseService.createExpense({
      id: id, // ID comes from frontend to ensure sync doesn't duplicate
      userId,
      amount: parseFloat(amount),
      category,
      note,
      date: new Date(date),
      imageUrl,
      syncStatus: 'synced',
    });

    res.status(201).json(newExpense);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Failed to create expense' });
  }
};

export const deleteExpense = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const userId = req.user?.uid;
    if (!userId) {
      res.status(401).json({ error: 'Unauthorized' });
      return;
    }

    const { id } = req.params;
    if (typeof id !== 'string') {
      res.status(400).json({ error: 'Invalid expense ID' });
      return;
    }
    await expenseService.deleteExpense(id, userId);
    res.status(200).json({ message: 'Deleted successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Failed to delete expense' });
  }
};
