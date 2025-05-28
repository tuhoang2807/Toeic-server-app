const User = require("../models/user");
const bcrypt = require("bcrypt");
const { Op } = require("sequelize");

class UserService {
  async getUserById(userId) {
    const user = await User.findByPk(userId, {
      attributes: {
        exclude: ["password_hash", "reset_token", "reset_token_expires"],
      },
    });
    if (!user) throw new Error("Người dùng không tồn tại");
    return user;
  }

  async getUserByEmail(email) {
    return await User.findOne({ where: { email } });
  }

  async getUserByUsername(username) {
    return await User.findOne({ where: { username } });
  }

  // Tạo người dùng mới
  async createUser({ username, email, password, full_name, phone }) {
    const existingUser = await this.getUserByEmail(email);
    if (existingUser) throw new Error("Email đã tồn tại");

    const existingUsername = await User.findOne({ where: { username } });
    if (existingUsername) throw new Error("Tên đăng nhập đã tồn tại");

    const password_hash = await bcrypt.hash(password, 10);
    return await User.create({
      username,
      email,
      password_hash,
      full_name,
      phone,
      role: "user",
      email_verified: false,
    });
  }
  async updateUser(userId, data) {
    const { username, full_name, avatar_url, phone, birth_date, email } = data;
    const user = await User.findByPk(userId);
    if (!user) {
      throw new Error("Tài khoản không tồn tại, hãy đăng nhập để tiếp tục");
    }

    const uniqueFields = { username, email, phone };
    for (const [field, value] of Object.entries(uniqueFields)) {
      if (value) {
        const existingUser = await User.findOne({
          where: {
            [field]: value,
            user_id: { [Op.ne]: userId }, // Thay đổi từ id thành user_id
          },
        });
        if (existingUser) {
          const fieldName =
            field === "phone"
              ? "Số điện thoại"
              : field === "email"
              ? "Email"
              : "Username";
          throw new Error(`${fieldName} đã được sử dụng`);
        }
      }
    }

    await user.update({
      username: username ?? user.username,
      full_name: full_name ?? user.full_name,
      avatar_url: avatar_url ?? user.avatar_url,
      phone: phone ?? user.phone,
      birth_date: birth_date ?? user.birth_date,
      email: email ?? user.email,
    });

    return this.getUserById(userId);
  }

  async changePassword(userId, oldPassword, newPassword) {
    const user = await User.findByPk(userId);
    if (!user) throw new Error("Người dùng không tồn tại");

    const isMatch = await bcrypt.compare(oldPassword, user.password_hash);
    if (!isMatch) throw new Error("Mật khẩu cũ không đúng");
    if (newPassword.length < 6)
      throw new Error("Mật khẩu mới phải có ít nhất 6 ký tự");
    if (newPassword === oldPassword)
      throw new Error("Mật khẩu mới không được trùng với mật khẩu cũ");
    const hashedPassword = await bcrypt.hash(newPassword, 10);
    await user.update({ password_hash: hashedPassword });
    return { message: "Đổi mật khẩu thành công" };
  }

  // Admin: Lấy danh sách người dùng
  async getAllUsers({ limit = 10, offset = 0, role, search }) {
    const where = {};
    if (role) where.role = role;
    if (search) {
      where[Op.or] = [
        { username: { [Op.like]: `%${search}%` } },
        { email: { [Op.like]: `%${search}%` } },
        { full_name: { [Op.like]: `%${search}%` } },
      ];
    }
    return await User.findAndCountAll({
      where,
      attributes: {
        exclude: ["password_hash", "reset_token", "reset_token_expires"],
      },
      limit: parseInt(limit),
      offset: parseInt(offset),
    });
  }

  // Admin: Kích hoạt hoặc vô hiệu hóa người dùng
  async toggleUserActive(userId, isActive) {
    const user = await User.findByPk(userId);
    if (!user) throw new Error("Người dùng không tồn tại");
    await user.update({ is_active: isActive });
    return this.getUserById(userId);
  }

  // Cập nhật token reset mật khẩu
  async updateResetToken(email, token, expires) {
    const user = await this.getUserByEmail(email);
    if (!user) throw new Error("Email không tồn tại");
    await user.update({
      reset_token: token,
      reset_token_expires: expires,
    });
    return user;
  }

  // Reset mật khẩu
  async resetPassword(token, newPassword) {
    const user = await User.findOne({
      where: {
        reset_token: token,
        reset_token_expires: { [Op.gt]: new Date() },
      },
    });
    if (!user) throw new Error("Token không hợp lệ hoặc đã hết hạn");

    const password_hash = await bcrypt.hash(newPassword, 10);
    await user.update({
      password_hash,
      reset_token: null,
      reset_token_expires: null,
    });
    return { message: "Đặt lại mật khẩu thành công" };
  }

  async deleteUser(userId) {
    const user = await User.findByPk(userId);
    if (!user) throw new Error("Người dùng không tồn tại");
    await user.destroy();
    return { message: "Tài khoản đã được xóa thành công" };
  }
}

module.exports = new UserService();
