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
