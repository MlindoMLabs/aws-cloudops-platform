const TaskModel = require('./task.model');

const TaskController = {
  async getAllTasks(req, res, next) {
    try {
      const { userId } = req.query;
      const tasks = userId
        ? await TaskModel.findByUserId(userId)
        : await TaskModel.findAll();

      res.status(200).json({ success: true, data: tasks });
    } catch (error) {
      next(error);
    }
  },

  async getTaskById(req, res, next) {
    try {
      const { id } = req.params;
      const task = await TaskModel.findById(id);

      if (!task) {
        return res.status(404).json({ success: false, error: 'Task not found' });
      }

      res.status(200).json({ success: true, data: task });
    } catch (error) {
      next(error);
    }
  },

  async createTask(req, res, next) {
    try {
      const { title, description, status, userId } = req.body;

      if (!title || !userId) {
        return res.status(400).json({
          success: false,
          error: 'Title and userId are required fields'
        });
      }

      const newTask = await TaskModel.create({ title, description, status, userId });
      res.status(201).json({ success: true, data: newTask });
    } catch (error) {
      next(error);
    }
  },

  async updateTask(req, res, next) {
    try {
      const { id } = req.params;
      const { title, description, status } = req.body;

      const existingTask = await TaskModel.findById(id);
      if (!existingTask) {
        return res.status(404).json({ success: false, error: 'Task not found' });
      }

      const updatedTask = await TaskModel.update(id, { title, description, status });
      res.status(200).json({ success: true, data: updatedTask });
    } catch (error) {
      next(error);
    }
  },

  async deleteTask(req, res, next) {
    try {
      const { id } = req.params;

      const deletedTask = await TaskModel.delete(id);
      if (!deletedTask) {
        return res.status(404).json({ success: false, error: 'Task not found' });
      }

      res.status(200).json({ success: true, message: 'Task deleted successfully' });
    } catch (error) {
      next(error);
    }
  }
};

module.exports = TaskController;
