const express = require('express');
const router = express.Router();
const SkillController = require('../controllers/skillController');
const { authenticate, isAdmin } = require('../middlewares/authMiddleware');

router.post('/create-skill', authenticate, isAdmin, SkillController.createSkill);
router.get('/get-all-skill', SkillController.getAllSkills);
router.get('/get-skill-by-id/:id', SkillController.getSkillById);
router.put('/update-skill/:id', authenticate, isAdmin, SkillController.updateSkill);
router.delete('/delete-skill/:id', authenticate, isAdmin, SkillController.deleteSkill);

module.exports = router;
