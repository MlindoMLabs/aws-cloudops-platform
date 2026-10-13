const UserModel = require('./user.model');

const UserController = {
  async getUsers(req, res, next) {
    try {
      const users = await UserModel.findAll();
      res.json({ success: true, data: users });
    } catch (error) {
      next(error);
    }
  },

  async createUser(req, res, next) {
    try {
      const { name, email } = req.body;
      const newUser = await UserModel.create({ name, email });
      res.status(201).json({ success: true, data: newUser });
    } catch (error) {
      next(error);
    }
  },
};

module.exports = UserController;
