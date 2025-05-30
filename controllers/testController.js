const TestSetService = require("../services/testSetService");
const QuestionTestService = require("../services/questionTestService");
const TestAttemptService = require("../services/testAttemptService");
const TestAnswerService = require("../services/testAnswerService");

class TestController {
  // PHẦN ĐỀ THI
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
        return res
          .status(404)
          .json({ status: 404, message: "Không tìm thấy thông tin bộ đề" });
      }
      res.status(200).json(testSet);
    } catch (error) {
      res.status(500).json({ status: 500, error: error.message });
    }
  }

  async updateTestSet(req, res) {
    try {
      const updatedTestSet = await TestSetService.updateTestSet(
        req.params.id,
        req.body
      );
      res.status(200).json(updatedTestSet);
    } catch (error) {
      res.status(400).json({ status: 400, error: error.message });
    }
  }

  async deleteTestSet(req, res) {
    try {
      await TestSetService.deleteTestSet(req.params.id);
      res
        .status(200)
        .json({ status: 200, message: "Bộ đề đã được xóa thành công" });
    } catch (error) {
      res.status(400).json({ status: 400, error: error.message });
    }
  }

  async getTestSetsByType(req, res) {
    try {
      const { type } = req.params;
      const userId = req.user.user_id;
      const testSets = await TestSetService.getTestSetsByType(type, userId);
      return res.status(200).json(testSets);
    } catch (error) {
      res.status(500).json({ status: 500, error: error.message });
    }
  }

  //KẾT THÚC PHẦN ĐỀ THI

  // PHẦN CÂU HỎI CHO BỘ ĐỀ THI
  async createQuestionTest(req, res) {
    try {
      const questionTest = await QuestionTestService.questionTestCreate(
        req.body
      );
      res.status(201).json({ status: 201, questionTest });
    } catch (error) {
      res.status(400).json({ status: 400, error: error.message });
    }
  }

  async getAllQuestionTests(req, res) {
    try {
      const questionTests = await QuestionTestService.questionTestGetAll();
      res.status(200).json(questionTests);
    } catch (error) {
      res.status(500).json({ status: 500, error: error.message });
    }
  }

  async getQuestionTestById(req, res) {
    try {
      const questionTest = await QuestionTestService.questionTestGetById(
        req.params.id
      );
      if (!questionTest) {
        return res
          .status(404)
          .json({ status: 404, message: "Không tìm thấy thông tin câu hỏi" });
      }
      res.status(200).json(questionTest);
    } catch (error) {
      res.status(500).json({ status: 500, error: error.message });
    }
  }

  async updateQuestionTest(req, res) {
    try {
      const updatedQuestionTest = await QuestionTestService.questionTestUpdate(
        req.params.id,
        req.body
      );
      res.status(200).json({ status: 200, updatedQuestionTest });
    } catch (error) {
      res.status(400).json({ status: 400, error: error.message });
    }
  }

  async deleteQuestionTest(req, res) {
    try {
      await QuestionTestService.questionTestDelete(req.params.id);
      res
        .status(200)
        .json({ status: 200, message: "Câu hỏi đã được xóa thành công" });
    } catch (error) {
      res.status(400).json({ status: 400, error: error.message });
    }
  }

  async getQuestionTestByTestSetId(req, res) {
    try {
      const setId = req.body.setId;
      console.log("s:", setId); 
      const questionTests =
        await QuestionTestService.questionTestGetByTestSetId(setId);
      res.status(200).json({
        status: 200,
        totalQuestions: questionTests.length,
        questionTests: questionTests.map((q) => ({
          test_set_id: q.test_set_id,
          part_number: q.part_number,
          question_number: q.question_number,
          question_text: q.question_text,
          audio_url: q.audio_url,
          image_url: q.image_url,
          passage_text: q.passage_text,
          options: q.options,
          is_active: q.is_active,
        })),
      });
    } catch (error) {
      res.status(500).json({ status: 500, error: error.message });
    }
  }

  //KẾT THÚC PHẦN CÂU HỎI CHO BỘ ĐỀ THI

  // PHẦN LÀM BÀI KIỂM TRA

  async createAttempt(req, res) {
    const { testSetId } = req.body;
    const userId = req.user.user_id;
    const totalQuestions = await QuestionTestService.getTotalQuestionsByTestSetId(testSetId);
    console.log("totalQuestions", totalQuestions);
    if (totalQuestions <= 0) {
      return res.status(400).json({
        status: 400,
        error:
          "Không có câu hỏi nào trong bộ đề thi",
      });
    }
    try {
      const attemptData = {
        user_id: userId,
        test_set_id: testSetId,
        total_questions: totalQuestions,
      };
      const testAttempt = await TestAttemptService.createAttempt(attemptData);
      res.status(201).json({
        status: 201,
        testAttempt: {
          attempt_id: testAttempt.attempt_id,
          user_id: testAttempt.user_id,
          test_set_id: testAttempt.test_set_id,
          total_questions: testAttempt.total_questions,
          status: testAttempt.status,
          started_at: testAttempt.started_at,
        },
      });
    } catch (error) {
      res.status(400).json({ status: 400, error: error.message });
    }
  }

  async submitTest(req, res) {
    const userId = req.user.user_id;
    const { attemptId, answers, timeTaken, testSetId } = req.body;

    if (!Array.isArray(answers) || !answers.length) {
      return res
        .status(400)
        .json({ status: 400, error: "Dữ liệu answers không hợp lệ" });
    }

    try {
      const totalQuestionTest =
        await QuestionTestService.questionTestGetByTestSetId(testSetId);
      const allQuestionIds = totalQuestionTest.map((q) => q.question_id);
      const questionIds = answers.map((a) => a.questionId);
      const questionTests =
        await QuestionTestService.questionTestsGetByMultipleId(questionIds);
      const abandonedQuestionIds = allQuestionIds.filter(
        (id) => !questionIds.includes(id)
      );

      if (!Array.isArray(questionTests)) {
        return res
          .status(500)
          .json({ status: 500, error: "Dữ liệu câu hỏi không hợp lệ" });
      }

      const correctAnswerMap = new Map(
        questionTests.map((q) => [q.question_id, q.correct_answer])
      );

      let correctCount = 0;
      answers.forEach((a) => {
        const correct = correctAnswerMap.get(a.questionId);
        if (a.userAnswer === correct) {
          correctCount++;
        }
      });

      const valuesToInsert = answers.map((a) => {
        const correct = correctAnswerMap.get(a.questionId);
        return {
          user_id: userId,
          attempt_id: attemptId,
          question_id: a.questionId,
          user_answer: a.userAnswer,
          is_correct: a.userAnswer === correct,
          time_taken_seconds: a.timeTaken || null,
        };
      });

      const testAnswers = await TestAnswerService.createAnswer(valuesToInsert);

      const resultWithCorrect = testAnswers.map((a) => ({
        user_id: a.user_id,
        attempt_id: a.attempt_id,
        question_id: a.question_id,
        user_answer: a.user_answer,
        is_correct: a.is_correct,
        correct_answer: correctAnswerMap.get(a.question_id),
      }));

      const dataToUpdateAttempt = {
        user_id: userId,
        correct_answers: correctCount,
        status: "completed",
        total_score: Number(
          ((10 / totalQuestionTest.length) * correctCount).toFixed(2)
        ),
        time_taken_seconds: timeTaken,
        completed_at: new Date(),
      };

      const testAttempt = await TestAttemptService.updateAttempt(
        attemptId,
        userId,
        dataToUpdateAttempt
      );

      return res.status(200).json({
        status: 200,
        message: "Nộp bài thành công",
        attemptId: testAttempt.attempt_id,
        attemptStatus: testAttempt.status,
        totalQuestion: testAttempt.total_questions,
        totalCorrectAnswer: testAttempt.correct_answers,
        totalWrongAnswer:
          testAttempt.total_questions -
          testAttempt.correct_answers -
          abandonedQuestionIds.length,
        totalBlankAnswer: abandonedQuestionIds.length,
        totalScore: testAttempt.total_score,
        Time: testAttempt.time_taken_seconds,
        answers: resultWithCorrect,
      });
    } catch (error) {
      return res.status(500).json({
        status: 500,
        error: "Lỗi khi nộp bài kiểm tra",
        details: error.message,
      });
    }
  }

  async getStatisticalTest(req, res) {
    try {
      const userId = req.user.user_id;
      const statisticalTest = await QuestionTestService.getStatisticalTest(
        userId
      );
      return res.status(200).json({ status: 200, statisticalTest });
    } catch (error) {
      return res.status(500).json({
        status: 500,
        error: "Lỗi khi thống kê kết quả bài kiểm tra",
        details: error.message,
      });
    }
  }
}

module.exports = new TestController();
