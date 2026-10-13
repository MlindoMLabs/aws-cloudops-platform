const express = require('express');
const cors = require('cors');
require('dotenv').config();

const db = require('./services/db');
const taskRoutes = require('./routes/tasks');

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors());
app.use(express.json());

// Liveness Probe (Used by ECS/Docker & ALB target health)
app.get('/live', (req, res) => {
  res.status(200).json({ status: 'UP', timestamp: new Date().toISOString() });
});

// Readiness Probe (Deep Health Check via Database ping)
app.get('/healthz', async (req, res) => {
  try {
    await db.query('SELECT 1');
    res.status(200).json({ status: 'HEALTHY', database: 'CONNECTED' });
  } catch (err) {
    res.status(503).json({ status: 'UNHEALTHY', database: 'DISCONNECTED', error: err.message });
  }
});

// API Routes
app.use('/api/v1/tasks', taskRoutes);

// Automatic DB Schema Verification / Bootstrap
const initDb = async () => {
  const schema = `
    CREATE TABLE IF NOT EXISTS tasks (
      id SERIAL PRIMARY KEY,
      title VARCHAR(255) NOT NULL,
      description TEXT,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
    );
  `;
  try {
    await db.query(schema);
    console.log('[DB] Table "tasks" verified/created successfully.');
  } catch (err) {
    console.warn('[DB] Schema setup deferred (Database connection pending startup):', err.message);
  }
};

app.listen(PORT, async () => {
  console.log(`[SERVER] Backend operational on port ${PORT} [Mode: ${process.env.NODE_ENV || 'development'}]`);
  await initDb();
});


const express = require('express');
const cors = require('cors');

// Import Module Routes
const userRoutes = require('./modules/users/user.routes');
const taskRoutes = require('./modules/tasks/task.routes');

const app = express();

// --- Core Middleware ---
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// --- Health Check Endpoint ---
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'UP',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development'
  });
});

// --- Mount Feature Module Routes ---
app.use('/api/v1/users', userRoutes);
app.use('/api/v1/tasks', taskRoutes);

// --- 404 Route Not Found Handler ---
app.use((req, res, next) => {
  res.status(404).json({
    success: false,
    error: `Cannot ${req.method} ${req.originalUrl}`
  });
});

// --- Global Centralized Error Handler ---
app.use((err, req, res, next) => {
  console.error('Unhandled Error:', err);

  const statusCode = err.statusCode || 500;
  const message = err.message || 'Internal Server Error';

  res.status(statusCode).json({
    success: false,
    error: message,
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  });
});

module.exports = app;
