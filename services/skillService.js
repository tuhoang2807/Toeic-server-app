const Skill = require('../models/skill');

class SkillService {
   async createSkill(data) {
    return await Skill.create(data);
  }

   async getAllSkills() {
    return await Skill.findAll();
  }

   async getSkillById(id) {
    const skill = await Skill.findByPk(id);
    if (!skill) throw new Error('Kỹ năng không tồn tại');
    return skill;
  }

   async updateSkill(id, data) {
    const skill = await Skill.findByPk(id);
    if (!skill) throw new Error('Kỹ năng không tồn tại');
    await skill.update(data);
    return skill;
  }

   async deleteSkill(id) {
    const skill = await Skill.findByPk(id);
    if (!skill) throw new Error('Kỹ năng không tồn tại');
    await skill.destroy();
    return { message: 'Đã xóa kỹ năng thành công' };
  }
}

module.exports = new SkillService();
