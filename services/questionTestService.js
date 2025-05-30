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

  async getStatisticalTest(userId) {
    try {
      const stats = await sequelize.query(
        `
            WITH test_stats AS (
                SELECT 
                    ts.type,
                    -- Đếm tổng số bộ đề có sẵn
                    COUNT(DISTINCT ts.test_set_id) as total_available_tests,
                    -- Đếm số bộ đề đã hoàn thành
                    COUNT(DISTINCT CASE WHEN ta.status = 'completed' THEN ta.test_set_id END) as completed_tests,
                    -- Tính tỷ lệ chính xác trung bình (chỉ tính các bài đã hoàn thành)
                    COALESCE(AVG(
                        CASE 
                            WHEN ta.status = 'completed' AND ta.total_questions > 0 
                            THEN (ta.correct_answers * 100.0 / ta.total_questions)
                            ELSE NULL 
                        END
                    ), 0) as avg_accuracy_rate,
                    -- Điểm trung bình (chỉ tính các bài đã hoàn thành)
                    COALESCE(AVG(
                        CASE 
                            WHEN ta.status = 'completed' 
                            THEN ta.total_score
                            ELSE NULL 
                        END
                    ), 0) as avg_total_score,
                    -- Thời gian trung bình (chỉ tính các bài đã hoàn thành)
                    COALESCE(AVG(
                        CASE 
                            WHEN ta.status = 'completed' AND ta.time_taken_seconds IS NOT NULL
                            THEN ta.time_taken_seconds
                            ELSE NULL 
                        END
                    ), 0) as avg_time_seconds
                FROM test_sets ts
                LEFT JOIN test_attempts ta ON ts.test_set_id = ta.test_set_id 
                    AND ta.user_id = :userId
                WHERE ts.is_active = TRUE
                GROUP BY ts.type
            )
            SELECT 
                type,
                total_available_tests,
                completed_tests,
                CONCAT(completed_tests, '/', total_available_tests) as completion_ratio,
                ROUND(avg_accuracy_rate, 1) as accuracy_rate,
                ROUND(avg_total_score, 0) as average_score,
                CASE 
                    WHEN avg_time_seconds = 0 THEN '0m 0s'
                    ELSE CONCAT(
                        FLOOR(avg_time_seconds / 60), 'm ',
                        ROUND(avg_time_seconds % 60, 0), 's'
                    )
                END as average_time
            FROM test_stats
            ORDER BY CASE WHEN type = 'mini_test' THEN 1 ELSE 2 END
        `,
        {
          replacements: { userId },
          type: sequelize.QueryTypes.SELECT,
        }
      );

      const defaultStats = {
        mini_test: {
          type: "mini_test",
          total_available_tests: 0,
          completed_tests: 0,
          completion_ratio: "0/0",
          accuracy_rate: 0,
          average_score: 0,
          average_time: "0m 0s",
        },
        full_test: {
          type: "full_test",
          total_available_tests: 0,
          completed_tests: 0,
          completion_ratio: "0/0",
          accuracy_rate: 0,
          average_score: 0,
          average_time: "0m 0s",
        },
      };

      stats.forEach((stat) => {
        defaultStats[stat.type] = stat;
      });
      return {
        success: true,
        data: {
          mini_test: defaultStats.mini_test,
          full_test: defaultStats.full_test,
          summary: {
            total_completed:
              defaultStats.mini_test.completed_tests +
              defaultStats.full_test.completed_tests,
            total_available:
              defaultStats.mini_test.total_available_tests +
              defaultStats.full_test.total_available_tests,
          },
        },
      };
    } catch (error) {
      console.error("Error in getStatisticalTest:", error);
      return {
        success: false,
        message: "Có lỗi xảy ra khi lấy thống kê bài thi",
        error: error.message,
      };
    }
  }
}

module.exports = new QuestionTestService();
