const TestSetService = require("../services/testSetService");

class TestController {
  async createTestSet(req, res) {
    try {
      const testSet = await TestSetService.createTestSet(req.body);
      res.status(201).json({ status: 201, testSet });
    } catch (error) {
      res.status(400).json({ status: 400, error: error.message });
    }
  }

  async getAllTestSets(req, res) {
    try {
      const testSets = await TestSetService.getAllTestSets();
      res.status(200).json(testSets);
    } catch (error) {
      res.status(500).json({ status: 500, error: error.message });
    }
  }

  async getTestSetById(req, res) {
    try {
      const testSet = await TestSetService.getTestSetById(req.params.id);
      if (!testSet) {
        return res.status(404).json({ status: 404, message: "Không tìm thấy thông tin bộ đề" });
      }
      res.status(200).json(testSet);
    } catch (error) {
      res.status(500).json({ status: 500, error: error.message });
    }
  }

  async updateTestSet(req, res) {
    try {
      const updatedTestSet = await TestSetService.updateTestSet(req.params.id, req.body);
      res.status(200).json(updatedTestSet);
    } catch (error) {
      res.status(400).json({ status: 400, error: error.message });
    }
  }

  async deleteTestSet(req, res) {
    try {
      await TestSetService.deleteTestSet(req.params.id);
      res.status(200).json({ status: 200, message: "Bộ đề đã được xóa thành công" });
    } catch (error) {
      res.status(400).json({ status: 400, error: error.message });
    }
  }

  async getTestSetsByType(req, res) {
    try {
      const { type } = req.body;
      const testSets = await TestSetService.getTestSetsByType(type);
      res.status(200).json({status: 200, testSets});
    } catch (error) {
      res.status(500).json({ status: 500, error: error.message });
    }
  }
}

module.exports = new TestController();