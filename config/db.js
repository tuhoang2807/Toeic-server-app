const { Sequelize } = require('sequelize');
require('dotenv').config();

const sequelize = new Sequelize(
  process.env.DB_NAME,    
  process.env.DB_USER,     
  process.env.DB_PASSWORD, 
  {
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    dialect: 'mysql',
    logging: false, 
  }
);

sequelize.authenticate()
  .then(() => {
    console.log('✅ Kết nối Sequelize MySQL thành công!');
  })
  .catch((err) => {
    console.error('❌ Lỗi kết nối Database:', err.message);
  });

module.exports = sequelize;
