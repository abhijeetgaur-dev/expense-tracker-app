import { Router } from 'express';
import multer from 'multer';
import { getExpenses, createExpense, deleteExpense } from '../controllers/expensesController';
import { authMiddleware } from '../middlewares/auth';

const router = Router();
const upload = multer({ storage: multer.memoryStorage() });

// All expense routes require authentication
router.use(authMiddleware as any);

router.get('/', getExpenses as any);
router.post('/', upload.single('image'), createExpense as any);
router.delete('/:id', deleteExpense as any);

export default router;
