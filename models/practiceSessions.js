const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const PracticeSession = sequelize.define('PracticeSession', {
  session_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  user_id: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  skill_id: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  topic_id: {
    type: DataTypes.INTEGER,
    allowNull: true
  },
  total_questions: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  correct_answers: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  total_time_seconds: {
    type: DataTypes.INTEGER,
    allowNull: true
  },
  score: {
    type: DataTypes.DECIMAL(5, 2),
    allowNull: true
  },
  completed_at: {
    type: DataTypes.DATE,
    allowNull: true
  },
  created_at: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW
  }
}, {
  tableName: 'practice_sessions',
  timestamps: false
});

module.exports = PracticeSession;
