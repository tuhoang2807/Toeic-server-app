const QuestionPractice = require("../models/questionPractice");
const StudyTimeLog = require("../models/studyTimeLog");
const { Sequelize } = require("sequelize");
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
      limit: 10,
    });
  }

  async getPracticeStatistical(userId) {
    const stats = await sequelize.query(
      `
      WITH latest_practice_answers AS (
          SELECT 
              pa.question_id,
              pa.user_id,
              pa.is_correct,
              q.skill_id,
              ROW_NUMBER() OVER (
                  PARTITION BY pa.question_id, pa.user_id 
                  ORDER BY pa.answered_at DESC
              ) as rn
          FROM practice_answers pa
          JOIN questions_practice q ON pa.question_id = q.question_id
          WHERE pa.user_id = :userId
      )
      SELECT 
          s.skill_id,
          s.name,
          COUNT(DISTINCT q.question_id) AS total_questions,
          
          COUNT(DISTINCT CASE 
              WHEN lpa.user_id = :userId THEN lpa.question_id 
              ELSE NULL 
          END) AS attempted,
          
          COALESCE(SUM(CASE 
              WHEN lpa.is_correct = TRUE AND lpa.rn = 1 THEN 1 
              ELSE 0 
          END), 0) AS correct,
          
          CASE 
              WHEN COUNT(DISTINCT CASE WHEN lpa.user_id = :userId THEN lpa.question_id ELSE NULL END) = 0 THEN 0
              ELSE ROUND(
                  COALESCE(SUM(CASE 
                      WHEN lpa.is_correct = TRUE AND lpa.rn = 1 THEN 1 
                      ELSE 0 
                  END), 0) * 100.0 / 
                  COUNT(DISTINCT CASE WHEN lpa.user_id = :userId THEN lpa.question_id ELSE NULL END),
                  2
              )
          END AS accuracy
          
      FROM skills s
      LEFT JOIN questions_practice q ON q.skill_id = s.skill_id 
          AND q.is_active = TRUE
      LEFT JOIN latest_practice_answers lpa ON q.question_id = lpa.question_id 
          AND lpa.rn = 1
      WHERE s.is_active = TRUE
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

  async getTotalQuestionByTopicAndSkill(userId, skillId) {
    const stats = await sequelize.query(
      `
      WITH latest_answers AS (
          SELECT 
              question_id,
              user_id,
              is_correct,
              ROW_NUMBER() OVER (
                  PARTITION BY question_id, user_id 
                  ORDER BY answered_at DESC
              ) as rn
          FROM practice_answers
          WHERE user_id = :userId
      )
      SELECT 
          t.topic_id,
          t.name AS topic_name,
          t.slug AS topic_slug,
          COUNT(DISTINCT qp.question_id) AS total_questions,
          
          COUNT(DISTINCT CASE 
              WHEN la.user_id = :userId THEN la.question_id 
              ELSE NULL 
          END) AS answered_questions,
          
          COALESCE(SUM(CASE 
              WHEN la.is_correct = TRUE AND la.rn = 1 THEN 1 
              ELSE 0 
          END), 0) AS correct_answers,
          
          CASE 
              WHEN COUNT(DISTINCT CASE WHEN la.user_id = :userId THEN la.question_id ELSE NULL END) = 0 THEN 0
              ELSE ROUND(
                  COALESCE(SUM(CASE 
                      WHEN la.is_correct = TRUE AND la.rn = 1 THEN 1 
                      ELSE 0 
                  END), 0) * 100.0 / 
                  COUNT(DISTINCT CASE WHEN la.user_id = :userId THEN la.question_id ELSE NULL END),
                  2
              )
          END AS accuracy_percentage

      FROM topics t
      LEFT JOIN questions_practice qp ON t.topic_id = qp.topic_id 
          AND qp.is_active = TRUE
      LEFT JOIN latest_answers la ON qp.question_id = la.question_id 
          AND la.rn = 1
      WHERE t.is_active = TRUE
        AND t.skill_id = :skillId
      GROUP BY t.topic_id, t.name, t.slug
      ORDER BY t.topic_id ASC;
      `,
      {
        replacements: { userId, skillId },
        type: sequelize.QueryTypes.SELECT,
      }
    );
    return stats;
  }

  async getStudyTimeLast7Days(userId) {
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 6);
    const studyTimes = await StudyTimeLog.findAll({
      where: {
        user_id: userId,
        activity_type: "practice",
        study_date: {
          [Sequelize.Op.gte]: sevenDaysAgo.toISOString().split("T")[0],
        },
      },
      attributes: [
        "study_date",
        [
          Sequelize.fn("SUM", Sequelize.col("study_time_minutes")),
          "total_minutes",
        ],
      ],
      group: ["study_date"],
      order: [["study_date", "ASC"]],
    });
    const result = {};
    for (let i = 6; i >= 0; i--) {
      const date = new Date();
      date.setDate(date.getDate() - i);
      const dateStr = date.toISOString().split("T")[0];
      result[dateStr] = 0;
    }
    studyTimes.forEach((record) => {
      result[record.study_date] =
        parseInt(record.dataValues.total_minutes) || 0;
    });

    return Object.entries(result).map(([date, minutes]) => ({ date, minutes }));
  }
}

module.exports = new QuestionPracticeService();
