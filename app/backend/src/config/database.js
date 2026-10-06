// backend/src/config/db.js
const { SecretsManagerClient, GetSecretValueCommand } = require("@aws-sdk/client-secrets-manager");
const { Pool } = require("pg");

let pool;

/**
 * Retrieves database config either from AWS Secrets Manager or local environment variables
 */
async function getDbConfig() {
  // If local DATABASE_URL or POSTGRES_HOST exists, use environment variables directly
  if (process.env.DATABASE_URL) {
    return { connectionString: process.env.DATABASE_URL };
  }

  const secretName = process.env.SECRET_NAME || "cloudops/rds/postgres-credentials";
  const region = process.env.AWS_REGION || "us-east-1";
  const client = new SecretsManagerClient({ region });

  try {
    const response = await client.send(
      new GetSecretValueCommand({ SecretId: secretName })
    );

    if (response.SecretString) {
      const creds = JSON.parse(response.SecretString);
      return {
        host: creds.host,
        port: creds.port,
        database: creds.dbname,
        user: creds.username,
        password: creds.password,
        ssl: { rejectUnauthorized: false }, // Required for AWS RDS connections
      };
    }
  } catch (error) {
    console.error("Error retrieving secret from AWS Secrets Manager:", error);
    throw error;
  }
}

/**
 * Returns or creates a singleton pg Pool instance
 */
async function getPool() {
  if (!pool) {
    const dbConfig = await getDbConfig();
    pool = new Pool(dbConfig);
  }
  return pool;
}

/**
 * Initializes database schema on application start
 */
async function initDb() {
  const dbPool = await getPool();
  const queryText = `
    CREATE TABLE IF NOT EXISTS tasks (
      id SERIAL PRIMARY KEY,
      title VARCHAR(255) NOT NULL,
      description TEXT,
      status VARCHAR(50) DEFAULT 'pending',
      user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
    );
  `;

  try {
    await dbPool.query(queryText);
    console.log("Tasks table initialized successfully");
  } catch (err) {
    console.error("Error initializing tasks table:", err);
    throw err;
  }
}

module.exports = { getPool, initDb };
