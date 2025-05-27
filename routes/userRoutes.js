const express = require('express');
const router = express.Router();
const UserController = require('../controllers/userController');
const { authenticate } = require('../middlewares/authMiddleware');

router.get('/profile', authenticate, UserController.getProfile);
router.put('/update-profile', authenticate, UserController.updateProfile);
router.put('/change-password', authenticate, UserController.changePassword);
router.delete('/delete-account', authenticate, UserController.deleteAccount);


module.exports = router;