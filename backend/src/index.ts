import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import expenseRoutes from './routes/expenses';

dotenv.config();

const app = express();
const port = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'OK', message: 'Camera-First Expense Tracker API is running' });
});

// Expense Routes
app.use('/expenses', expenseRoutes);

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
