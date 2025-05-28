const express = require('express');
const router = express.Router();
const AdminController = require('../controllers/adminController');
const { authenticate, isAdmin } = require('../middlewares/authMiddleware');


router.get('/get-all-users', authenticate, isAdmin, AdminController.getAllUsers);
router.put('/:userId/active', authenticate, isAdmin, AdminController.toggleUserActive);
router.put('/update-user/:userId', authenticate, isAdmin, AdminController.updateUser);
router.delete('/delete-user/:userId', authenticate, isAdmin, AdminController.deleteUser);

module.exports = router;