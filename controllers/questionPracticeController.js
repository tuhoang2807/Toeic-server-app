const QuestionPracticeService = require("../services/questionPracticeService");
const PracticeSessionsService = require("../services/practiceSessionsService");
const PracticeAnSwerService = require("../services/practiceAnSwerService");

class QuestionPracticeController {
  async questionPracticeGetAll(req, res) {
    try {
      const data = await QuestionPracticeService.questionPracticeGetAll();
      res.json(data);
    } catch (err) {
      res.status(500).json({
        status: 500,
        message: "Lỗi khi lấy danh sách câu hỏi.",
        error: err.message,
      });
    }
  }

  async questionPracticeGetById(req, res) {
    try {
      const data = await QuestionPracticeService.questionPracticeGetById(
        req.params.id
      );
      if (!data)
        return res
          .status(404)
          .json({ status: 404, message: "Không tìm thấy câu hỏi." });
      res.json(data);
    } catch (err) {
      res.status(500).json({
        status: 500,
        message: "Lỗi khi lấy chi tiết câu hỏi.",
        error: err.message,
      });
    }
  }

  async questionPracticeCreate(req, res) {
    try {
      const newQuestion = await QuestionPracticeService.questionPracticeCreate(
        req.body
      );
      res.status(201).json({ status: 201, newQuestion });
    } catch (err) {
      res.status(400).json({
        status: 400,
        message: "Lỗi khi tạo câu hỏi.",
        error: err.message,
      });
    }
  }

  async questionPracticeUpdate(req, res) {
    try {
      const result = await QuestionPracticeService.questionPracticeUpdate(
        req.params.id,
        req.body
      );
      if (result[0] === 0)
        return res.status(404).json({
          status: 404,
          message: "Không tìm thấy câu hỏi để cập nhật.",
        });
      res.json({ status: 200, message: "Cập nhật thành công." });
    } catch (err) {
      res.status(400).json({
        status: 400,
        message: "Lỗi khi cập nhật câu hỏi.",
        error: err.message,
      });
    }
  }

  async questionPracticeDelete(req, res) {
    try {
      const result = await QuestionPracticeService.questionPracticeDelete(
        req.params.id
      );
      if (result === 0)
        return res
          .status(404)
          .json({ status: 404, message: "Không tìm thấy câu hỏi để xóa." });
      res.json({ status: 200, message: "Xóa thành công." });
    } catch (err) {
      res.status(500).json({
        status: 500,
        message: "Lỗi khi xóa câu hỏi.",
        error: err.message,
      });
    }
  }

  async questionPracticeRandomByTopicAndSkill(req, res) {
    try {
      const { skillId, topicId } = req.body;
      const userId = req.user.user_id;

      if (!skillId || !topicId) {
        return res
          .status(400)
          .json({ status: 400, message: "Thiếu skillId hoặc topicId" });
      }

      const questions =
        await QuestionPracticeService.questionPracticeRandomByTopicAndSkill(
          skillId,
          topicId
        );
      const session = await PracticeSessionsService.createSession(
        userId,
        skillId,
        topicId,
        questions.length
      );

      res.status(200).json({
        status: 200,
        session_id: session.session_id,
        total_questions: questions.length,
        questions: questions.map((q) => ({
          question_id: q.question_id,
          question_text: q.question_text,
          audio_url: q.audio_url,
          image_url: q.image_url,
          options: q.options,
        })),
      });
    } catch (err) {
      res.status(500).json({
        status: 500,
        message: "Lỗi khi lấy câu hỏi",
        error: err.message,
      });
    }
  }

  async deleteSession(req, res) {
    try {
      const sessionId = req.params.id;
      const userId = req.user.user_id;
      if (!sessionId) {
        return res.status(400).json({
          status: 400,
          message: "Thiếu sessionId",
        });
      }

      const result = await PracticeSessionsService.deleteSession(
        sessionId,
        userId
      );
      if (result === 0) {
        return res.status(404).json({
          status: 404,
          message: "Không tìm thấy phiên làm bài để xóa.",
        });
      }
      res
        .status(200)
        .json({ status: 200, message: "Xóa phiên làm bài thành công." });
    } catch (err) {
      res.status(500).json({
        status: 500,
        message: "Lỗi khi xóa phiên làm bài.",
        error: err.message,
      });
    }
  }

  async practiceAnswerQuestion(req, res) {
    const userId = req.user.user_id;
    try {
      const { sessionId, questionId, answer, time_taken_seconds } = req.body;

      if (!sessionId || !questionId || !answer) {
        return res.status(400).json({
          status: 400,
          message: "Thiếu thông tin cần thiết",
        });
      }

      const question = await QuestionPracticeService.questionPracticeGetById(
        questionId
      );
      if (!question) {
        return res
          .status(404)
          .json({ status: 404, message: "Câu hỏi không tồn tại" });
      }

      const isCorrect =
        question.correct_answer.trim().toUpperCase() ===
        answer.trim().toUpperCase();
      const data = {
        user_id: userId,
        session_id: sessionId,
        question_id: questionId,
        user_answer: answer,
        is_correct: isCorrect,
        time_taken_seconds: time_taken_seconds,
      };

      const savedAnswer = await PracticeAnSwerService.answerQuestion(data);
      return res.status(200).json({
        status: 200,
        message: "Đã lưu câu trả lời",
        is_correct: isCorrect,
        correct_answer: question.correct_answer,
        explanation: question.explanation || null,
        answer_id: savedAnswer.answer_id,
      });
    } catch (err) {
      return res.status(500).json({
        status: 500,
        message: "Lỗi khi trả lời câu hỏi.",
        error: err.message,
      });
    }
  }

