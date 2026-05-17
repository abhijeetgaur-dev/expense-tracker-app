# Expense Tracker Backend

This is the backend API for the Camera-First Expense Tracker application.

## 🛠️ Tech Stack & Database Choice

We chose a robust, modern, and highly scalable stack tailored for end-to-end type safety and developer productivity:

- **Express.js (TypeScript)**: A lightweight, fast, and flexible Node.js web framework. We use TypeScript to ensure strict type safety across our API routes, middleware, and services.
- **PostgreSQL**: A powerful, open-source relational database. We chose Postgres for its proven reliability, strict ACID compliance, and excellent support for relational data structures like users and expenses.
- **Drizzle ORM**: A high-performance, lightweight, and incredibly type-safe ORM. It allows us to define our database schema directly in TypeScript (`src/db/schema.ts`) and provides a SQL-like syntax without the bloat of traditional ORMs.
- **Supabase**: Configured as the managed PostgreSQL provider, offering a fast, serverless database experience that is easy to scale.
- **Firebase Admin SDK**: Used for secure, server-side JWT authentication token verification and Cloud Storage integration (for processing and saving scanned receipt images).

---

## 🚀 How to Run the Backend Locally

### 1. Prerequisites
Make sure you have the following installed on your machine:
- [Node.js](https://nodejs.org/) 
- [pnpm](https://pnpm.io/) package manager

### 2. Configure Environment Variables
In the `backend` directory, ensure you have a `.env` file configured with your local development keys. It should look like this:

```env
PORT=3000
DATABASE_URL=postgresql://<username>:<password>@<host>:5432/postgres
FIREBASE_STORAGE_BUCKET=your-firebase-project.appspot.com
GOOGLE_APPLICATION_CREDENTIALS=path/to/firebase-service-account.json
```

### 3. Install Dependencies
Open your terminal at the root of the project workspace and install the required packages:
```bash
pnpm install
```

### 4. Database Schema Setup
Navigate to the `backend` directory and push your Drizzle schema to the Postgres database. This will automatically create the necessary tables (like `expenses`):
```bash
cd backend
pnpm run db:generate
pnpm run db:push
```

### 5. Start the Development Server
Launch the backend with hot-reloading (powered by `tsx`):
```bash
pnpm run dev
```
The API server will start up and listen for requests at `http://localhost:3000`.
