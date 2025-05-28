const TestSet = require("../models/testSet");

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

  async getTestSetsByType(type) {
    const testSets = await TestSet.findAll({
      where: {
        type,
        is_active: true,
      },
    });
    return testSets;
  }
}

module.exports = new TestSetService();