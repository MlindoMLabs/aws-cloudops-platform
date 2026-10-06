const db = require('../../config/database');

const TaskModel = {
  async findAll() {
    const { rows } = await db.query(
      'SELECT id, title, description, status, user_id, created_at, updated_at FROM tasks ORDER BY created_at DESC'
    );
    return rows;
  },

  async findById(id) {
    const { rows } = await db.query(
      'SELECT id, title, description, status, user_id, created_at, updated_at FROM tasks WHERE id = $1',
      [id]
    );
    return rows[0];
  },

  async findByUserId(userId) {
    const { rows } = await db.query(
      'SELECT id, title, description, status, user_id, created_at, updated_at FROM tasks WHERE user_id = $1 ORDER BY created_at DESC',
      [userId]
    );
    return rows;
  },

  async create({ title, description, status = 'pending', userId }) {
    const { rows } = await db.query(
      `INSERT INTO tasks (title, description, status, user_id)
       VALUES ($1, $2, $3, $4)
       RETURNING id, title, description, status, user_id, created_at, updated_at`,
      [title, description, status, userId]
    );
    return rows[0];
  },

  async update(id, { title, description, status }) {
    const { rows } = await db.query(
      `UPDATE tasks
       SET title = COALESCE($1, title),
           description = COALESCE($2, description),
           status = COALESCE($3, status),
           updated_at = CURRENT_TIMESTAMP
       WHERE id = $4
       RETURNING id, title, description, status, user_id, created_at, updated_at`,
      [title, description, status, id]
    );
    return rows[0];
  },

  async delete(id) {
    const { rows } = await db.query(
      'DELETE FROM tasks WHERE id = $1 RETURNING id',
      [id]
    );
    return rows[0];
  }
};

module.exports = TaskModel;
