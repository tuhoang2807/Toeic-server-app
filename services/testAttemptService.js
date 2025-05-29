const TestAtempt = require('../models/testAttempts');

class TestAttemptService {
  async createAttempt(data) {
    return await TestAtempt.create(data);
  }

  async updateAttempt(attemptId, userId, data) {
  await TestAtempt.update(data, {
    where: { attempt_id: attemptId, user_id: userId },
  });
  return await TestAtempt.findOne({
    where: { attempt_id: attemptId, user_id: userId },
  });
}

}

module.exports = new TestAttemptService();