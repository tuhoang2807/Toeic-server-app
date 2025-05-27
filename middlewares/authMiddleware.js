const jwt = require("jsonwebtoken");

const authenticate = (req, res, next) => {
  const token = req.cookies?.auth_token;

  if (!token) {
    return res.status(401).json({status: 401, error: "Phiên đăng nhập đã hết vui lòng đăng nhập lại" });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(401).json({ error: "Token không hợp lệ" });
  }
};

const isAdmin = (req, res, next) => {
  if (!req.user || req.user.role !== "admin") {
    return res.status(403).json({ error: "Yêu cầu quyền admin" });
  }
  next();
};

module.exports = { authenticate, isAdmin };
