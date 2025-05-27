const PracticeSession = require("../models/practiceSessions");

class PracticeSessionsService {
  async createSession(userId, skillId, topicId, totalQuestions) {
    return await PracticeSession.create({
      user_id: userId,
      skill_id: skillId,
      topic_id: topicId,
      total_questions: totalQuestions,
    });
  }

  async updateSession(sessionId, data, userId) {
  await PracticeSession.update(data, {
    where: {
      session_id: sessionId,
      user_id: userId,
    },
  });

  return await PracticeSession.findOne({
    where: {
      session_id: sessionId,
      user_id: userId,
    },
  });
}

}

module.exports = new PracticeSessionsService();
