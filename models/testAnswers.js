const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const TestAnswer = sequelize.define('test_answers', {
  answer_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  user_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  attempt_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  question_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  user_answer: {
    type: DataTypes.STRING(5),
    allowNull: true, // Có thể null nếu chưa trả lời
  },
  is_correct: {
    type: DataTypes.BOOLEAN,
    allowNull: true, // Có thể null nếu chưa trả lời
  },
  time_taken_seconds: {
    type: DataTypes.INTEGER,
  },
  answered_at: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
  }
}, {
  tableName: 'test_answers',
  timestamps: false
});

module.exports = TestAnswer;
