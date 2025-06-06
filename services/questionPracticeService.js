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

  async createStudyTimeLog(studyTimeData) {
    return await StudyTimeLog.create({
      user_id: studyTimeData.user_id,
      activity_type: studyTimeData.activity_type,
      skill_id: studyTimeData.skill_id,
      topic_id: studyTimeData.topic_id,
      session_id: studyTimeData.session_id,
      study_time_minutes: studyTimeData.study_time_minutes,
      study_date: studyTimeData.study_date,
    });
  }

  async getRank({ type, skill_id }) {
    try {
      let query;
      let results;

      if (skill_id) {
        query = `
          WITH UserCorrectAnswers AS (
            SELECT 
              pa.user_id,
              pa.question_id,
              MIN(pa.answered_at) AS first_correct_answer
            FROM practice_answers pa
            WHERE pa.is_correct = 1
            GROUP BY pa.user_id, pa.question_id
          )
          SELECT 
            ROW_NUMBER() OVER (ORDER BY COUNT(uca.question_id) DESC) AS stt,
            u.full_name AS ho_va_ten,
            s.name AS ky_nang,
            CONCAT(COUNT(uca.question_id), '/', 
              (SELECT COUNT(*) FROM questions_practice WHERE skill_id = :skill_id AND is_active = 1)) AS so_cau_dung_tong_so_cau
          FROM users u
          LEFT JOIN UserCorrectAnswers uca ON u.user_id = uca.user_id
          JOIN skills s ON s.skill_id = :skill_id
          WHERE u.is_active = 1
            AND s.is_active = 1
            AND (uca.question_id IS NULL OR EXISTS (
              SELECT 1 
              FROM questions_practice qp 
              WHERE qp.question_id = uca.question_id 
                AND qp.skill_id = :skill_id
                AND qp.is_active = 1
            ))
          GROUP BY u.user_id, u.full_name, s.name
          ORDER BY COUNT(uca.question_id) DESC
          LIMIT 10;
        `;
        results = await sequelize.query(query, {
          replacements: { skill_id },
          type: sequelize.QueryTypes.SELECT,
        });
      } else if (type === "mini_test" || type === "full_test") {
        query = `
          SELECT 
            ROW_NUMBER() OVER (ORDER BY SUM(ta.total_score) DESC) AS stt,
            u.full_name AS ho_va_ten,
            ts.type AS loai_hinh,
            CONCAT(COUNT(DISTINCT ta.test_set_id), '/', 
              (SELECT COUNT(*) FROM test_sets WHERE type = :type AND is_active = 1)) AS so_bai_da_lam_tong_so_bai,
            ROUND(SUM(ta.total_score), 2) AS tong_diem
          FROM users u
          JOIN test_attempts ta ON u.user_id = ta.user_id
          JOIN test_sets ts ON ta.test_set_id = ts.test_set_id
          WHERE ts.type = :type
            AND u.is_active = 1
            AND ts.is_active = 1
            AND ta.status = 'completed'
          GROUP BY u.user_id, u.full_name, ts.type
          ORDER BY SUM(ta.total_score) DESC
          LIMIT 10;
        `;
        results = await sequelize.query(query, {
          replacements: { type },
          type: sequelize.QueryTypes.SELECT,
        });
      } else {
        throw new Error("Invalid type or skill_id provided");
      }

      return results;
    } catch (error) {
      throw new Error(`Error fetching ranking: ${error.message}`);
    }
  }
}

module.exports = new QuestionPracticeService();
