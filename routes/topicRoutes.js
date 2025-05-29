const express = require('express');
const router = express.Router();
const TopicController = require('../controllers/topicController');
const { authenticate, isAdmin } = require('../middlewares/authMiddleware');

router.post('/create-topic',authenticate, isAdmin, TopicController.createTopic);
router.get('/get-all-topics', TopicController.getAllTopics);
router.get('/get-topic-by-id/:id', TopicController.getTopicById);
router.put('/update-topic/:id',authenticate, isAdmin, TopicController.updateTopic);
router.delete('/delete-topic/:id',authenticate, isAdmin, TopicController.deleteTopic);

router.get('/get-topics-by-skill-id/:skillId', TopicController.getTopicsBySkillId);
router.get('/getTopicsBySkillId/:skillId', TopicController.getTopicsBySkillId);

module.exports = router;