  async getPracticeSessionResult(req, res) {
    try {
      const { sessionId, totalTime } = req.body;
      const userId = req.user.user_id;
      if (!sessionId) {
        return res.status(400).json({
          status: 400,
          message: "Thiếu sessionId",
        });
      }
      const answers = await PracticeAnSwerService.getAnswersBySessionId(
        sessionId
      );
      if (!answers || answers.length === 0) {
        return res.status(400).json({
          status: 400,
          message: "Chưa có câu trả lời nào trong phiên luyện tập này.",
        });
      }

      const correctAnswers = answers.filter((ans) => ans.is_correct).length;
      const wrongAnswers = answers.filter((ans) => !ans.is_correct).length;
      const totalQuestions = answers.length;
      const score = ((correctAnswers / totalQuestions) * 100).toFixed(2);
      const data = {
        correct_answers: correctAnswers,
        total_time_seconds: totalTime,
        score: score,
        completed_at: new Date(),
      };

      const session = await PracticeSessionsService.updateSession(
        sessionId,
        data,
        userId
      );
      console.log("Session data:", session.totalTime);

      await QuestionPracticeService.createStudyTimeLog({
        user_id: userId,
        activity_type: "practice",
        skill_id: session.skill_id,
        topic_id: session.topic_id,
        session_id: session.session_id,
        study_time_minutes: totalTime / 60,
        study_date: new Date(session.completed_at).toISOString().split("T")[0],
      });

      res.status(200).json({
        status: 200,
        message: "Hoàn thành phiên luyện tập",
        result: {
          session_id: session.session_id,
          user_id: session.user_id,
          skill_id: session.skill_id,
          topic_id: session.topic_id,
          correct_answers: correctAnswers,
          wrong_answers: wrongAnswers,
          total_time_seconds: totalTime,
          score: score,
          completed_at: session.completed_at,
        },
      });
    } catch (err) {
      res.status(500).json({
        status: 500,
        message: "Lỗi khi lấy kết quả phiên làm bài.",
        error: err.message,
      });
    }
  }
  async getPracticeStatistical(req, res) {
    try {
      const userId = req.user.user_id;
      const statistical = await QuestionPracticeService.getPracticeStatistical(
        userId
      );
      res.status(200).json({ status: 200, data: statistical });
    } catch (err) {
      res.status(500).json({
        status: 500,
        message: "Lỗi khi thống kê tiến độ.",
        error: err.message,
      });
    }
  }

  async getTotalQuestionByTopicAndSkill(req, res) {
    try {
      const { skillId } = req.body;
      const userId = req.user.user_id;

      if (!skillId) {
        return res.status(400).json({
          status: 400,
          message: "Thiếu thông tin cần thiết",
        });
      }

      const totalQuestions =
        await QuestionPracticeService.getTotalQuestionByTopicAndSkill(
          userId,
          skillId
        );
      res.status(200).json({
        status: 200,
        total_questions: totalQuestions,
      });
    } catch (err) {
      res.status(500).json({
        status: 500,
        message: "Lỗi khi lấy tổng số câu hỏi theo chủ đề và kỹ năng.",
        error: err.message,
      });
    }
  }

  async getTotalQuestionByTopic(req, res) {
    try {
      const { topicId } = req.body;
      if (!topicId) {
        return res.status(400).json({
          status: 400,
          message: "Thiếu topicId",
        });
      }
      const totalQuestions =
        await QuestionPracticeService.getTotalQuestionByTopic(topicId);
      res.status(200).json({
        status: 200,
        total_questions: totalQuestions,
      });
    } catch (err) {
      res.status(500).json({
        status: 500,
        message: "Lỗi khi lấy tổng số câu hỏi theo chủ đề.",
        error: err.message,
      });
    }
  }

  async getStudyTimeLast7Days(req, res) {
    try {
      const userId = req.user.user_id;
      const timeLog = await QuestionPracticeService.getStudyTimeLast7Days(
        userId
      );
      res.status(200).json({ status: 200, timeLog });
    } catch (err) {
      res.status(500).json({
        status: 500,
        message: "Lỗi khi lấy kỹ năng theo chủ đề.",
        error: err.message,
      });
    }
  }

  async getRank(req, res) {
    try {
      let { skillId, type } = req.body;
      const rankData = await QuestionPracticeService.getRank({
        skill_id: skillId,
        type,
      });
      res.status(200).json({ status: 200, data: rankData });
    } catch (err) {
      res.status(500).json({
        status: 500,
        message: "Lỗi khi lấy bảng xếp hạng.",
        error: err.message,
      });
    }
  }
}

module.exports = new QuestionPracticeController();
