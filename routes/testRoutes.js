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
router.get('/test-set/get-by-type/:type', authenticate, TestController.getTestSetsByType);


//QUESTION TEST ROUTES
router.get('/question-test/get-all', authenticate, TestController.getAllQuestionTests);
router.get('/question-test/get-by-id/:id', authenticate, TestController.getQuestionTestById);
router.post('/question-test/create', authenticate, isAdmin, TestController.createQuestionTest);
router.put('/question-test/update/:id', authenticate, isAdmin, TestController.updateQuestionTest);
router.delete('/question-test/delete/:id', authenticate, isAdmin, TestController.deleteQuestionTest);
router.post('/question-test/get-by-test-set-id', authenticate, TestController.getQuestionTestByTestSetId);

//USER TEST ATTEMPTS ROUTES
router.post('/test-attempt/create', authenticate, TestController.createAttempt);
router.post('/submit', authenticate, TestController.submitTest);
router.post('/statistical-test', authenticate, TestController.getStatisticalTest);


module.exports = router;