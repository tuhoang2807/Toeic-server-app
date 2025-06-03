const QuestionTest = require("../models/questionTest");
const sequelize = require("../config/db");

class QuestionTestService {
  async questionTestGetAll() {
    return await QuestionTest.findAll();
  }

  async questionTestGetById(id) {
    return await QuestionTest.findByPk(id);
  }

  async questionTestCreate(data) {
    return await QuestionTest.create(data);
  }

  async questionTestUpdate(id, data) {
    return await QuestionTest.update(data, {
      where: { question_id: id },
    });
  }

  async questionTestDelete(id) {
    return await QuestionTest.destroy({
      where: { question_id: id },
    });
  }

  async questionTestGetByTestSetId(testSetId) {
    return await QuestionTest.findAll({
      where: { test_set_id: testSetId },
    });
  }

  async getTotalQuestionsByTestSetId(testSetId) {
    const count = await QuestionTest.count({
      where: { test_set_id: testSetId },
    });
    return count;
  }

  async questionTestsGetByMultipleId(questionIds) {
    return await QuestionTest.findAll({
      where: {
        question_id: questionIds,
      },
    });
  }
  async getStatisticalTest(user_id, type) {
    try {
      if (!["mini_test", "full_test"].includes(type)) {
        throw new Error(
          'type phải là một trong hai giá trị: "mini_test" hoặc "full_test"'
        );
      }
      const stats = await sequelize.query(
        `
        WITH LatestAttempts AS (
          SELECT 
            ta.attempt_id,
            ta.test_set_id,
            ta.total_questions,
            ta.correct_answers,
            ta.time_taken_seconds,
            ROW_NUMBER() OVER (PARTITION BY ta.test_set_id ORDER BY ta.completed_at DESC) AS rn
          FROM test_attempts ta
          JOIN test_sets ts ON ta.test_set_id = ts.test_set_id
          WHERE ta.user_id = :user_id 
            AND ts.type = :type 
            AND ta.status = 'completed'
        ),
        AccuracyPerAttempt AS (
          SELECT 
            la.attempt_id,
            COALESCE(SUM(tan.is_correct) / NULLIF(COUNT(tan.answer_id), 0), 0) AS attempt_accuracy,
            (10.0 / la.total_questions) * la.correct_answers AS attempt_score,
            la.time_taken_seconds
          FROM LatestAttempts la
          LEFT JOIN test_answers tan ON la.attempt_id = tan.attempt_id
          WHERE la.rn = 1
          GROUP BY la.attempt_id, la.total_questions, la.correct_answers, la.time_taken_seconds
        )
        SELECT 
          :type AS type,
          (SELECT COUNT(*) 
           FROM test_sets 
           WHERE type = :type AND is_active = TRUE) AS total_available_tests,
          COUNT(DISTINCT la.test_set_id) AS completed_tests,
          CONCAT(COUNT(DISTINCT la.test_set_id), '/', 
                 (SELECT COUNT(*) 
                  FROM test_sets 
                  WHERE type = :type AND is_active = TRUE)) AS completion_ratio,
          COALESCE(ROUND(AVG(apa.attempt_accuracy) * 100, 2), 0) AS accuracy_rate,
          COALESCE(ROUND(AVG(apa.attempt_score), 2), 0) AS average_score,
          COALESCE(ROUND(AVG(apa.time_taken_seconds), 0), 0) AS average_time
        FROM LatestAttempts la
        LEFT JOIN AccuracyPerAttempt apa ON la.attempt_id = apa.attempt_id
        WHERE la.rn = 1;
      `,
        {
          replacements: { type, user_id },
          type: sequelize.QueryTypes.SELECT,
        }
      );
      return stats.length > 0
        ? stats[0]
        : {
            type,
            total_available_tests: 0,
            completed_tests: 0,
            completion_ratio: "0/0",
            accuracy_rate: 0,
            average_score: 0,
            average_time: 0,
          };
    } catch (error) {
      console.error(
        `Lỗi trong quá trình lấy thống kê của ${user_id} and type ${type}:`,
        error
      );
      throw new Error(`Lỗi trong quá trình lấy thống kê của ${user_id}: ${error.message}`);
    }
  }
}

module.exports = new QuestionTestService();
