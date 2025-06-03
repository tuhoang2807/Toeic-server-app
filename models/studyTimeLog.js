const { Sequelize, DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const StudyTimeLog = sequelize.define('study_time_log', {
  log_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  user_id: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  activity_type: {
    type: DataTypes.ENUM('practice', 'mini_test', 'full_test'),
    allowNull: false
  },
  skill_id: {
    type: DataTypes.INTEGER,
    allowNull: true
  },
  topic_id: {
    type: DataTypes.INTEGER,
    allowNull: true
  },
  session_id: {
    type: DataTypes.INTEGER,
    allowNull: true
  },
  study_time_minutes: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  study_date: {
    type: DataTypes.DATEONLY,
    allowNull: false
  },
  created_at: {
    type: DataTypes.DATE,
    defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
  }
}, {
  timestamps: false,
  tableName: 'study_time_log'
});

module.exports = StudyTimeLog;