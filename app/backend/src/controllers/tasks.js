const db = require('../services/db');

const getTasks = async (req, res) => {
  try {
    const { rows } = await db.query('SELECT * FROM tasks ORDER BY created_at DESC');
    res.json({ success: true, count: rows.length, data: rows });
  } catch (error) {
    console.error('Error fetching tasks:', error.message);
    res.status(500).json({ success: false, error: 'Failed to retrieve tasks' });
  }
};

const createTask = async (req, res) => {
  const { title, description } = req.body;
  if (!title) {
    return res.status(400).json({ success: false, error: 'Task title is required' });
  }

  try {
    const query = 'INSERT INTO tasks (title, description) VALUES ($1, $2) RETURNING *';
    const { rows } = await db.query(query, [title, description || '']);
    res.status(201).json({ success: true, data: rows[0] });
  } catch (error) {
    console.error('Error creating task:', error.message);
    res.status(500).json({ success: false, error: 'Failed to create task' });
  }
};

const deleteTask = async (req, res) => {
  const { id } = req.params;
  try {
    const result = await db.query('DELETE FROM tasks WHERE id = $1 RETURNING *', [id]);
    if (result.rowCount === 0) {
      return res.status(404).json({ success: false, error: 'Task not found' });
    }
    res.json({ success: true, message: `Task ${id} deleted successfully` });
  } catch (error) {
    console.error('Error deleting task:', error.message);
    res.status(500).json({ success: false, error: 'Failed to delete task' });
  }
};

module.exports = { getTasks, createTask, deleteTask };
