const Topic = require("../models/topic");
class TopicService {
  async createTopic(data) {
    return await Topic.create(data);
  }
  async getAllTopics() {
    return await Topic.findAll();
  }

  async getTopicById(topicId) {
    return await Topic.findByPk(topicId);
  }

  async updateTopic(topicId, data) {
    const topic = await Topic.findByPk(topicId);
    if (!topic) throw new Error("Topic không tồn tại");

    await topic.update(data);
    return topic;
  }

  async deleteTopic(topicId) {
    const topic = await Topic.findByPk(topicId);
    if (!topic) throw new Error("Topic không tồn tại");

    await topic.destroy();
    return true;
  }
  
  async getTopicsBySkillId(skillId) {
    return await Topic.findAll({
      where: { skill_id: skillId },
    });
  }
}

module.exports = new TopicService();
