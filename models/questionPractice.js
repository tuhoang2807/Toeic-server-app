const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const QuestionPractice = sequelize.define('QuestionPractice', {
  question_id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true
  },
  skill_id: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  topic_id: {
    type: DataTypes.INTEGER,
    allowNull: true
  },
  question_text: {
    type: DataTypes.TEXT,
    allowNull: false
  },
  audio_url: {
    type: DataTypes.STRING(255),
    allowNull: true
  },
  image_url: {
    type: DataTypes.STRING(255),
    allowNull: true
  },
  options: {
    type: DataTypes.JSON,
    allowNull: false
  },
  correct_answer: {
    type: DataTypes.STRING(50),
    allowNull: false
  },
  explanation: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  is_active: {
    type: DataTypes.BOOLEAN,
    defaultValue: true
  },
  created_by: {
    type: DataTypes.INTEGER,
    allowNull: true
  },
  created_at: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW
  },
  updated_at: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW
  }
}, {
  tableName: 'questions_practice',
  timestamps: false,
  underscored: true
});

module.exports = QuestionPractice;
