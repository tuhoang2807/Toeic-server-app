const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const TestSet = sequelize.define('TestSet', {
  test_set_id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true,
  },
  name: {
    type: DataTypes.STRING(100),
    allowNull: false,
  },
  type: {
    type: DataTypes.ENUM('mini_test', 'full_test'),
    allowNull: false,
  },
  total_questions: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  time_limit: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: true,
  },
  is_active: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
  },
  created_by: {
    type: DataTypes.INTEGER,
    allowNull: true,
    references: {
      model: 'users',
      key: 'user_id',
    },
    onDelete: 'SET NULL',
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
  tableName: 'test_sets',
  timestamps: false,
  underscored: true,
  hooks: {
    beforeUpdate: (testSet) => {
      testSet.updated_at = new Date();
    }
  }
});

module.exports = TestSet;
