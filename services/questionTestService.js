const QuestionTest = require('../models/questionTest');

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
      question_id: questionIds
    }
  });
}

}

module.exports = new QuestionTestService();