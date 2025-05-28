const QuestionPractice = require("../models/questionPractice");
const sequelize = require("../config/db");

class QuestionPracticeService {
  async questionPracticeGetAll() {
    return await QuestionPractice.findAll();
  }

  async questionPracticeGetById(id) {
    return await QuestionPractice.findByPk(id);
  }

  async questionPracticeCreate(data) {
    return await QuestionPractice.create(data);
  }

  async questionPracticeUpdate(id, data) {
    return await QuestionPractice.update(data, {
      where: { question_id: id },
    });
  }

  async questionPracticeDelete(id) {
    return await QuestionPractice.destroy({
      where: { question_id: id },
    });
  }

  async questionPracticeRandomByTopicAndSkill(skillId, topicId) {
    return await QuestionPractice.findAll({
      where: {
        skill_id: skillId,
        topic_id: topicId,
        is_active: true,
      },
      order: sequelize.random(),
      limit: 20,
    });
  }

  async getPracticeStatistical(userId) {
    const stats = await sequelize.query(
      `
    SELECT 
      s.skill_id,
      s.name,
      COUNT(DISTINCT q.question_id) AS total_questions,
      COUNT(DISTINCT CASE WHEN ps.user_id = :userId THEN pa.question_id END) AS attempted,
      SUM(CASE WHEN ps.user_id = :userId AND pa.is_correct = true THEN 1 ELSE 0 END) AS correct,
      CASE 
        WHEN COUNT(DISTINCT CASE WHEN ps.user_id = :userId THEN pa.question_id END) = 0 THEN 0
        ELSE ROUND(
          SUM(CASE WHEN ps.user_id = :userId AND pa.is_correct = true THEN 1 ELSE 0 END) * 100.0 /
          COUNT(DISTINCT CASE WHEN ps.user_id = :userId THEN pa.question_id END), 
          2
        )
      END AS accuracy
    FROM skills s
    LEFT JOIN questions_practice q ON q.skill_id = s.skill_id
    LEFT JOIN practice_answers pa ON pa.question_id = q.question_id
    LEFT JOIN practice_sessions ps ON ps.session_id = pa.session_id
    GROUP BY s.skill_id, s.name
    ORDER BY s.skill_id;
    `,
      {
        replacements: { userId },
        type: sequelize.QueryTypes.SELECT,
      }
    );
    return stats;
  }

  async getTotalQuestionByTopic(topicId) {
    const totalQuestions = await QuestionPractice.count({
      where: { topic_id: topicId, is_active: true },
    });
    return totalQuestions;
  }
}

module.exports = new QuestionPracticeService();
