require('dotenv').config();
const app = require('./app');
const { initDbPool } = require('./config/database');

const PORT = process.env.PORT || 3000;

async function startServer() {
  try {
    // 1. Initialize Database Connection / AWS Secrets Manager
    console.log('Connecting to PostgreSQL database...');
    await initDbPool();
    console.log('Database connection pool established successfully.');

    // 2. Start Express Server
    app.listen(PORT, () => {
      console.log(`Server listening on port ${PORT} [${process.env.NODE_ENV || 'development'}]`);
    });
  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
  }
}

// Handle unhandled rejections and uncaught exceptions
process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason);
});

process.on('uncaughtException', (error) => {
  console.error('Uncaught Exception thrown:', error);
  process.exit(1);
});

startServer();
