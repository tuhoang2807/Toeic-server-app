const UserService = require("../services/userService");
const AuthController = require("./authController");
class UserController {
  async getProfile(req, res) {
    try {
      const userId = req.user.user_id;
      const user = await UserService.getUserById(userId);
      res.status(200).json(user);
    } catch (error) {
      res.status(400).json({ status: 400, error: error.message });
    }
  }

  async updateProfile(req, res) {
    try {
      const userId = req.user.user_id;
      const { username, full_name, avatar_url, phone, birth_date, email } =
        req.body;
      const updatedUser = await UserService.updateUser(userId, {
        username,
        full_name,
        avatar_url,
        phone,
        birth_date,
        email,
      });
      res.status(200).json(updatedUser);
    } catch (error) {
      res.status(400).json({ status: 400, error: error.message });
    }
  }

  async changePassword(req, res) {
    try {
      const userId = req.user.user_id;
      const { oldPassword, newPassword } = req.body;
      if (!oldPassword || !newPassword)
        throw new Error("Vui lòng cung cấp mật khẩu cũ và mới");
      const result = await UserService.changePassword(
        userId,
        oldPassword,
        newPassword
      );
      res.status(200).json({ status: 200, result });
    } catch (error) {
      res.status(400).json({ status: 400, error: error.message });
    }
  }

  async deleteAccount(req, res) {
    try {
      const userId = req.user.user_id;
      await UserService.deleteUser(userId);
      await AuthController.logout(req, res);
      res.status(200).json({ status: 200, message: "Tài khoản đã xóa" });
    } catch (error) {
      res.status(400).json({ status: 400, error: error.message });
    }
  }
}

module.exports = new UserController();
