const TestAnswer = require("../models/testAnswers");

const TestAnswerService = {
  async createAnswer(data) {
    return await TestAnswer.bulkCreate(data);
  }
};

module.exports = TestAnswerService;
