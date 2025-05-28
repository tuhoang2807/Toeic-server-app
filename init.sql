CREATE DATABASE IF NOT EXISTS toeic_app_db;
USE toeic_app_db;
-- 1. BẢNG USERS - Quản lý người dùng (admin và user thường)
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT, -- ID duy nhất cho người dùng
    username VARCHAR(50) UNIQUE NOT NULL, -- Tên đăng nhập, không trùng lặp
    email VARCHAR(100) UNIQUE NOT NULL, -- Email duy nhất, dùng cho đăng nhập/quên mật khẩu
    password_hash VARCHAR(255) NOT NULL, -- Mật khẩu mã hóa
    full_name VARCHAR(100), -- Họ tên đầy đủ
    avatar_url VARCHAR(255), -- Link ảnh đại diện
    phone VARCHAR(20), -- Số điện thoại
    birth_date DATE, -- 🆕 Ngày sinh
    role ENUM('admin', 'user') DEFAULT 'user', -- Vai trò: admin hoặc user
    is_active BOOLEAN DEFAULT TRUE, -- Tài khoản có hoạt động không
    reset_token VARCHAR(255), -- Token để reset mật khẩu
    reset_token_expires DATETIME, -- Thời gian hết hạn của token
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Thời gian tạo tài khoản
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP -- Thời gian cập nhật
);


-- 2. BẢNG TOPICS - Quản lý chủ đề (Sport, School, Music, v.v.)
CREATE TABLE topics (
    topic_id INT PRIMARY KEY AUTO_INCREMENT, -- ID duy nhất cho chủ đề
    name VARCHAR(100) NOT NULL, -- Tên chủ đề
    slug VARCHAR(100) UNIQUE NOT NULL, -- Slug cho URL hoặc truy vấn
    description TEXT, -- Mô tả chủ đề
    image_url VARCHAR(255), -- Link ảnh đại diện cho chủ đề
    is_active BOOLEAN DEFAULT TRUE, -- Chủ đề có hoạt động không
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Thời gian tạo
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP -- Thời gian cập nhật
);

-- 3. BẢNG SKILLS - Quản lý 4 kỹ năng (Listening, Reading, Vocabulary, Grammar)
CREATE TABLE skills (
    skill_id INT PRIMARY KEY AUTO_INCREMENT, -- ID duy nhất cho kỹ năng
    name VARCHAR(50) NOT NULL, -- Tên kỹ năng
    slug VARCHAR(50) UNIQUE NOT NULL, -- Slug cho URL hoặc truy vấn
    description TEXT, -- Mô tả kỹ năng
    is_active BOOLEAN DEFAULT TRUE, -- Kỹ năng có hoạt động không
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Thời gian tạo
);

