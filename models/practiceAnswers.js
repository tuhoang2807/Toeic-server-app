const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const PracticeAnswer = sequelize.define('PracticeAnswer', {
  answer_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  user_id: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  session_id: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  question_id: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  user_answer: {
    type: DataTypes.STRING(5),
    allowNull: true
  },
  is_correct: {
    type: DataTypes.BOOLEAN,
    allowNull: true
  },
  time_taken_seconds: {
    type: DataTypes.INTEGER,
    allowNull: true
  },
  answered_at: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW
  }
}, {
  tableName: 'practice_answers',
  timestamps: false
});


module.exports = PracticeAnswer;
