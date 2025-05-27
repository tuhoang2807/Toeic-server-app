const UserService = require("../services/userService");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const crypto = require("crypto");

class AuthController {
  async register(req, res) {
    try {
      const { username, email, password, full_name, phone } = req.body;

      if (!username || !email || !password || !full_name) {
        return res.status(400).json({
          status: 400,
          error: "Vui lòng nhập đầy đủ thông tin bắt buộc",
        });
      }

      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      if (!emailRegex.test(email)) {
        return res
          .status(400)
          .json({ status: 400, error: "Email không hợp lệ" });
      }

      if (password.length < 6) {
        return res
          .status(400)
          .json({ status: 400, error: "Mật khẩu phải có ít nhất 6 ký tự" });
      }

      if (phone && !/^[0-9+\-\s]*$/.test(phone)) {
        return res.status(400).json({
          status: 400,
          error: "Số điện thoại chỉ được chứa số, dấu +, -, và khoảng trắng",
        });
      }

      const existingUser = await UserService.getUserByEmail(email);
      if (existingUser) {
        return res
          .status(400)
          .json({ status: 400, error: "Email đã được sử dụng" });
      }

      const existingUsername = await UserService.getUserByUsername(username);
      if (existingUsername) {
        return res
          .status(400)
          .json({ status: 400, error: "Tên đăng nhập đã được sử dụng" });
      }

      await UserService.createUser({
        username,
        email,
        password,
        full_name,
        phone,
      });

      return res
        .status(201)
        .json({ status: 201, message: "Đăng ký thành công" });
    } catch (error) {
      console.error("Đăng ký thất bại:", error);
      return res
        .status(500)
        .json({ status: 500, error: "Đã xảy ra lỗi trong quá trình đăng ký" });
    }
  }

  async login(req, res) {
    try {
      const { username, password } = req.body;
      if (!username || !password) {
        return res
          .status(400)
          .json({
            status: 400,
            error: "Vui lòng nhập đầy đủ thông tin bắt buộc",
          });
      }

      if (password.length < 6) {
        return res
          .status(400)
          .json({ status: 400, error: "Mật khẩu phải có ít nhất 6 ký tự" });
      }

      const user = await UserService.getUserByUsername(username);
      if (!user || !user.is_active) {
        return res
          .status(401)
          .json({
            status: 400,
            error: "Người dùng không tồn tại hoặc bị vô hiệu hóa",
          });
      }

      const isMatch = await bcrypt.compare(password, user.password_hash);
      if (!isMatch) {
        return res
          .status(401)
          .json({ status: 401, error: "Mật khẩu không đúng" });
      }

      const token = jwt.sign(
        { user_id: user.user_id, role: user.role },
        process.env.JWT_SECRET,
        { expiresIn: "1d" }
      );

      res.cookie("auth_token", token, {
        httpOnly: true,
        secure: process.env.NODE_ENV === "production",
        maxAge: 24 * 60 * 60 * 1000,
        sameSite: "Strict",
      });

      res.status(200).json({
        status: 200,
        token,
        user: {
          userId: user.user_id,
          userName: user.username,
          role: user.role,
        },
        message: "Đăng nhập thành công",
      });
    } catch (error) {
      console.error("Đăng nhập lỗi:", error);
      res
        .status(500)
        .json({ error: "Đã xảy ra lỗi trong quá trình đăng nhập" });
    }
  }

  async logout(req, res) {
    try {
      res.clearCookie("auth_token", {
        httpOnly: true,
        secure: process.env.NODE_ENV === "production",
        sameSite: "Strict",
      });

      res.status(200).json({
        status: 200,
        message: "Đăng xuất thành công",
      });
    } catch (error) {
      console.error("Đăng xuất lỗi:", error);
      res.status(500).json({
        status: 500,
        error: "Đã xảy ra lỗi trong quá trình đăng xuất",
      });
    }
  }

  async forgotPassword(req, res) {
    try {
      const { email } = req.body;
      if (!email) throw new Error("Vui lòng cung cấp email");

      const token = crypto.randomBytes(32).toString("hex");
      const expires = new Date(Date.now() + 3600000); // Hết hạn sau 1 giờ
      await UserService.updateResetToken(email, token, expires);

      await sendEmail({
        to: email,
        subject: "Đặt lại mật khẩu - TOEIC App",
        text: `Đặt lại mật khẩu tại: ${process.env.APP_URL}/reset-password?token=${token}`,
      });

      res.status(200).json({ message: "Email đặt lại mật khẩu đã được gửi" });
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  async resetPassword(req, res) {
    try {
      const { token, newPassword } = req.body;
      if (!token || !newPassword)
        throw new Error("Vui lòng cung cấp token và mật khẩu mới");

      const result = await UserService.resetPassword(token, newPassword);
      res.status(200).json(result);
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }
}

module.exports = new AuthController();
