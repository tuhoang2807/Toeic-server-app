const express = require('express');
const router = express.Router();
const questionPracticeController = require('../controllers/questionPracticeController');
const { authenticate, isAdmin } = require('../middlewares/authMiddleware');

router.get('/question-practice/get-all',authenticate, questionPracticeController.questionPracticeGetAll);
router.get('/question-practice/get-by-id/:id', authenticate , questionPracticeController.questionPracticeGetById);
router.post('/question-practice/create',authenticate, questionPracticeController.questionPracticeCreate);
router.put('/question-practice/update/:id',authenticate, questionPracticeController.questionPracticeUpdate);
router.delete('/question-practice/delete/:id',authenticate, questionPracticeController.questionPracticeDelete);
router.post('/question-practice/random-by-topic-and-skill',authenticate, questionPracticeController.questionPracticeRandomByTopicAndSkill);
router.get('/question-practice/get-question-by-topic', authenticate, questionPracticeController.getTotalQuestionByTopic);


router.post('/practice-answer-question', authenticate, questionPracticeController.practiceAnswerQuestion);
router.post('/practice-session-result', authenticate, questionPracticeController.getPracticeSessionResult);
router.get('/practice-statistical', authenticate, questionPracticeController.getPracticeStatistical);
router.get('/question-practice/get-total-question-by-topic-and-skill', authenticate, questionPracticeController.getTotalQuestionByTopicAndSkill);

module.exports = router;
