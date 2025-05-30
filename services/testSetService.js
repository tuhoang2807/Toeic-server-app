const TestSet = require("../models/testSet");
const sequelize = require("../config/db");

class TestSetService {
  async createTestSet(data) {
    return await TestSet.create(data);
  }

  async getAllTestSets() {
    return await TestSet.findAll();
  }

  async getTestSetById(testSetId) {
    return await TestSet.findByPk(testSetId);
  }

  async updateTestSet(testSetId, data) {
    const testSet = await TestSet.findByPk(testSetId);
    if (!testSet) throw new Error("Test set không tồn tại");

    await testSet.update(data);
    return testSet;
  }

  async deleteTestSet(testSetId) {
    const testSet = await TestSet.findByPk(testSetId);
    if (!testSet) throw new Error("Test set không tồn tại");

    await testSet.destroy();
    return true;
  }

  async getTestSetsByType(type, userId) {
    const query = `
        SELECT 
            ts.test_set_id,
            ts.name,
            ts.type,
            ts.total_questions,
            ts.time_limit,
            ts.description,
            ts.created_at,
            ta.attempt_id,
            ta.total_score,
            ta.listening_score,
            ta.reading_score,
            ta.completed_at,
            CASE 
                WHEN ta.attempt_id IS NOT NULL THEN TRUE 
                ELSE FALSE 
            END as is_completed
        FROM test_sets ts
        LEFT JOIN (
            SELECT 
                t1.test_set_id,
                t1.user_id,
                t1.attempt_id,
                t1.total_score,
                t1.listening_score,
                t1.reading_score,
                t1.completed_at
            FROM test_attempts t1
            WHERE t1.status = 'completed' 
                AND t1.user_id = ?
                AND t1.completed_at = (
                    SELECT MAX(t2.completed_at)
                    FROM test_attempts t2
                    WHERE t2.test_set_id = t1.test_set_id 
                        AND t2.user_id = t1.user_id
                        AND t2.status = 'completed'
                )
        ) ta ON ts.test_set_id = ta.test_set_id
        WHERE ts.type = ?
            AND ts.is_active = TRUE
        ORDER BY ts.test_set_id  ASC;
    `;

    const results = await sequelize.query(query, {
      replacements: [userId, type],
      type: sequelize.QueryTypes.SELECT,
    });
    return results.map((row) => ({
      test_set_id: row.test_set_id,
      name: row.name,
      type: row.type,
      total_questions: row.total_questions, 
      time_limit: row.time_limit, 
      description: row.description,
      is_completed: row.is_completed,
      total_score: row.total_score || 0,
      listening_score: row.listening_score || 0,
      reading_score: row.reading_score || 0,
      completed_at: row.completed_at,
      created_at: row.created_at,
    }));
  }
}

module.exports = new TestSetService();
