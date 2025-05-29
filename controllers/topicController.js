const TopicService = require("../services/topicService");

class TopicController {
  async createTopic(req, res) {
    try {
      const { skill_id, name, slug ,description} = req.body;
      if (!name || !description || !skill_id) {
        return res.status(400).json({ error: "Yêu cầu nhập đầy đủ thông tin" });
      }
      console.log("body", req.body);
      const topic = await TopicService.createTopic({
        skill_id,
        name,
        slug,
        description,
      });

      res.status(201).json({status: 201, topic});
    } catch (error) {
      res.status(400).json({status: 400, error: error.message });
    }
  }

  async getAllTopics(req, res) {
    try {
      const topics = await TopicService.getAllTopics();
      res.json(topics);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  async getTopicById(req, res) {
    try {
      const topic = await TopicService.getTopicById(req.params.id);
      if (!topic) return res.status(404).json({ error: "Topic không tồn tại" });
      res.json(topic);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  async updateTopic(req, res) {
    try {
      const topic = await TopicService.updateTopic(req.params.id, req.body);
      res.json(topic);
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  async deleteTopic(req, res) {
    try {
      await TopicService.deleteTopic(req.params.id);
      res.json({status: 200, message: "Xóa topic thành công" });
    } catch (error) {
      res.status(400).json({status: 400, error: error.message });
    }
  }

  async getTopicsBySkillId(req, res) {
    try {
      const topics = await TopicService.getTopicsBySkillId(req.params.skillId);
      if (!topics || topics.length === 0) {
        return res.status(404).json({ error: "Không tìm thấy topic cho skill này" });
      }
      res.json(topics);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
}

module.exports = new TopicController();
