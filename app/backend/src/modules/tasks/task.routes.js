const { Router } = require('express');
const router = Router();

// Placeholder route for tasks
router.get('/', (req, res) => {
  res.json({ success: true, data: [], message: 'Task endpoint active' });
});

module.exports = router;

const { Router } = require('express');
const TaskController = require('./task.controller');

const router = Router();

router.get('/', TaskController.getAllTasks);
router.get('/:id', TaskController.getTaskById);
router.post('/', TaskController.createTask);
router.put('/:id', TaskController.updateTask);
router.delete('/:id', TaskController.deleteTask);

module.exports = router;
