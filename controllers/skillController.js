const SkillService = require("../services/skillService");

class SkillController {
  async createSkill(req, res) {
    try {
      const skill = await SkillService.createSkill(req.body);
      res.status(201).json(skill);
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  async getAllSkills(req, res) {
    try {
      const skills = await SkillService.getAllSkills();
      res.status(200).json(skills);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  async getSkillById(req, res) {
    try {
      const skill = await SkillService.getSkillById(req.params.id);
      res.status(200).json(skill);
    } catch (error) {
      res.status(404).json({ error: error.message });
    }
  }

  async updateSkill(req, res) {
    try {
      const skill = await SkillService.updateSkill(req.params.id, req.body);
      res.status(200).json(skill);
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  async deleteSkill(req, res) {
    try {
      const result = await SkillService.deleteSkill(req.params.id);
      res.status(200).json(result);
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }
}

module.exports = new SkillController();
