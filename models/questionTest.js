const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const QuestionTest = sequelize.define('questions_test', {
  question_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  test_set_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  part_number: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  question_number: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  question_text: {
    type: DataTypes.TEXT,
    allowNull: false,
  },
  audio_url: {
    type: DataTypes.STRING(255),
  },
  image_url: {
    type: DataTypes.STRING(255),
  },
  passage_text: {
    type: DataTypes.TEXT,
  },
  options: {
    type: DataTypes.JSON,
    allowNull: false,
  },
  correct_answer: {
    type: DataTypes.STRING(5),
    allowNull: false,
  },
  explanation: {
    type: DataTypes.TEXT,
  },
  is_active: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
  },
  created_by: {
    type: DataTypes.INTEGER,
    allowNull: true,
  },
  created_at: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
  },
  updated_at: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
  },
}, {
  tableName: 'questions_test',
  timestamps: false, 
  indexes: [
    {
      unique: true,
      fields: ['test_set_id', 'question_number']
    }
  ]
});

module.exports = QuestionTest;
