const { Router } = require('express');
const UserController = require('./user.controller');

const router = Router();

router.get('/', UserController.getUsers);
router.post('/', UserController.createUser);

module.exports = router;
