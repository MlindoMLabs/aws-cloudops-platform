const db = require('../../config/database');

const UserModel = {
  async findAll() {
    const { rows } = await db.query('SELECT id, name, email, created_at FROM users ORDER BY created_at DESC');
    return rows;
  },

  async findById(id) {
    const { rows } = await db.query('SELECT id, name, email, created_at FROM users WHERE id = $1', [id]);
    return rows[0];
  },

  async create({ name, email }) {
    const { rows } = await db.query(
      'INSERT INTO users (name, email) VALUES ($1, $2) RETURNING id, name, email, created_at',
      [name, email]
    );
    return rows[0];
  },
};

module.exports = UserModel;
