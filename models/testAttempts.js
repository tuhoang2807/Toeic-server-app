const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const TestAttempt = sequelize.define('test_attempts', {
  attempt_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  user_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  test_set_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  total_questions: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  correct_answers: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
  },
  listening_score: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
  },
  reading_score: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
  },
  total_score: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
  },
  time_taken_seconds: {
    type: DataTypes.INTEGER,
  },
  started_at: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
  },
  completed_at: {
    type: DataTypes.DATE,
    allowNull: true,
  },
  status: {
    type: DataTypes.ENUM('in_progress', 'completed', 'abandoned'),
    defaultValue: 'in_progress',
  }
}, {
  tableName: 'test_attempts',
  timestamps: false
});

module.exports = TestAttempt;
