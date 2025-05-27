const express = require('express');
require('dotenv').config();
const cookieParser = require('cookie-parser');
const authRoutes = require("./routes/authRoutes");
const userRoutes = require("./routes/userRoutes");
const topicRoutes = require("./routes/topicRoutes");
const adminRoutes = require("./routes/adminRoutes");
const skillRoutes = require("./routes/skillRoutes");
const practiceRoutes = require("./routes/questionPracticeRoute");

const app = express();
const PORT = process.env.PORT || 8000;

app.use(express.json());
app.use(cookieParser());



app.use('/api/admin', adminRoutes);
app.use("/api/auth", authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/topics', topicRoutes);
app.use('/api/skills', skillRoutes);
app.use('/api/practice', practiceRoutes);


app.get('/', (req, res) => {
  res.json({ message: 'TOEIC App đang chạy...' });
});

app.listen(PORT, () => {
  console.log(`🚀 Server đang chạy tại http://localhost:${PORT}`);
});
