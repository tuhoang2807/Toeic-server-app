const UserService = require("../services/userService");

class AdminController {
  async getAllUsers(req, res) {
    try {
      const { limit, offset, role, search } = req.query;
      const users = await UserService.getAllUsers({
        limit,
        offset,
        role,
        search,
      });
      res.status(200).json(users);
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  async toggleUserActive(req, res) {
    try {
      const { userId } = req.params;
      const { isActive } = req.body;
      if (typeof isActive !== "boolean")
        throw new Error("isActive phải là boolean");
      const user = await UserService.toggleUserActive(userId, isActive);
      res.status(200).json(user);
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }  
}



module.exports = new AdminController();
