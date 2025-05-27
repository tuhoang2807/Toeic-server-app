const PracticeAnswer = require("../models/practiceAnswers");

class PracticeAnswerService {
  async answerQuestion(data) {
    return await PracticeAnswer.create(data);
  }

  async getAnswersBySessionId(sessionId) {
    return await PracticeAnswer.findAll({
      where: { session_id: sessionId },
    });
  }
}

module.exports = new PracticeAnswerService();