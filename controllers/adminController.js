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

  async updateUser(req, res) {
    try {
      const { userId } = req.params;
      const {
        username,
        full_name,
        avatar_url,
        phone,
        birth_date,
        email,
      } = req.body;
      const updatedUser = await UserService.updateUser(userId, {
        username,
        full_name,
        avatar_url,
        phone,
        birth_date,
        email,
      });

      res.status(200).json({
        status: 200,
        message: "Cập nhật người dùng thành công",
        data: updatedUser,
      });
    } catch (error) {
      res.status(400).json({ status: 400, error: error.message });
    }
  }

  async deleteUser(req, res) {
    try {
      const { userId } = req.params;
      await UserService.deleteUser(userId);
      res.status(200).json({
        status: 200,
        message: "Người dùng đã được xóa thành công",
      });
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
