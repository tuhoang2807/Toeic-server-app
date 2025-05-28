const express = require('express');
const router = express.Router();
const TestController = require('../controllers/testController');
const { authenticate , isAdmin } = require('../middlewares/authMiddleware');


//TEST SET ROUTES
router.post('/test-set/create', authenticate,isAdmin, TestController.createTestSet);
router.get('/test-set/get-all', authenticate,isAdmin ,TestController.getAllTestSets);
router.get('/test-set/get-by-id/:id', authenticate,isAdmin, TestController.getTestSetById);
router.put('/test-set/update/:id', authenticate,isAdmin ,TestController.updateTestSet);
router.delete('/test-set/delete/:id', authenticate,isAdmin,TestController.deleteTestSet);
router.get('/test-set/get-by-type', authenticate, TestController.getTestSetsByType);


module.exports = router;