-- 4. BẢNG QUESTIONS_PRACTICE - Lưu tất cả câu hỏi (luyện tập)
CREATE TABLE questions_practice (
    question_id INT PRIMARY KEY AUTO_INCREMENT, -- ID duy nhất cho câu hỏi
    skill_id INT NOT NULL, -- ID kỹ năng (Listening, Reading, v.v.)
    topic_id INT, -- ID chủ đề (null nếu là câu hỏi thi)
    question_text TEXT NOT NULL, -- Nội dung câu hỏi
    audio_url VARCHAR(255), -- Link audio cho câu hỏi Listening
    image_url VARCHAR(255), -- Link ảnh cho câu hỏi Listening nhìn hình
    options JSON NOT NULL, -- Đáp án dạng JSON (ví dụ: ["A: Option 1", "B: Option 2", ...])
    correct_answer VARCHAR(50) NOT NULL, -- Đáp án đúng (A, B, C, D)
    explanation TEXT, -- Giải thích đáp án
    is_active BOOLEAN DEFAULT TRUE, -- Câu hỏi có hoạt động không
    created_by INT, -- ID admin tạo câu hỏi
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Thời gian tạo
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Thời gian cập nhật
    FOREIGN KEY (skill_id) REFERENCES skills(skill_id) ON DELETE CASCADE,
    FOREIGN KEY (topic_id) REFERENCES topics(topic_id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE SET NULL
);

-- 5. BẢNG TEST_SETS - Quản lý các bộ đề thi (Mini Test & Full Test)
CREATE TABLE test_sets (
    test_set_id INT PRIMARY KEY AUTO_INCREMENT, -- ID duy nhất cho bộ đề
    name VARCHAR(100) NOT NULL, -- Tên bộ đề (ví dụ: "Mini Test 1", "Full Test 1")
    type ENUM('mini_test', 'full_test') NOT NULL, -- Loại test
    total_questions INT NOT NULL, -- Tổng số câu hỏi (100 cho mini, 200 cho full)
    time_limit INT NOT NULL, -- Thời gian làm bài (phút) - 60 cho mini, 120 cho full
    description TEXT, -- Mô tả bộ đề
    is_active BOOLEAN DEFAULT TRUE, -- Bộ đề có hoạt động không
    created_by INT, -- ID admin tạo bộ đề
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE SET NULL
);

-- 6. BẢNG QUESTIONS_TEST - Câu hỏi cho bài thi (Mini Test & Full Test)
CREATE TABLE questions_test (
    question_id INT PRIMARY KEY AUTO_INCREMENT,
    test_set_id INT NOT NULL, -- ID bộ đề chứa câu hỏi này
    part_number INT NOT NULL, -- Part trong TOEIC (1-7)
    question_number INT NOT NULL, -- Số thứ tự câu hỏi trong bộ đề
    question_text TEXT NOT NULL, -- Nội dung câu hỏi
    audio_url VARCHAR(255), -- Link audio (cho Listening)
    image_url VARCHAR(255), -- Link ảnh (cho Part 1)
    passage_text TEXT, -- Đoạn văn (cho Reading parts)
    options JSON NOT NULL, -- Các lựa chọn A, B, C, D
    correct_answer VARCHAR(5) NOT NULL, -- Đáp án đúng
    explanation TEXT, -- Giải thích đáp án
    is_active BOOLEAN DEFAULT TRUE,
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (test_set_id) REFERENCES test_sets(test_set_id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE SET NULL,
    UNIQUE KEY unique_question_per_set (test_set_id, question_number)
);

-- 7. BẢNG PRACTICE_SESSIONS - Lưu phiên luyện tập kỹ năng
CREATE TABLE practice_sessions (
    session_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL, -- ID người dùng
    skill_id INT NOT NULL, -- ID kỹ năng
    topic_id INT, -- ID chủ đề (có thể null nếu luyện tập tổng hợp)
    total_questions INT NOT NULL, -- Tổng số câu hỏi trong phiên
    correct_answers INT DEFAULT 0, -- Số câu trả lời đúng
    total_time_seconds INT, -- Tổng thời gian làm bài (giây)
    score DECIMAL(5,2), -- Điểm số (tính theo %)
    completed_at TIMESTAMP NULL, -- Thời gian hoàn thành (null nếu chưa hoàn thành)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (skill_id) REFERENCES skills(skill_id) ON DELETE CASCADE,
    FOREIGN KEY (topic_id) REFERENCES topics(topic_id) ON DELETE CASCADE
);

-- 8. BẢNG PRACTICE_ANSWERS - Lưu chi tiết câu trả lời trong phiên luyện tập
CREATE TABLE practice_answers (
    answer_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL, -- ID người dùng
    session_id INT NOT NULL, -- ID phiên luyện tập
    question_id INT NOT NULL, -- ID câu hỏi
    user_answer VARCHAR(5), -- Câu trả lời của user (A, B, C, D hoặc null nếu bỏ qua)
    is_correct BOOLEAN, -- Câu trả lời có đúng không
    time_taken_seconds INT, -- Thời gian làm câu này (giây)
    answered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (session_id) REFERENCES practice_sessions(session_id) ON DELETE CASCADE,
    FOREIGN KEY (question_id) REFERENCES questions_practice(question_id) ON DELETE CASCADE
);

-- 9. BẢNG TEST_ATTEMPTS - Lưu lần làm bài thi
CREATE TABLE test_attempts (
    attempt_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL, -- ID người dùng
    test_set_id INT NOT NULL, -- ID bộ đề thi
    total_questions INT NOT NULL, -- Tổng số câu hỏi
    correct_answers INT DEFAULT 0, -- Số câu trả lời đúng
    listening_score INT DEFAULT 0, -- Điểm Listening
    reading_score INT DEFAULT 0, -- Điểm Reading
    total_score INT DEFAULT 0, -- Tổng điểm TOEIC
    time_taken_seconds INT, -- Thời gian làm bài thực tế
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Thời gian bắt đầu
    completed_at TIMESTAMP NULL, -- Thời gian hoàn thành
    status ENUM('in_progress', 'completed', 'abandoned') DEFAULT 'in_progress',
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (test_set_id) REFERENCES test_sets(test_set_id) ON DELETE CASCADE
);

-- 10. BẢNG TEST_ANSWERS - Lưu chi tiết câu trả lời trong bài thi
CREATE TABLE test_answers (
    answer_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL, -- ID người dùng
    attempt_id INT NOT NULL, -- ID lần làm bài thi
    question_id INT NOT NULL, -- ID câu hỏi
    user_answer VARCHAR(5), -- Câu trả lời của user
    is_correct BOOLEAN, -- Câu trả lời có đúng không
    time_taken_seconds INT, -- Thời gian làm câu này
    answered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (attempt_id) REFERENCES test_attempts(attempt_id) ON DELETE CASCADE,
    FOREIGN KEY (question_id) REFERENCES questions_test(question_id) ON DELETE CASCADE
);

-- 11. BẢNG STUDY_TIME_LOG - Lưu thời gian học của user (cho thống kê)
CREATE TABLE study_time_log (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL, -- ID người dùng
    activity_type ENUM('practice', 'mini_test', 'full_test') NOT NULL, -- Loại hoạt động
    skill_id INT, -- ID kỹ năng (null nếu là test)
    topic_id INT, -- ID chủ đề (null nếu là test)
    session_id INT, -- ID phiên luyện tập hoặc attempt_id
    study_time_minutes INT NOT NULL, -- Thời gian học (phút)
    study_date DATE NOT NULL, -- Ngày học
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (skill_id) REFERENCES skills(skill_id) ON DELETE CASCADE,
    FOREIGN KEY (topic_id) REFERENCES topics(topic_id) ON DELETE CASCADE,
    INDEX idx_user_date (user_id, study_date)
);

-- 12. BẢNG LEADERBOARD - Bảng xếp hạng
CREATE TABLE leaderboard (
    leaderboard_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL, -- ID người dùng
    category ENUM('listening', 'reading', 'vocabulary', 'grammar', 'mini_test', 'full_test') NOT NULL,
    best_score DECIMAL(5,2) NOT NULL, -- Điểm cao nhất
    total_attempts INT DEFAULT 0, -- Tổng số lần thử
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_category (user_id, category)
);



-- ====================================================
-- CÁC VIEW HỖ TRỢ THỐNG KÊ
-- ====================================================

-- View thống kê tổng quan user
CREATE VIEW user_statistics AS
SELECT 
    u.user_id,
    u.full_name,
    u.username,
    COUNT(DISTINCT ps.session_id) as total_practice_sessions,
    COUNT(DISTINCT ta.attempt_id) as total_test_attempts,
    AVG(ta.total_score) as avg_test_score,
    SUM(stl.study_time_minutes) as total_study_minutes
FROM users u
LEFT JOIN practice_sessions ps ON u.user_id = ps.user_id
LEFT JOIN test_attempts ta ON u.user_id = ta.user_id AND ta.status = 'completed'
LEFT JOIN study_time_log stl ON u.user_id = stl.user_id
WHERE u.role = 'user'
GROUP BY u.user_id;

-- View bảng xếp hạng tổng hợp
CREATE VIEW leaderboard_summary AS
SELECT 
    u.user_id,
    u.full_name,
    u.username,
    l.category,
    l.best_score,
    l.total_attempts,
    RANK() OVER (PARTITION BY l.category ORDER BY l.best_score DESC) as ranking
FROM users u
JOIN leaderboard l ON u.user_id = l.user_id
WHERE u.is_active = TRUE
ORDER BY l.category, l.best_score DESC;

-- ====================================================
-- CÁC INDEX TỐI ƯU HIỆU SUẤT
-- ====================================================

-- Index cho tìm kiếm câu hỏi luyện tập
CREATE INDEX idx_questions_practice_skill_topic ON questions_practice(skill_id, topic_id, is_active);

-- Index cho tìm kiếm câu hỏi thi
CREATE INDEX idx_questions_test_set_part ON questions_test(test_set_id, part_number);

-- Index cho thống kê user
CREATE INDEX idx_practice_sessions_user_skill ON practice_sessions(user_id, skill_id, completed_at);
CREATE INDEX idx_test_attempts_user_completed ON test_attempts(user_id, completed_at, status);

-- Index cho leaderboard
CREATE INDEX idx_leaderboard_category_score ON leaderboard(category, best_score DESC);

-- ====================================================
-- CÁC STORED PROCEDURE HỖ TRỢ
-- ====================================================

DELIMITER //

-- Procedure cập nhật leaderboard
CREATE PROCEDURE UpdateLeaderboard(
    IN p_user_id INT,
    IN p_category VARCHAR(50),
    IN p_score DECIMAL(5,2)
)
BEGIN
    INSERT INTO leaderboard (user_id, category, best_score, total_attempts)
    VALUES (p_user_id, p_category, p_score, 1)
    ON DUPLICATE KEY UPDATE
        best_score = GREATEST(best_score, p_score),
        total_attempts = total_attempts + 1;
END //

-- Procedure lấy câu hỏi random cho luyện tập
CREATE PROCEDURE GetRandomPracticeQuestions(
    IN p_skill_id INT,
    IN p_topic_id INT,
    IN p_limit INT
)
BEGIN
    SELECT * FROM questions_practice
    WHERE skill_id = p_skill_id 
    AND (p_topic_id IS NULL OR topic_id = p_topic_id)
    AND is_active = TRUE
    ORDER BY RAND()
    LIMIT p_limit;
END //

DELIMITER ;

-- ====================================================
-- DỮ LIỆU MẪU
-- ====================================================

INSERT INTO skills (name, slug, description) VALUES
('Listening', 'listening', 'Kỹ năng nghe hiểu'),
('Reading', 'reading', 'Kỹ năng đọc hiểu'),
('Vocabulary', 'vocabulary', 'Từ vựng'),
('Grammar', 'grammar', 'Ngữ pháp');

INSERT INTO topics (name, slug, description) VALUES
('Sport', 'sport', 'Chủ đề thể thao'),
('School', 'school', 'Chủ đề trường học'),
('Music', 'music', 'Chủ đề âm nhạc'),
('Travel', 'travel', 'Chủ đề du lịch'),
('Technology', 'technology', 'Chủ đề công nghệ'),
('Environment', 'environment', 'Chủ đề môi trường'),
('Health', 'health', 'Chủ đề sức khỏe'),
('Food', 'food', 'Chủ đề ẩm thực');

INSERT INTO users (username, email, password_hash, full_name, role) VALUES
('admin', 'admin@toeicapp.com', '$2b$10$tsYG7z3.paHe4Mg6a1N8tOrVZ7P.b7GHdWMrzJ6l/E.O67q6VXri6', 'Administrator', 'admin'),

('tulh', 'lait@example.com', '$2b$10$tsYG7z3.paHe4Mg6a1N8tOrVZ7P.b7GHdWMrzJ6l/E.O67q6VXri6', 'Lại Hoàng Tú', 'user'),

('quannm', 'nguyennmt@example.com', '$2b$10$tsYG7z3.paHe4Mg6a1N8tOrVZ7P.b7GHdWMrzJ6l/E.O67q6VXri6', 'Nguyễn Minh Quân', 'user'),

('phucnb', 'nguyenbp@example.com', '$2b$10$tsYG7z3.paHe4Mg6a1N8tOrVZ7P.b7GHdWMrzJ6l/E.O67q6VXri6', 'Nguyễn Bảo Phúc', 'user'),

('hunglh', 'lehung@example.com', '$2b$10$tsYG7z3.paHe4Mg6a1N8tOrVZ7P.b7GHdWMrzJ6l/E.O67q6VXri6', 'Lê Hữu Hùng', 'user'),

('capnt', 'nguyentc@example.com', '$2b$10$tsYG7z3.paHe4Mg6a1N8tOrVZ7P.b7GHdWMrzJ6l/E.O67q6VXri6', 'Nguyễn Tiến Cấp', 'user');



-- ====================================================
-- DỮ LIỆU MẪU CHO CÂU HỎI LUYỆN TẬP
-- ====================================================

-- Câu hỏi Listening - Sport
INSERT INTO questions_practice (skill_id, topic_id, question_text, audio_url, options, correct_answer, explanation, created_by) VALUES
(1, 1, 'What sport is the man talking about?', 'https://example.com/audio/sport1.mp3', '["A: Soccer", "B: Basketball", "C: Tennis", "D: Swimming"]', 'A', 'The man mentions kicking the ball, which indicates soccer.', 1),
(1, 1, 'Where does the conversation take place?', 'https://example.com/audio/sport2.mp3', '["A: At a gym", "B: At a stadium", "C: At a park", "D: At home"]', 'B', 'Background noise suggests a stadium environment.', 1),
(1, 1, 'When does the game start?', 'https://example.com/audio/sport3.mp3', '["A: 2:00 PM", "B: 3:00 PM", "C: 4:00 PM", "D: 5:00 PM"]', 'B', 'The speaker clearly states 3 oclock.', 1);

-- Câu hỏi Reading - School
INSERT INTO questions_practice (skill_id, topic_id, question_text, options, correct_answer, explanation, created_by) VALUES
(2, 2, 'According to the passage, what is the main purpose of the new library system?', '["A: To save money", "B: To improve student access", "C: To reduce staff", "D: To update technology"]', 'B', 'The passage emphasizes better access for students.', 1),
(2, 2, 'The word "comprehensive" in line 3 is closest in meaning to:', '["A: Complete", "B: Expensive", "C: Modern", "D: Simple"]', 'A', 'Comprehensive means complete or thorough.', 1);

-- Câu hỏi Vocabulary - Technology  
INSERT INTO questions_practice (skill_id, topic_id, question_text, options, correct_answer, explanation, created_by) VALUES
(3, 5, 'The new software will _____ our productivity significantly.', '["A: enhance", "B: reduce", "C: complicate", "D: ignore"]', 'A', 'Enhance means to improve or make better.', 1),
(3, 5, 'We need to _____ the system before implementing the changes.', '["A: destroy", "B: test", "C: sell", "D: hide"]', 'B', 'Testing is essential before implementing changes.', 1);

-- Câu hỏi Grammar - Environment
INSERT INTO questions_practice (skill_id, topic_id, question_text, options, correct_answer, explanation, created_by) VALUES
(4, 6, 'If we _____ more trees, the air quality would improve.', '["A: plant", "B: planted", "C: will plant", "D: have planted"]', 'B', 'Second conditional uses past tense in if-clause.', 1),
(4, 6, 'The pollution level _____ dramatically over the past decade.', '["A: increases", "B: increased", "C: has increased", "D: will increase"]', 'C', 'Present perfect tense for actions continuing to present.', 1);

-- Thêm câu hỏi cho tất cả các chủ đề còn lại
INSERT INTO questions_practice (skill_id, topic_id, question_text, audio_url, options, correct_answer, explanation, created_by) VALUES
-- Music - Listening
(1, 3, 'What instrument is being played?', 'https://example.com/audio/music1.mp3', '["A: Piano", "B: Guitar", "C: Violin", "D: Drums"]', 'A', 'The sound is clearly from a piano.', 1),
-- Travel - Reading  
(2, 4, 'What is required for the visa application?', NULL, '["A: Passport only", "B: Passport and photos", "C: Photos only", "D: No documents"]', 'B', 'The text mentions both passport and photos are required.', 1),
-- Health - Vocabulary
(3, 7, 'Regular exercise can _____ your immune system.', NULL, '["A: weaken", "B: strengthen", "C: damage", "D: ignore"]', 'B', 'Exercise strengthens the immune system.', 1),
-- Food - Grammar
(4, 8, 'I would rather _____ at home than go to a restaurant.', NULL, '["A: cook", "B: cooking", "C: cooked", "D: to cook"]', 'A', 'Would rather is followed by base form of verb.', 1);


-- ====================================================
-- DỮ LIỆU MẪU CHO BỘ ĐỀ THI
-- ====================================================

-- Tạo bộ đề Mini Test
INSERT INTO test_sets (name, type, total_questions, time_limit, description, created_by) VALUES
('Mini Test 1', 'mini_test', 100, 60, 'First mini test for practice', 1),
('Mini Test 2', 'mini_test', 100, 60, 'Second mini test for practice', 1),
('Mini Test 3', 'mini_test', 100, 60, 'Third mini test for practice', 1);

-- Tạo bộ đề Full Test  
INSERT INTO test_sets (name, type, total_questions, time_limit, description, created_by) VALUES
('Full Test 1', 'full_test', 200, 120, 'Complete TOEIC simulation test', 1),
('Full Test 2', 'full_test', 200, 120, 'Advanced TOEIC practice test', 1);

-- ====================================================
-- CÂU HỎI CHO MINI TEST 1 (Mẫu một số câu)
-- ====================================================

-- Part 1: Listening - Pictures (6 câu)
INSERT INTO questions_test (test_set_id, part_number, question_number, question_text, audio_url, image_url, options, correct_answer, explanation, created_by) VALUES
(1, 1, 1, 'Look at the picture and listen to the four statements. Choose the statement that best describes what you see.', 'https://example.com/test/mini1/part1_q1.mp3', 'https://example.com/test/mini1/part1_q1.jpg', '["A: The man is reading a book", "B: The woman is typing on computer", "C: The people are having meeting", "D: The office is empty"]', 'C', 'The image shows people in a meeting room.', 1),
(1, 1, 2, 'Look at the picture and listen to the four statements.', 'https://example.com/test/mini1/part1_q2.mp3', 'https://example.com/test/mini1/part1_q2.jpg', '["A: The car is parked", "B: The man is driving", "C: The road is empty", "D: The traffic light is red"]', 'A', 'The car is clearly parked in the image.', 1),
(1, 1, 3, 'Look at the picture and listen to the four statements.', 'https://example.com/test/mini1/part1_q3.mp3', 'https://example.com/test/mini1/part1_q3.jpg', '["A: The woman is cooking", "B: The kitchen is clean", "C: The stove is on", "D: The woman is washing dishes"]', 'D', 'The woman is at the sink washing dishes.', 1);

-- Part 2: Question-Response (25 câu - mẫu một số câu)
INSERT INTO questions_test (test_set_id, part_number, question_number, question_text, audio_url, options, correct_answer, explanation, created_by) VALUES
(1, 2, 7, 'Where is the nearest bank?', 'https://example.com/test/mini1/part2_q7.mp3', '["A: Its on Main Street", "B: At 9 AM", "C: Yes, I do"]', 'A', 'Where questions require location answers.', 1),
(1, 2, 8, 'When does the meeting start?', 'https://example.com/test/mini1/part2_q8.mp3', '["A: In the conference room", "B: At 2 PM", "C: Mr. Johnson"]', 'B', 'When questions require time answers.', 1),
(1, 2, 9, 'Who is responsible for this project?', 'https://example.com/test/mini1/part2_q9.mp3', '["A: Last week", "B: Very important", "C: Sarah is"]', 'C', 'Who questions require person answers.', 1);

-- Part 5: Incomplete Sentences (30 câu - mẫu một số câu)  
INSERT INTO questions_test (test_set_id, part_number, question_number, question_text, options, correct_answer, explanation, created_by) VALUES
(1, 5, 51, 'The meeting has been _____ until next Monday due to scheduling conflicts.', '["A: postponed", "B: postpone", "C: postponing", "D: postpones"]', 'A', 'Present perfect passive requires past participle.', 1),
(1, 5, 52, 'All employees must _____ their ID badges while on company premises.', '["A: wear", "B: wearing", "C: wore", "D: worn"]', 'A', 'Must is followed by base form of verb.', 1),
(1, 5, 53, 'The quarterly report shows _____ improvement in sales figures.', '["A: signify", "B: significant", "C: significantly", "D: significance"]', 'B', 'Need adjective to modify noun improvement.', 1);

-- ====================================================
-- DỮ LIỆU MẪU LỊCH SỬ LUYỆN TẬP
-- ====================================================

-- Practice Sessions của user John Doe (user_id = 2)
INSERT INTO practice_sessions (user_id, skill_id, topic_id, total_questions, correct_answers, total_time_seconds, score, completed_at) VALUES
(2, 1, 1, 10, 8, 600, 80.00, '2024-01-15 10:30:00'),
(2, 1, 2, 10, 7, 720, 70.00, '2024-01-16 14:20:00'),
(2, 2, 3, 10, 9, 900, 90.00, '2024-01-17 09:15:00'),
(2, 3, 5, 10, 6, 480, 60.00, '2024-01-18 16:45:00'),
(2, 4, 6, 10, 8, 540, 80.00, '2024-01-19 11:30:00');

-- Practice Answers cho session đầu tiên  
-- Practice Answers cho session đầu tiên  
INSERT INTO practice_answers (user_id, session_id, question_id, user_answer, is_correct, time_taken_seconds) VALUES
(2, 1, 1, 'A', 1, 45),
(2, 1, 2, 'C', 0, 60),
(2, 1, 3, 'B', 1, 50);


-- Test Attempts của user John Doe
INSERT INTO test_attempts (user_id, test_set_id, total_questions, correct_answers, listening_score, reading_score, total_score, time_taken_seconds, started_at, completed_at, status) VALUES
(2, 1, 100, 75, 380, 390, 770, 3200, '2024-01-20 09:00:00', '2024-01-20 10:53:20', 'completed'),
(2, 4, 200, 145, 420, 435, 855, 6800, '2024-01-25 13:00:00', '2024-01-25 14:53:20', 'completed');

-- Test Attempts của user Jane Smith  
INSERT INTO test_attempts (user_id, test_set_id, total_questions, correct_answers, listening_score, reading_score, total_score, time_taken_seconds, started_at, completed_at, status) VALUES
(3, 1, 100, 68, 350, 360, 710, 3450, '2024-01-21 10:00:00', '2024-01-21 11:57:30', 'completed'),
(3, 2, 100, 72, 370, 375, 745, 3300, '2024-01-22 14:00:00', '2024-01-22 15:55:00', 'completed');

-- ====================================================
-- DỮ LIỆU STUDY TIME LOG
-- ====================================================

INSERT INTO study_time_log (user_id, activity_type, skill_id, topic_id, session_id, study_time_minutes, study_date) VALUES
(2, 'practice', 1, 1, 1, 10, '2024-01-15'),
(2, 'practice', 1, 2, 2, 12, '2024-01-16'),
(2, 'practice', 2, 3, 3, 15, '2024-01-17'),
(2, 'practice', 3, 5, 4, 8, '2024-01-18'),
(2, 'practice', 4, 6, 5, 9, '2024-01-19'),
(2, 'mini_test', NULL, NULL, 1, 53, '2024-01-20'),
(2, 'full_test', NULL, NULL, 2, 113, '2024-01-25'),
(3, 'mini_test', NULL, NULL, 3, 58, '2024-01-21'),
(3, 'mini_test', NULL, NULL, 4, 55, '2024-01-22');

-- ====================================================
-- DỮ LIỆU LEADERBOARD
-- ====================================================

-- INSERT INTO leaderboard (user_id, category, best_score, total_attempts) VALUES
-- (2, 'listening', 85.00, 5),
-- (2, 'reading', 90.00, 4),
-- (2, 'vocabulary', 75.00, 3),
-- (2, 'grammar', 80.00, 2),
-- (2, 'mini_test', 770.00, 1),
-- (2, 'full_test', 855.00, 1),
-- (3, 'listening', 78.00, 3),
-- (3, 'reading', 82.00, 4),
-- (3, 'mini_test', 745.00, 2),
-- (4, 'listening', 70.00, 2),
-- (4, 'vocabulary', 65.00, 1);