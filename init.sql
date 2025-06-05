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
    birth_date DATE, --  Ngày sinh
    role ENUM('admin', 'user') DEFAULT 'user', -- Vai trò: admin hoặc user
    is_active BOOLEAN DEFAULT TRUE, -- Tài khoản có hoạt động không
    reset_token VARCHAR(255), -- Token để reset mật khẩu
    reset_token_expires DATETIME, -- Thời gian hết hạn của token
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Thời gian tạo tài khoản
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP -- Thời gian cập nhật
);


-- 2. BẢNG SKILLS - Quản lý 4 kỹ năng (Listening, Reading, Vocabulary, Grammar)
CREATE TABLE skills (
    skill_id INT PRIMARY KEY AUTO_INCREMENT, -- ID duy nhất cho kỹ năng
    name VARCHAR(50) NOT NULL, -- Tên kỹ năng
    slug VARCHAR(50) UNIQUE NOT NULL, -- Slug cho URL hoặc truy vấn
    description TEXT, -- Mô tả kỹ năng
    is_active BOOLEAN DEFAULT TRUE, -- Kỹ năng có hoạt động không
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Thời gian tạo
);


-- 3. BẢNG TOPICS - Quản lý chủ đề (Sport, School, Music, v.v.)
CREATE TABLE topics (
    topic_id INT PRIMARY KEY AUTO_INCREMENT, -- ID duy nhất cho chủ đề
    skill_id INT NOT NULL, -- ID kỹ năng liên quan (Listening, Reading, v.v.)
    name VARCHAR(100) NOT NULL, -- Tên chủ đề
    slug VARCHAR(100) UNIQUE NOT NULL, -- Slug cho URL hoặc truy vấn
    description TEXT, -- Mô tả chủ đề
    image_url VARCHAR(255), -- Link ảnh đại diện cho chủ đề
    is_active BOOLEAN DEFAULT TRUE, -- Chủ đề có hoạt động không
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Thời gian tạo
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Thời gian cập nhật
    FOREIGN KEY (skill_id) REFERENCES skills(skill_id) ON DELETE CASCADE -- Liên kết với bảng skills
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
    total_score FLOAT DEFAULT 0, -- Tổng điểm TOEIC
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
-- DỮ LIỆU MẪU
-- ====================================================

INSERT INTO skills (name, slug, description) VALUES
('Listening', 'listening', 'Kỹ năng nghe hiểu các đoạn hội thoại, tin tức, và tình huống hàng ngày.'),
('Reading', 'reading', 'Kỹ năng đọc hiểu văn bản tiếng Anh như bài báo, truyện ngắn, và email.'),
('Vocabulary', 'vocabulary', 'Tăng vốn từ vựng theo chủ đề như đồ ăn, du lịch, công nghệ.'),
('Grammar', 'grammar', 'Ngữ pháp tiếng Anh bao gồm thì, câu điều kiện, mệnh đề, loại từ.');


-- 1. Listening Topics (skill_id = 1)
INSERT INTO topics (skill_id, name, slug, description, image_url) VALUES
(1, 'Sport', 'sport-listening', 'Nghe các đoạn hội thoại về thể thao.', 'https://picsum.photos/id/201/200'),
(1, 'School', 'school-listening', 'Nghe tình huống ở trường học.', 'https://picsum.photos/id/202/200'),
(1, 'Music', 'music-listening', 'Nghe về các thể loại nhạc và nghệ sĩ.', 'https://picsum.photos/id/203/200'),
(1, 'Travel', 'travel-listening', 'Nghe các hội thoại khi đi du lịch.', 'https://picsum.photos/id/204/200'),
(1, 'Technology', 'technology-listening', 'Nghe podcast về công nghệ.', 'https://picsum.photos/id/205/200'),
(1, 'Environment', 'environment-listening', 'Nghe về các vấn đề môi trường.', 'https://picsum.photos/id/206/200'),
(1, 'Health', 'health-listening', 'Nghe về sức khỏe và lối sống.', 'https://picsum.photos/id/207/200'),
(1, 'Food', 'food-listening', 'Nghe mô tả món ăn và công thức.', 'https://picsum.photos/id/208/200');


-- 2. Reading Topics (skill_id = 2)
INSERT INTO topics (skill_id, name, slug, description, image_url) VALUES
(2, 'Sport', 'sport-reading', 'Đọc bài viết về thể thao và vận động viên.', 'https://picsum.photos/id/301/200'),
(2, 'School', 'school-reading', 'Đọc bài học, nội quy trường học.', 'https://picsum.photos/id/302/200'),
(2, 'Music', 'music-reading', 'Đọc bài báo về âm nhạc và nghệ sĩ.', 'https://picsum.photos/id/303/200'),
(2, 'Travel', 'travel-reading', 'Đọc cẩm nang du lịch.', 'https://picsum.photos/id/304/200'),
(2, 'Technology', 'technology-reading', 'Đọc về phát minh và công nghệ mới.', 'https://picsum.photos/id/305/200'),
(2, 'Environment', 'environment-reading', 'Đọc về bảo vệ môi trường.', 'https://picsum.photos/id/306/200'),
(2, 'Health', 'health-reading', 'Đọc các mẹo sống khỏe.', 'https://picsum.photos/id/307/200'),
(2, 'Food', 'food-reading', 'Đọc công thức và đánh giá món ăn.', 'https://picsum.photos/id/308/200');


-- 3. Vocabulary Topics (skill_id = 3)
INSERT INTO topics (skill_id, name, slug, description, image_url) VALUES
(3, 'Sport', 'sport-vocabulary', 'Từ vựng liên quan đến thể thao.', 'https://picsum.photos/id/401/200'),
(3, 'School', 'school-vocabulary', 'Từ vựng về trường học.', 'https://picsum.photos/id/402/200'),
(3, 'Music', 'music-vocabulary', 'Từ vựng về âm nhạc, nhạc cụ.', 'https://picsum.photos/id/403/200'),
(3, 'Travel', 'travel-vocabulary', 'Từ vựng khi đi du lịch.', 'https://picsum.photos/id/404/200'),
(3, 'Technology', 'technology-vocabulary', 'Từ vựng công nghệ.', 'https://picsum.photos/id/405/200'),
(3, 'Environment', 'environment-vocabulary', 'Từ vựng về môi trường.', 'https://picsum.photos/id/406/200'),
(3, 'Health', 'health-vocabulary', 'Từ vựng về sức khỏe.', 'https://picsum.photos/id/407/200'),
(3, 'Food', 'food-vocabulary', 'Từ vựng về món ăn, nấu ăn.', 'https://picsum.photos/id/408/200');


-- 4. Grammar Topics (skill_id = 4)
INSERT INTO topics (skill_id, name, slug, description, image_url) VALUES
(4, 'Tenses', 'tenses', 'Các thì trong tiếng Anh: hiện tại, quá khứ, tương lai.', 'https://picsum.photos/id/1100/200'),
(4, 'Conditional Sentences', 'conditional-sentences', 'Câu điều kiện loại 1, 2, 3.', 'https://picsum.photos/id/1110/200'),
(4, 'Parts of Speech', 'parts-of-speech', 'Các loại từ: danh từ, động từ, trạng từ, tính từ.', 'https://picsum.photos/id/1120/200'),
(4, 'Passive Voice', 'passive-voice', 'Câu bị động trong tiếng Anh.', 'https://picsum.photos/id/1130/200');


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

INSERT INTO questions_practice (skill_id, topic_id, question_text, audio_url, options, correct_answer, explanation, created_by) VALUES
(1, 1, 'What sport is the man talking about?', 'https://example.com/audio/listening/sport/soccer_match_1.mp3', '["A: Soccer", "B: Basketball", "C: Tennis", "D: Swimming"]', 'A', 'The man mentions kicking a ball into a goal, which indicates soccer.', 1),
(1, 1, 'What does the woman say about the tennis tournament?', 'https://example.com/audio/listening/sport/tennis_tournament_1.mp3', '["A: It starts next week.", "B: It was canceled.", "C: It ended last month.", "D: It is free to watch."]', 'A', 'The woman says the tennis tournament is scheduled to start next week.', 1),
(1, 1, 'Where is the sports event taking place?', 'https://example.com/audio/listening/sport/event_announcement_1.mp3', '["A: City Stadium", "B: Central Park", "C: National Arena", "D: Sports Complex"]', 'C', 'The announcement mentions that the event is held at the National Arena.', 1),
(1, 1, 'What sport is the speaker describing?', 'https://example.com/audio/listening/sport/sport_description_1.mp3', '["A: Basketball", "B: Volleyball", "C: Baseball", "D: Rugby"]', 'B', 'The speaker describes hitting a ball over a net, which is volleyball.', 1),
(1, 1, 'Why was the match delayed?', 'https://example.com/audio/listening/sport/match_delay_1.mp3', '["A: Bad weather", "B: Player injury", "C: Technical issues", "D: Crowd problems"]', 'A', 'The conversation mentions heavy rain as the reason for the match delay.', 1),
(1, 1, 'What does the man say about his experience playing golf?', 'https://example.com/audio/listening/sport/golf_experience_1.mp3', '["A: He plays every weekend.", "B: He started last year.", "C: He dislikes it.", "D: He is a professional."]', 'B', 'The man says he started playing golf last year and enjoys it.', 1),
(1, 1, 'Which team won the championship?', 'https://example.com/audio/listening/sport/championship_news_1.mp3', '["A: Tigers", "B: Eagles", "C: Lions", "D: Bears"]', 'C', 'The news reports that the Lions won the championship this year.', 1),
(1, 1, 'What is the woman’s opinion about swimming?', 'https://example.com/audio/listening/sport/swimming_opinion_1.mp3', '["A: It is boring.", "B: It is relaxing.", "C: It is too difficult.", "D: It is expensive."]', 'B', 'The woman says swimming is relaxing and helps her stay fit.', 1),
(1, 1, 'What sport does the athlete compete in?', 'https://example.com/audio/listening/sport/athlete_interview_1.mp3', '["A: Athletics", "B: Gymnastics", "C: Swimming", "D: Cycling"]', 'A', 'The athlete mentions competing in track and field events, which is athletics.', 1),
(1, 1, 'What does the speaker say about the new sports facility?', 'https://example.com/audio/listening/sport/sports_facility_1.mp3', '["A: It is still under construction.", "B: It opened last month.", "C: It is too small.", "D: It is only for professionals."]', 'B', 'The speaker says the new sports facility opened last month.', 1),
(1, 1, 'What is the main topic of the sports podcast?', 'https://example.com/audio/listening/sport/sports_podcast_1.mp3', '["A: Football strategies", "B: Marathon training", "C: Basketball rules", "D: Tennis equipment"]', 'B', 'The podcast focuses on tips for marathon training.', 1),
(1, 1, 'Who is the guest speaker in the sports interview?', 'https://example.com/audio/listening/sport/guest_interview_1.mp3', '["A: A soccer coach", "B: A retired swimmer", "C: A tennis player", "D: A marathon runner"]', 'C', 'The guest is introduced as a professional tennis player.', 1),
(1, 1, 'What does the man say about the cycling event?', 'https://example.com/audio/listening/sport/cycling_event_1.mp3', '["A: It is an annual event.", "B: It is for amateurs only.", "C: It was postponed.", "D: It is free to join."]', 'A', 'The man mentions that the cycling event happens every year.', 1),
(1, 1, 'What is the score of the basketball game mentioned?', 'https://example.com/audio/listening/sport/basketball_score_1.mp3', '["A: 82-78", "B: 90-85", "C: 76-70", "D: 88-80"]', 'B', 'The announcer says the final score was 90-85.', 1),
(1, 1, 'What does the woman suggest for improving sports performance?', 'https://example.com/audio/listening/sport/performance_tips_1.mp3', '["A: More practice", "B: Better equipment", "C: Healthy diet", "D: Hiring a coach"]', 'C', 'The woman emphasizes the importance of a healthy diet for sports performance.', 1);


INSERT INTO questions_practice (skill_id, topic_id, question_text, audio_url, options, correct_answer, explanation, created_by) VALUES
(1, 2, 'What is the teacher announcing in the classroom?', 'https://example.com/audio/listening/school/classroom_announcement_1.mp3', '["A: A new homework assignment", "B: A school trip", "C: A schedule change", "D: A guest speaker"]', 'C', 'The teacher mentions that classes will start earlier tomorrow due to a schedule change.', 1),
(1, 2, 'What does the student ask the teacher about?', 'https://example.com/audio/listening/school/student_question_1.mp3', '["A: The exam date", "B: The homework deadline", "C: The textbook price", "D: The class location"]', 'A', 'The student asks when the final exam will take place.', 1),
(1, 2, 'Where is the school meeting being held?', 'https://example.com/audio/listening/school/school_meeting_1.mp3', '["A: Library", "B: Auditorium", "C: Cafeteria", "D: Gymnasium"]', 'B', 'The announcement states that the meeting is in the auditorium.', 1),
(1, 2, 'What subject is the teacher discussing?', 'https://example.com/audio/listening/school/subject_discussion_1.mp3', '["A: Math", "B: History", "C: Science", "D: Literature"]', 'C', 'The teacher talks about a science experiment planned for next week.', 1),
(1, 2, 'Why is the school library closed?', 'https://example.com/audio/listening/school/library_closure_1.mp3', '["A: Renovation", "B: Holiday", "C: Staff meeting", "D: Power outage"]', 'A', 'The announcement mentions that the library is closed for renovation.', 1),
(1, 2, 'What does the man say about the school club?', 'https://example.com/audio/listening/school/school_club_1.mp3', '["A: It meets every Friday.", "B: It is for new students only.", "C: It requires a fee.", "D: It is canceled."]', 'A', 'The man says the club meets every Friday after school.', 1),
(1, 2, 'What is the topic of the school assembly?', 'https://example.com/audio/listening/school/assembly_topic_1.mp3', '["A: School rules", "B: Sports day", "C: Career guidance", "D: Exam preparation"]', 'C', 'The speaker mentions that the assembly is about career guidance for students.', 1),
(1, 2, 'What does the woman suggest to improve the school event?', 'https://example.com/audio/listening/school/event_suggestion_1.mp3', '["A: More activities", "B: Better food", "C: Shorter duration", "D: Different location"]', 'A', 'The woman suggests adding more activities to make the event more engaging.', 1),
(1, 2, 'Who is speaking in the conversation?', 'https://example.com/audio/listening/school/conversation_speaker_1.mp3', '["A: A student", "B: A parent", "C: A teacher", "D: A principal"]', 'C', 'The speaker is addressing the class as a teacher.', 1),
(1, 2, 'What is the purpose of the school announcement?', 'https://example.com/audio/listening/school/announcement_purpose_1.mp3', '["A: Cancel a class", "B: Promote a fundraiser", "C: Announce a test", "D: Change a schedule"]', 'B', 'The announcement is about a fundraiser for the school library.', 1),
(1, 2, 'What does the student say about the new teacher?', 'https://example.com/audio/listening/school/new_teacher_1.mp3', '["A: She is strict.", "B: She is friendly.", "C: She is retiring.", "D: She is absent."]', 'B', 'The student describes the new teacher as friendly and approachable.', 1),
(1, 2, 'What is the school event mentioned in the conversation?', 'https://example.com/audio/listening/school/school_event_1.mp3', '["A: Talent show", "B: Science fair", "C: Sports day", "D: Book fair"]', 'A', 'The conversation mentions a talent show happening next month.', 1),
(1, 2, 'What does the teacher ask the students to do?', 'https://example.com/audio/listening/school/teacher_request_1.mp3', '["A: Submit homework", "B: Join a club", "C: Attend a meeting", "D: Read a book"]', 'A', 'The teacher reminds students to submit their homework by tomorrow.', 1),
(1, 2, 'What is the main topic of the school podcast?', 'https://example.com/audio/listening/school/podcast_topic_1.mp3', '["A: Study tips", "B: School history", "C: Club activities", "D: Exam schedules"]', 'A', 'The podcast focuses on effective study tips for students.', 1),
(1, 2, 'What does the woman say about the school cafeteria?', 'https://example.com/audio/listening/school/cafeteria_opinion_1.mp3', '["A: It is too expensive.", "B: It has new dishes.", "C: It is closed today.", "D: It needs cleaning."]', 'B', 'The woman mentions that the cafeteria introduced new dishes this week.', 1);


INSERT INTO questions_practice (skill_id, topic_id, question_text, audio_url, options, correct_answer, explanation, created_by) VALUES
(1, 3, 'What type of music is the man talking about?', 'https://example.com/audio/listening/music/music_type_1.mp3', '["A: Classical", "B: Pop", "C: Jazz", "D: Rock"]', 'C', 'The man mentions improvisation and saxophone, which indicates jazz.', 1),
(1, 3, 'What does the woman say about the concert?', 'https://example.com/audio/listening/music/concert_info_1.mp3', '["A: It is sold out.", "B: It is next weekend.", "C: It was canceled.", "D: It is free."]', 'B', 'The woman says the concert is scheduled for next weekend.', 1),
(1, 3, 'Where is the music festival taking place?', 'https://example.com/audio/listening/music/festival_location_1.mp3', '["A: City Park", "B: Concert Hall", "C: Beach", "D: Stadium"]', 'A', 'The announcement states that the music festival is in City Park.', 1),
(1, 3, 'What instrument is the speaker learning?', 'https://example.com/audio/listening/music/instrument_learning_1.mp3', '["A: Piano", "B: Guitar", "C: Violin", "D: Drums"]', 'B', 'The speaker mentions practicing chords on the guitar.', 1),
(1, 3, 'Why was the band’s performance delayed?', 'https://example.com/audio/listening/music/band_delay_1.mp3', '["A: Technical issues", "B: Late arrival", "C: Weather problems", "D: Low attendance"]', 'A', 'The conversation mentions technical issues with the sound system.', 1),
(1, 3, 'What does the man say about his favorite singer?', 'https://example.com/audio/listening/music/favorite_singer_1.mp3', '["A: She is retiring.", "B: She is very talented.", "C: She is new.", "D: She is unpopular."]', 'B', 'The man describes his favorite singer as very talented.', 1),
(1, 3, 'What is the theme of the music event?', 'https://example.com/audio/listening/music/event_theme_1.mp3', '["A: Rock music", "B: Classical music", "C: Folk music", "D: Pop music"]', 'C', 'The announcement mentions a folk music theme for the event.', 1),
(1, 3, 'What does the woman suggest for enjoying music?', 'https://example.com/audio/listening/music/music_suggestion_1.mp3', '["A: Buying CDs", "B: Attending concerts", "C: Listening online", "D: Learning an instrument"]', 'B', 'The woman suggests attending concerts for a better music experience.', 1),
(1, 3, 'Who is performing at the music show?', 'https://example.com/audio/listening/music/performer_1.mp3', '["A: A local band", "B: A famous singer", "C: A student group", "D: A DJ"]', 'B', 'The speaker mentions a famous singer performing at the show.', 1),
(1, 3, 'What is the purpose of the music workshop?', 'https://example.com/audio/listening/music/workshop_purpose_1.mp3', '["A: Teach music theory", "B: Promote new albums", "C: Discuss music history", "D: Practice singing"]', 'A', 'The workshop focuses on teaching music theory to beginners.', 1),
(1, 3, 'What does the student say about the music class?', 'https://example.com/audio/listening/music/music_class_1.mp3', '["A: It is boring.", "B: It is challenging.", "C: It is fun.", "D: It is expensive."]', 'C', 'The student describes the music class as fun and engaging.', 1),
(1, 3, 'What is the main topic of the music podcast?', 'https://example.com/audio/listening/music/podcast_topic_1.mp3', '["A: Music production", "B: Artist interviews", "C: Music history", "D: Concert reviews"]', 'B', 'The podcast features interviews with artists.', 1),
(1, 3, 'What does the man say about the new album?', 'https://example.com/audio/listening/music/new_album_1.mp3', '["A: It is disappointing.", "B: It is his favorite.", "C: It is too long.", "D: It is not released yet."]', 'B', 'The man says the new album is his favorite so far.', 1),
(1, 3, 'What is the name of the band mentioned?', 'https://example.com/audio/listening/music/band_name_1.mp3', '["A: Blue Stars", "B: Red Waves", "C: Green Notes", "D: Yellow Beats"]', 'A', 'The speaker mentions the band Blue Stars.', 1),
(1, 3, 'What does the woman say about music festivals?', 'https://example.com/audio/listening/music/festival_opinion_1.mp3', '["A: They are too crowded.", "B: They are exciting.", "C: They are expensive.", "D: They are boring."]', 'B', 'The woman describes music festivals as exciting and fun.', 1);


INSERT INTO questions_practice (skill_id, topic_id, question_text, audio_url, options, correct_answer, explanation, created_by) VALUES
(1, 4, 'What is the man planning to do on his trip?', 'https://example.com/audio/listening/travel/trip_plan_1.mp3', '["A: Visit museums", "B: Go hiking", "C: Attend a festival", "D: Relax at the beach"]', 'B', 'The man mentions planning to go hiking in the mountains.', 1),
(1, 4, 'What does the woman say about the train schedule?', 'https://example.com/audio/listening/travel/train_schedule_1.mp3', '["A: It is delayed.", "B: It is on time.", "C: It is canceled.", "D: It is fully booked."]', 'B', 'The woman says the train is running on time today.', 1),
(1, 4, 'Where is the travel agency located?', 'https://example.com/audio/listening/travel/agency_location_1.mp3', '["A: Downtown", "B: Near the airport", "C: In the mall", "D: By the station"]', 'A', 'The announcement states that the travel agency is in downtown.', 1),
(1, 4, 'What is the main topic of the travel podcast?', 'https://example.com/audio/listening/travel/podcast_topic_1.mp3', '["A: Budget travel", "B: Luxury vacations", "C: Adventure trips", "D: City tours"]', 'A', 'The podcast discusses tips for budget travel.', 1),
(1, 4, 'Why was the flight canceled?', 'https://example.com/audio/listening/travel/flight_cancel_1.mp3', '["A: Bad weather", "B: Technical issues", "C: Low demand", "D: Staff strike"]', 'A', 'The announcement mentions bad weather as the reason for the flight cancellation.', 1),
(1, 4, 'What does the man say about his recent trip?', 'https://example.com/audio/listening/travel/recent_trip_1.mp3', '["A: It was boring.", "B: It was amazing.", "C: It was too short.", "D: It was expensive."]', 'B', 'The man describes his recent trip as amazing and memorable.', 1),
(1, 4, 'What type of accommodation does the woman prefer?', 'https://example.com/audio/listening/travel/accommodation_1.mp3', '["A: Hotel", "B: Hostel", "C: Apartment", "D: Camping"]', 'C', 'The woman says she prefers renting an apartment for more space.', 1),
(1, 4, 'What does the speaker suggest for traveling abroad?', 'https://example.com/audio/listening/travel/travel_tip_1.mp3', '["A: Learn basic phrases", "B: Book early", "C: Avoid tourist areas", "D: Travel alone"]', 'A', 'The speaker suggests learning basic phrases in the local language.', 1),
(1, 4, 'What is the destination of the tour mentioned?', 'https://example.com/audio/listening/travel/tour_destination_1.mp3', '["A: Paris", "B: Tokyo", "C: New York", "D: Sydney"]', 'B', 'The tour guide mentions Tokyo as the destination.', 1),
(1, 4, 'What does the woman say about the travel guidebook?', 'https://example.com/audio/listening/travel/guidebook_1.mp3', '["A: It is outdated.", "B: It is helpful.", "C: It is expensive.", "D: It is hard to find."]', 'B', 'The woman says the guidebook is very helpful for planning.', 1),
(1, 4, 'What is the purpose of the travel announcement?', 'https://example.com/audio/listening/travel/announcement_1.mp3', '["A: Promote a tour", "B: Cancel a trip", "C: Change a schedule", "D: Offer a discount"]', 'D', 'The announcement offers a discount on travel packages.', 1),
(1, 4, 'What does the man say about the airport?', 'https://example.com/audio/listening/travel/airport_opinion_1.mp3', '["A: It is crowded.", "B: It is modern.", "C: It is small.", "D: It is far away."]', 'B', 'The man describes the airport as modern and well-equipped.', 1),
(1, 4, 'What activity is the speaker planning for the trip?', 'https://example.com/audio/listening/travel/trip_activity_1.mp3', '["A: Skiing", "B: Sightseeing", "C: Shopping", "D: Cooking"]', 'B', 'The speaker mentions visiting historical sites, which is sightseeing.', 1),
(1, 4, 'What is the name of the airline mentioned?', 'https://example.com/audio/listening/travel/airline_1.mp3', '["A: SkyHigh", "B: BlueWings", "C: StarFly", "D: CloudJet"]', 'A', 'The announcement mentions SkyHigh as the airline.', 1),
(1, 4, 'What does the woman say about traveling by bus?', 'https://example.com/audio/listening/travel/bus_travel_1.mp3', '["A: It is slow.", "B: It is comfortable.", "C: It is expensive.", "D: It is unreliable."]', 'B', 'The woman says traveling by bus is comfortable and scenic.', 1);


INSERT INTO questions_practice (skill_id, topic_id, question_text, audio_url, options, correct_answer, explanation, created_by) VALUES
(1, 5, 'What is the man talking about in the podcast?', 'https://example.com/audio/listening/technology/podcast_topic_1.mp3', '["A: New smartphones", "B: Artificial intelligence", "C: Virtual reality", "D: Cloud computing"]', 'B', 'The man discusses advancements in artificial intelligence.', 1),
(1, 5, 'What does the woman say about the new software?', 'https://example.com/audio/listening/technology/software_info_1.mp3', '["A: It is easy to use.", "B: It is outdated.", "C: It is expensive.", "D: It is unreliable."]', 'A', 'The woman says the new software is user-friendly.', 1),
(1, 5, 'Where is the technology conference being held?', 'https://example.com/audio/listening/technology/conference_location_1.mp3', '["A: Convention Center", "B: University Hall", "C: Hotel", "D: Tech Park"]', 'A', 'The announcement states the conference is at the Convention Center.', 1),
(1, 5, 'What device is the speaker reviewing?', 'https://example.com/audio/listening/technology/device_review_1.mp3', '["A: Laptop", "B: Tablet", "C: Smartwatch", "D: Camera"]', 'C', 'The speaker describes the features of a smartwatch.', 1),
(1, 5, 'Why was the product launch delayed?', 'https://example.com/audio/listening/technology/launch_delay_1.mp3', '["A: Production issues", "B: Marketing problems", "C: Technical glitches", "D: Lack of funding"]', 'C', 'The conversation mentions technical glitches as the reason for the delay.', 1),
(1, 5, 'What does the man say about his new phone?', 'https://example.com/audio/listening/technology/new_phone_1.mp3', '["A: It has a great camera.", "B: It is too heavy.", "C: It is slow.", "D: It is cheap."]', 'A', 'The man praises the camera quality of his new phone.', 1),
(1, 5, 'What is the focus of the technology seminar?', 'https://example.com/audio/listening/technology/seminar_focus_1.mp3', '["A: Cybersecurity", "B: Game development", "C: Web design", "D: Mobile apps"]', 'A', 'The seminar discusses cybersecurity and online safety.', 1),
(1, 5, 'What does the woman suggest for improving tech skills?', 'https://example.com/audio/listening/technology/tech_skills_1.mp3', '["A: Online courses", "B: Reading books", "C: Attending workshops", "D: Joining a club"]', 'A', 'The woman suggests taking online courses to improve tech skills.', 1),
(1, 5, 'Who is speaking at the tech event?', 'https://example.com/audio/listening/technology/event_speaker_1.mp3', '["A: A software engineer", "B: A tech CEO", "C: A student", "D: A professor"]', 'B', 'The speaker is introduced as a tech company CEO.', 1),
(1, 5, 'What is the purpose of the technology podcast?', 'https://example.com/audio/listening/technology/podcast_purpose_1.mp3', '["A: Review new gadgets", "B: Discuss tech trends", "C: Teach coding", "D: Promote products"]', 'B', 'The podcast focuses on discussing current tech trends.', 1),
(1, 5, 'What does the student say about the new app?', 'https://example.com/audio/listening/technology/new_app_1.mp3', '["A: It is confusing.", "B: It is helpful.", "C: It is slow.", "D: It is expensive."]', 'B', 'The student describes the app as helpful for studying.', 1),
(1, 5, 'What is the main topic of the tech interview?', 'https://example.com/audio/listening/technology/interview_topic_1.mp3', '["A: Robotics", "B: Blockchain", "C: Augmented reality", "D: Data analysis"]', 'A', 'The interview focuses on advancements in robotics.', 1),
(1, 5, 'What does the man say about the new laptop?', 'https://example.com/audio/listening/technology/laptop_review_1.mp3', '["A: It is too expensive.", "B: It is lightweight.", "C: It is slow.", "D: It is outdated."]', 'B', 'The man says the laptop is lightweight and portable.', 1),
(1, 5, 'What is the name of the tech company mentioned?', 'https://example.com/audio/listening/technology/company_name_1.mp3', '["A: TechTrend", "B: InnovateNow", "C: FutureTech", "D: SmartSolutions"]', 'C', 'The speaker mentions FutureTech as the company.', 1),
(1, 5, 'What does the woman say about smart home devices?', 'https://example.com/audio/listening/technology/smart_home_1.mp3', '["A: They are unreliable.", "B: They are convenient.", "C: They are expensive.", "D: They are hard to install."]', 'B', 'The woman says smart home devices are convenient for daily use.', 1);


INSERT INTO questions_practice (skill_id, topic_id, question_text, audio_url, options, correct_answer, explanation, created_by) VALUES
(1, 6, 'What is the main topic of the environmental podcast?', 'https://example.com/audio/listening/environment/podcast_topic_1.mp3', '["A: Climate change", "B: Wildlife conservation", "C: Recycling", "D: Air pollution"]', 'A', 'The podcast discusses the impacts of climate change.', 1),
(1, 6, 'What does the woman say about recycling?', 'https://example.com/audio/listening/environment/recycling_info_1.mp3', '["A: It is mandatory.", "B: It is ineffective.", "C: It is optional.", "D: It is expensive."]', 'A', 'The woman says recycling is mandatory in her city.', 1),
(1, 6, 'Where is the environmental conference being held?', 'https://example.com/audio/listening/environment/conference_location_1.mp3', '["A: City Hall", "B: University", "C: Community Center", "D: Park"]', 'B', 'The announcement states the conference is at the university.', 1),
(1, 6, 'What is the speaker discussing?', 'https://example.com/audio/listening/environment/environment_issue_1.mp3', '["A: Deforestation", "B: Ocean pollution", "C: Renewable energy", "D: Urbanization"]', 'C', 'The speaker talks about the benefits of renewable energy.', 1),
(1, 6, 'Why was the environmental campaign launched?', 'https://example.com/audio/listening/environment/campaign_purpose_1.mp3', '["A: Promote recycling", "B: Protect wildlife", "C: Reduce emissions", "D: Clean rivers"]', 'B', 'The campaign aims to protect endangered wildlife.', 1),
(1, 6, 'What does the man say about the new park?', 'https://example.com/audio/listening/environment/new_park_1.mp3', '["A: It is too small.", "B: It is eco-friendly.", "C: It is far away.", "D: It is closed."]', 'B', 'The man says the park was designed to be eco-friendly.', 1),
(1, 6, 'What is the focus of the environmental seminar?', 'https://example.com/audio/listening/environment/seminar_focus_1.mp3', '["A: Water conservation", "B: Air quality", "C: Soil erosion", "D: Green energy"]', 'A', 'The seminar discusses ways to conserve water.', 1),
(1, 6, 'What does the woman suggest for helping the environment?', 'https://example.com/audio/listening/environment/environment_suggestion_1.mp3', '["A: Reduce plastic use", "B: Drive less", "C: Plant trees", "D: All of the above"]', 'D', 'The woman suggests reducing plastic, driving less, and planting trees.', 1),
(1, 6, 'Who is speaking at the environmental event?', 'https://example.com/audio/listening/environment/event_speaker_1.mp3', '["A: A scientist", "B: A politician", "C: A student", "D: An activist"]', 'D', 'The speaker is introduced as an environmental activist.', 1),
(1, 6, 'What is the purpose of the environmental announcement?', 'https://example.com/audio/listening/environment/announcement_1.mp3', '["A: Promote a cleanup", "B: Cancel an event", "C: Discuss regulations", "D: Offer funding"]', 'A', 'The announcement promotes a community cleanup event.', 1),
(1, 6, 'What does the student say about the recycling program?', 'https://example.com/audio/listening/environment/recycling_program_1.mp3', '["A: It is ineffective.", "B: It is successful.", "C: It is new.", "D: It is expensive."]', 'B', 'The student says the recycling program has been successful.', 1),
(1, 6, 'What is the main topic of the environmental interview?', 'https://example.com/audio/listening/environment/interview_topic_1.mp3', '["A: Ocean cleanup", "B: Forest preservation", "C: Solar energy", "D: Waste management"]', 'A', 'The interview focuses on ocean cleanup initiatives.', 1),
(1, 6, 'What does the man say about climate change?', 'https://example.com/audio/listening/environment/climate_change_1.mp3', '["A: It is exaggerated.", "B: It is urgent.", "C: It is solved.", "D: It is irrelevant."]', 'B', 'The man says climate change is an urgent issue.', 1),
(1, 6, 'What is the name of the environmental organization mentioned?', 'https://example.com/audio/listening/environment/organization_1.mp3', '["A: Green Earth", "B: Blue Planet", "C: Clean World", "D: EcoFuture"]', 'A', 'The speaker mentions Green Earth as the organization.', 1),
(1, 6, 'What does the woman say about renewable energy?', 'https://example.com/audio/listening/environment/renewable_energy_1.mp3', '["A: It is unreliable.", "B: It is the future.", "C: It is expensive.", "D: It is limited."]', 'B', 'The woman says renewable energy is the future for sustainability.', 1);


INSERT INTO questions_practice (skill_id, topic_id, question_text, audio_url, options, correct_answer, explanation, created_by) VALUES
(1, 7, 'What is the main topic of the health podcast?', 'https://example.com/audio/listening/health/podcast_topic_1.mp3', '["A: Healthy eating", "B: Mental health", "C: Exercise routines", "D: Sleep habits"]', 'A', 'The podcast discusses tips for healthy eating.', 1),
(1, 7, 'What does the woman say about yoga?', 'https://example.com/audio/listening/health/yoga_info_1.mp3', '["A: It is difficult.", "B: It is relaxing.", "C: It is expensive.", "D: It is boring."]', 'B', 'The woman says yoga is relaxing and good for stress relief.', 1),
(1, 7, 'Where is the health workshop being held?', 'https://example.com/audio/listening/health/workshop_location_1.mp3', '["A: Community Center", "B: Hospital", "C: Gym", "D: Library"]', 'A', 'The announcement states the workshop is at the Community Center.', 1),
(1, 7, 'What is the speaker discussing?', 'https://example.com/audio/listening/health/health_issue_1.mp3', '["A: Stress management", "B: Weight loss", "C: Heart health", "D: Skin care"]', 'C', 'The speaker talks about ways to improve heart health.', 1),
(1, 7, 'Why was the fitness class canceled?', 'https://example.com/audio/listening/health/class_cancel_1.mp3', '["A: Instructor illness", "B: Low attendance", "C: Weather issues", "D: Facility maintenance"]', 'A', 'The announcement mentions the instructor’s illness as the reason.', 1),
(1, 7, 'What does the man say about his diet?', 'https://example.com/audio/listening/health/diet_info_1.mp3', '["A: It is unhealthy.", "B: It is balanced.", "C: It is expensive.", "D: It is boring."]', 'B', 'The man says his diet is balanced and includes vegetables.', 1),
(1, 7, 'What is the focus of the health seminar?', 'https://example.com/audio/listening/health/seminar_focus_1.mp3', '["A: Mental wellness", "B: Physical fitness", "C: Nutrition", "D: Sleep disorders"]', 'A', 'The seminar discusses mental wellness and stress reduction.', 1),
(1, 7, 'What does the woman suggest for staying healthy?', 'https://example.com/audio/listening/health/health_suggestion_1.mp3', '["A: Regular exercise", "B: Drinking water", "C: Getting enough sleep", "D: All of the above"]', 'D', 'The woman suggests exercise, hydration, and sleep for health.', 1),
(1, 7, 'Who is speaking at the health event?', 'https://example.com/audio/listening/health/event_speaker_1.mp3', '["A: A doctor", "B: A nutritionist", "C: A fitness coach", "D: A student"]', 'B', 'The speaker is introduced as a nutritionist.', 1),
(1, 7, 'What is the purpose of the health announcement?', 'https://example.com/audio/listening/health/announcement_1.mp3', '["A: Promote a campaign", "B: Cancel a class", "C: Offer free checkups", "D: Discuss regulations"]', 'C', 'The announcement offers free health checkups this week.', 1),
(1, 7, 'What does the student say about meditation?', 'https://example.com/audio/listening/health/meditation_1.mp3', '["A: It is difficult.", "B: It is relaxing.", "C: It is time-consuming.", "D: It is expensive."]', 'B', 'The student says meditation is relaxing and helps focus.', 1),
(1, 7, 'What is the main topic of the health interview?', 'https://example.com/audio/listening/health/interview_topic_1.mp3', '["A: Fitness trends", "B: Mental health", "C: Diet plans", "D: Medical research"]', 'B', 'The interview focuses on mental health awareness.', 1),
(1, 7, 'What does the man say about running?', 'https://example.com/audio/listening/health/running_1.mp3', '["A: It is boring.", "B: It is beneficial.", "C: It is dangerous.", "D: It is expensive."]', 'B', 'The man says running is beneficial for his health.', 1),
(1, 7, 'What is the name of the health program mentioned?', 'https://example.com/audio/listening/health/program_name_1.mp3', '["A: FitLife", "B: HealthyYou", "C: WellnessNow", "D: ActiveMind"]', 'C', 'The speaker mentions WellnessNow as the health program.', 1),
(1, 7, 'What does the woman say about sleep habits?', 'https://example.com/audio/listening/health/sleep_habits_1.mp3', '["A: They are unimportant.", "B: They are crucial.", "C: They are hard to change.", "D: They are expensive."]', 'B', 'The woman says good sleep habits are crucial for health.', 1);


INSERT INTO questions_practice (skill_id, topic_id, question_text, audio_url, options, correct_answer, explanation, created_by) VALUES
(1, 8, 'What is the man talking about in the conversation?', 'https://example.com/audio/listening/food/food_topic_1.mp3', '["A: Italian cuisine", "B: Japanese cuisine", "C: Mexican cuisine", "D: French cuisine"]', 'B', 'The man mentions sushi and ramen, which are Japanese dishes.', 1),
(1, 8, 'What does the woman say about the new restaurant?', 'https://example.com/audio/listening/food/restaurant_info_1.mp3', '["A: It is expensive.", "B: It is popular.", "C: It is closed.", "D: It is small."]', 'B', 'The woman says the new restaurant is very popular.', 1),
(1, 8, 'Where is the cooking class being held?', 'https://example.com/audio/listening/food/cooking_class_1.mp3', '["A: Community Center", "B: Restaurant", "C: School", "D: Library"]', 'A', 'The announcement states the cooking class is at the Community Center.', 1),
(1, 8, 'What dish is the speaker preparing?', 'https://example.com/audio/listening/food/dish_preparation_1.mp3', '["A: Pizza", "B: Sushi", "C: Tacos", "D: Pasta"]', 'D', 'The speaker describes boiling pasta for the dish.', 1),
(1, 8, 'Why was the food festival canceled?', 'https://example.com/audio/listening/food/festival_cancel_1.mp3', '["A: Bad weather", "B: Lack of funds", "C: Health concerns", "D: Low attendance"]', 'C', 'The announcement mentions health concerns as the reason for cancellation.', 1),
(1, 8, 'What does the man say about vegetarian food?', 'https://example.com/audio/listening/food/vegetarian_food_1.mp3', '["A: It is boring.", "B: It is healthy.", "C: It is expensive.", "D: It is difficult to cook."]', 'B', 'The man says vegetarian food is healthy and tasty.', 1),
(1, 8, 'What is the focus of the food podcast?', 'https://example.com/audio/listening/food/podcast_focus_1.mp3', '["A: Baking", "B: Street food", "C: Healthy recipes", "D: Food history"]', 'C', 'The podcast discusses healthy recipes for daily meals.', 1),
(1, 8, 'What does the woman suggest for cooking?', 'https://example.com/audio/listening/food/cooking_suggestion_1.mp3', '["A: Use fresh ingredients", "B: Buy pre-made meals", "C: Avoid spices", "D: Cook quickly"]', 'A', 'The woman suggests using fresh ingredients for better flavor.', 1),
(1, 8, 'Who is speaking at the food event?', 'https://example.com/audio/listening/food/event_speaker_1.mp3', '["A: A chef", "B: A food critic", "C: A student", "D: A nutritionist"]', 'A', 'The speaker is introduced as a professional chef.', 1),
(1, 8, 'What is the purpose of the food announcement?', 'https://example.com/audio/listening/food/announcement_1.mp3', '["A: Promote a restaurant", "B: Cancel a class", "C: Offer a discount", "D: Discuss safety"]', 'C', 'The announcement offers a discount on dining this week.', 1),
(1, 8, 'What does the student say about the cafeteria food?', 'https://example.com/audio/listening/food/cafeteria_food_1.mp3', '["A: It is unhealthy.", "B: It is delicious.", "C: It is expensive.", "D: It is limited."]', 'B', 'The student says the cafeteria food is delicious and varied.', 1),
(1, 8, 'What is the main topic of the food interview?', 'https://example.com/audio/listening/food/interview_topic_1.mp3', '["A: Food trends", "B: Cooking techniques", "C: Food safety", "D: Restaurant reviews"]', 'A', 'The interview focuses on current food trends.', 1),
(1, 8, 'What does the man say about baking?', 'https://example.com/audio/listening/food/baking_1.mp3', '["A: It is difficult.", "B: It is fun.", "C: It is expensive.", "D: It is unhealthy."]', 'B', 'The man says baking is fun and relaxing.', 1),
(1, 8, 'What is the name of the restaurant mentioned?', 'https://example.com/audio/listening/food/restaurant_name_1.mp3', '["A: TastyBites", "B: FoodHaven", "C: SpicyTreats", "D: FreshEats"]', 'A', 'The speaker mentions TastyBites as the restaurant.', 1),
(1, 8, 'What does the woman say about spicy food?', 'https://example.com/audio/listening/food/spicy_food_1.mp3', '["A: It is unhealthy.", "B: It is her favorite.", "C: It is too strong.", "D: It is hard to find."]', 'B', 'The woman says she loves spicy food.', 1);


INSERT INTO questions_practice (skill_id, topic_id, question_text, audio_url, options, correct_answer, explanation, created_by) VALUES
(2, 9, 'The article discusses a recent soccer match. What was the final score? \n\nThe match ended with a score of 3-2 in favor of the home team.', NULL, '["A: 2-3", "B: 3-2", "C: 1-2", "D: 3-1"]', 'B', 'The article states the match ended with a score of 3-2 in favor of the home team.', 1),
(2, 9, 'Why was the tennis tournament postponed? \n\nDue to heavy rain, the tournament was rescheduled to next week.', NULL, '["A: Player injuries", "B: Heavy rain", "C: Lack of tickets", "D: Technical issues"]', 'B', 'The text mentions heavy rain as the reason for postponing the tournament.', 1),
(2, 9, 'What is the main focus of the sports magazine? \n\nThis month’s issue highlights marathon running and training tips.', NULL, '["A: Soccer strategies", "B: Marathon running", "C: Basketball rules", "D: Tennis equipment"]', 'B', 'The magazine focuses on marathon running and training tips.', 1),
(2, 9, 'Who won the championship according to the article? \n\nThe Eagles won the national basketball championship.', NULL, '["A: Tigers", "B: Eagles", "C: Lions", "D: Bears"]', 'B', 'The article states that the Eagles won the championship.', 1),
(2, 9, 'What does the author say about swimming? \n\nSwimming is described as a low-impact exercise suitable for all ages.', NULL, '["A: It is high-impact.", "B: It is low-impact.", "C: It is dangerous.", "D: It is expensive."]', 'B', 'The author describes swimming as a low-impact exercise.', 1),
(2, 9, 'What is the purpose of the sports article? \n\nThe article aims to promote a new fitness program for athletes.', NULL, '["A: Promote a fitness program", "B: Review a match", "C: Discuss injuries", "D: Advertise equipment"]', 'A', 'The article’s purpose is to promote a new fitness program.', 1),
(2, 9, 'What sport is the new club focused on? \n\nThe club is dedicated to promoting volleyball among students.', NULL, '["A: Soccer", "B: Volleyball", "C: Basketball", "D: Tennis"]', 'B', 'The text mentions that the club focuses on volleyball.', 1),
(2, 9, 'What does the article suggest for improving athletic performance? \n\nA balanced diet is recommended to enhance performance.', NULL, '["A: More practice", "B: A balanced diet", "C: Better equipment", "D: Hiring a coach"]', 'B', 'The article recommends a balanced diet to improve performance.', 1),
(2, 9, 'Where is the new sports facility located? \n\nThe facility is located near the city center.', NULL, '["A: City center", "B: Suburbs", "C: Countryside", "D: Downtown"]', 'A', 'The text states the sports facility is near the city center.', 1),
(2, 9, 'What is the main topic of the sports column? \n\nThe column discusses the benefits of cycling for fitness.', NULL, '["A: Soccer", "B: Cycling", "C: Swimming", "D: Tennis"]', 'B', 'The column focuses on the benefits of cycling.', 1),
(2, 9, 'What does the article say about the new coach? \n\nThe new coach is experienced and has trained top athletes.', NULL, '["A: He is inexperienced.", "B: He is experienced.", "C: He is retiring.", "D: He is unpopular."]', 'B', 'The article describes the new coach as experienced.', 1),
(2, 9, 'What event is the sports club organizing? \n\nThe club is organizing a charity run next month.', NULL, '["A: Charity run", "B: Soccer match", "C: Tennis tournament", "D: Basketball game"]', 'A', 'The text mentions a charity run organized by the club.', 1),
(2, 9, 'What is the benefit of the new training program? \n\nThe program improves endurance and strength.', NULL, '["A: Flexibility", "B: Endurance and strength", "C: Speed only", "D: Teamwork"]', 'B', 'The article highlights endurance and strength as benefits.', 1),
(2, 9, 'What does the article say about the sports festival? \n\nThe festival will feature various sports and activities.', NULL, '["A: It is canceled.", "B: It features sports.", "C: It is expensive.", "D: It is exclusive."]', 'B', 'The article states the festival features various sports.', 1),
(2, 9, 'Who is the target audience of the sports article? \n\nThe article targets young athletes seeking training tips.', NULL, '["A: Young athletes", "B: Professional coaches", "C: Sports fans", "D: Older adults"]', 'A', 'The article is aimed at young athletes.', 1);


INSERT INTO questions_practice (skill_id, topic_id, question_text, audio_url, options, correct_answer, explanation, created_by) VALUES
(2, 10, 'What is the main topic of the school newsletter? \n\nThe newsletter discusses upcoming school events.', NULL, '["A: School events", "B: Exam schedules", "C: Teacher profiles", "D: Library hours"]', 'A', 'The newsletter focuses on upcoming school events.', 1),
(2, 10, 'Why was the school library closed? \n\nThe library is closed for renovations this month.', NULL, '["A: Renovations", "B: Staff shortage", "C: Holiday", "D: Budget cuts"]', 'A', 'The text states the library is closed for renovations.', 1),
(2, 10, 'What subject is the new course focused on? \n\nThe new course introduces students to computer science.', NULL, '["A: Literature", "B: Computer science", "C: History", "D: Mathematics"]', 'B', 'The text mentions a new course in computer science.', 1),
(2, 10, 'What does the article say about the school club? \n\nThe club meets every Wednesday after school.', NULL, '["A: It meets on Wednesdays.", "B: It meets on Fridays.", "C: It is canceled.", "D: It is for teachers."]', 'A', 'The article states the club meets every Wednesday.', 1),
(2, 10, 'What is the purpose of the school announcement? \n\nThe announcement promotes a fundraising event.', NULL, '["A: Cancel a class", "B: Promote fundraising", "C: Change schedules", "D: Announce a holiday"]', 'B', 'The announcement is about a fundraising event.', 1),
(2, 10, 'What does the school article suggest for students? \n\nStudents are encouraged to join extracurricular activities.', NULL, '["A: Study harder", "B: Join activities", "C: Attend classes", "D: Read more"]', 'B', 'The article encourages joining extracurricular activities.', 1),
(2, 10, 'Where is the school event being held? \n\nThe event will take place in the auditorium.', NULL, '["A: Cafeteria", "B: Auditorium", "C: Library", "D: Gymnasium"]', 'B', 'The text states the event is in the auditorium.', 1),
(2, 10, 'What is the topic of the school seminar? \n\nThe seminar focuses on career planning.', NULL, '["A: Study skills", "B: Career planning", "C: School rules", "D: Exam preparation"]', 'B', 'The seminar is about career planning.', 1),
(2, 10, 'What does the article say about the new teacher? \n\nThe new teacher is highly qualified and friendly.', NULL, '["A: She is strict.", "B: She is friendly.", "C: She is retiring.", "D: She is absent."]', 'B', 'The article describes the new teacher as friendly.', 1),
(2, 10, 'What is the benefit of the school’s new program? \n\nThe program improves students’ study habits.', NULL, '["A: Study habits", "B: Sports skills", "C: Social skills", "D: Leadership"]', 'A', 'The article highlights improved study habits as a benefit.', 1),
(2, 10, 'What event is the school organizing? \n\nThe school is hosting a science fair next week.', NULL, '["A: Talent show", "B: Science fair", "C: Sports day", "D: Book fair"]', 'B', 'The text mentions a science fair organized by the school.', 1),
(2, 10, 'What does the school article say about the cafeteria? \n\nThe cafeteria now offers healthier meal options.', NULL, '["A: It is closed.", "B: It offers healthier meals.", "C: It is expensive.", "D: It is small."]', 'B', 'The article states the cafeteria offers healthier meals.', 1),
(2, 10, 'What is the focus of the school workshop? \n\nThe workshop teaches time management skills.', NULL, '["A: Time management", "B: Public speaking", "C: Teamwork", "D: Creative writing"]', 'A', 'The workshop focuses on time management skills.', 1),
(2, 10, 'Who is the target audience of the school article? \n\nThe article targets parents of new students.', NULL, '["A: Teachers", "B: Parents", "C: Students", "D: Administrators"]', 'B', 'The article is aimed at parents of new students.', 1),
(2, 10, 'What does the article say about school uniforms? \n\nSchool uniforms are now mandatory for all students.', NULL, '["A: They are optional.", "B: They are mandatory.", "C: They are expensive.", "D: They are outdated."]', 'B', 'The article states that uniforms are mandatory.', 1);


INSERT INTO questions_practice (skill_id, topic_id, question_text, audio_url, options, correct_answer, explanation, created_by) VALUES
(2, 11, 'What is the main topic of the music article? \n\nThe article discusses the rise of pop music.', NULL, '["A: Classical music", "B: Pop music", "C: Jazz music", "D: Rock music"]', 'B', 'The article focuses on the rise of pop music.', 1),
(2, 11, 'Why was the concert canceled? \n\nThe concert was canceled due to the performer’s illness.', NULL, '["A: Low ticket sales", "B: Performer illness", "C: Weather issues", "D: Venue problems"]', 'B', 'The text states the concert was canceled due to the performer’s illness.', 1),
(2, 11, 'What instrument is the article about? \n\nThe article highlights the history of the guitar.', NULL, '["A: Piano", "B: Guitar", "C: Violin", "D: Drums"]', 'B', 'The article discusses the history of the guitar.', 1),
(2, 11, 'What does the article say about the music festival? \n\nThe festival will feature local bands.', NULL, '["A: It features local bands.", "B: It is canceled.", "C: It is expensive.", "D: It is abroad."]', 'A', 'The article states the festival features local bands.', 1),
(2, 11, 'What is the purpose of the music column? \n\nThe column promotes a new music school.', NULL, '["A: Review albums", "B: Promote a school", "C: Discuss history", "D: Advertise concerts"]', 'B', 'The column’s purpose is to promote a new music school.', 1),
(2, 11, 'What does the author suggest for enjoying music? \n\nThe author suggests attending live concerts.', NULL, '["A: Buying CDs", "B: Attending concerts", "C: Listening online", "D: Learning an instrument"]', 'B', 'The author recommends attending live concerts.', 1),
(2, 11, 'Where is the music event being held? \n\nThe event will take place in the city park.', NULL, '["A: Concert hall", "B: City park", "C: Stadium", "D: Theater"]', 'B', 'The text states the event is in the city park.', 1),
(2, 11, 'What is the focus of the music workshop? \n\nThe workshop teaches music production techniques.', NULL, '["A: Music theory", "B: Music production", "C: Singing", "D: Instrument repair"]', 'B', 'The workshop focuses on music production techniques.', 1),
(2, 11, 'What does the article say about the new album? \n\nThe new album is a mix of jazz and pop.', NULL, '["A: It is classical.", "B: It is jazz and pop.", "C: It is rock.", "D: It is folk."]', 'B', 'The article describes the album as a mix of jazz and pop.', 1),
(2, 11, 'What is the benefit of the music program? \n\nThe program improves students’ creativity.', NULL, '["A: Creativity", "B: Technical skills", "C: Teamwork", "D: Confidence"]', 'A', 'The article highlights creativity as a benefit of the program.', 1),
(2, 11, 'What event is the music school organizing? \n\nThe school is hosting a talent show.', NULL, '["A: Talent show", "B: Concert", "C: Workshop", "D: Competition"]', 'A', 'The text mentions a talent show organized by the school.', 1),
(2, 11, 'What does the article say about the band? \n\nThe band is known for its energetic performances.', NULL, '["A: It is new.", "B: It is energetic.", "C: It is unpopular.", "D: It is retiring."]', 'B', 'The article describes the band as energetic.', 1),
(2, 11, 'What is the focus of the music magazine? \n\nThe magazine covers new music trends.', NULL, '["A: Music trends", "B: Artist interviews", "C: Music history", "D: Concert reviews"]', 'A', 'The magazine focuses on new music trends.', 1),
(2, 11, 'Who is the target audience of the music article? \n\nThe article targets young music enthusiasts.', NULL, '["A: Music teachers", "B: Young enthusiasts", "C: Professional musicians", "D: Older adults"]', 'B', 'The article is aimed at young music enthusiasts.', 1),
(2, 11, 'What does the article say about music lessons? \n\nMusic lessons are now available online.', NULL, '["A: They are expensive.", "B: They are online.", "C: They are canceled.", "D: They are in-person only."]', 'B', 'The article states that music lessons are available online.', 1);


INSERT INTO questions_practice (skill_id, topic_id, question_text, audio_url, options, correct_answer, explanation, created_by) VALUES
(2, 12, 'What is the main topic of the travel article? \n\nThe article discusses budget travel tips.', NULL, '["A: Budget travel", "B: Luxury vacations", "C: Adventure trips", "D: City tours"]', 'A', 'The article focuses on budget travel tips.', 1),
(2, 12, 'Why was the flight delayed? \n\nThe flight was delayed due to technical issues.', NULL, '["A: Bad weather", "B: Technical issues", "C: Staff strike", "D: Low demand"]', 'B', 'The text states the flight was delayed due to technical issues.', 1),
(2, 12, 'What destination is the article about? \n\nThe article highlights tourist attractions in Paris.', NULL, '["A: Paris", "B: Tokyo", "C: New York", "D: Sydney"]', 'A', 'The article discusses tourist attractions in Paris.', 1),
(2, 12, 'What does the article say about the travel agency? \n\nThe agency offers affordable tour packages.', NULL, '["A: It is expensive.", "B: It is affordable.", "C: It is new.", "D: It is unreliable."]', 'B', 'The article states the agency offers affordable packages.', 1),
(2, 12, 'What is the purpose of the travel column? \n\nThe column promotes eco-friendly travel.', NULL, '["A: Promote eco-friendly travel", "B: Review hotels", "C: Discuss safety", "D: Advertise flights"]', 'A', 'The column’s purpose is to promote eco-friendly travel.', 1),
(2, 12, 'What does the author suggest for traveling? \n\nThe author suggests booking tickets early.', NULL, '["A: Book early", "B: Travel alone", "C: Avoid tourist areas", "D: Learn languages"]', 'A', 'The author recommends booking tickets early.', 1),
(2, 12, 'Where is the travel event being held? \n\nThe event will take place at the convention center.', NULL, '["A: Hotel", "B: Convention center", "C: Airport", "D: Park"]', 'B', 'The text states the event is at the convention center.', 1),
(2, 12, 'What is the focus of the travel workshop? \n\nThe workshop teaches travel photography skills.', NULL, '["A: Travel photography", "B: Budget planning", "C: Language learning", "D: Safety tips"]', 'A', 'The workshop focuses on travel photography skills.', 1),
(2, 12, 'What does the article say about the new tour? \n\nThe new tour includes historical sites.', NULL, '["A: It is expensive.", "B: It includes historical sites.", "C: It is canceled.", "D: It is short."]', 'B', 'The article describes the tour as including historical sites.', 1),
(2, 12, 'What is the benefit of the travel program? \n\nThe program offers discounts for group travel.', NULL, '["A: Solo travel", "B: Group discounts", "C: Luxury packages", "D: Adventure trips"]', 'B', 'The article highlights discounts for group travel.', 1),
(2, 12, 'What event is the travel agency organizing? \n\nThe agency is hosting a travel expo.', NULL, '["A: Travel expo", "B: Charity event", "C: Workshop", "D: Tour"]', 'A', 'The text mentions a travel expo organized by the agency.', 1),
(2, 12, 'What does the article say about the airport? \n\nThe airport has modern facilities.', NULL, '["A: It is outdated.", "B: It is modern.", "C: It is small.", "D: It is crowded."]', 'B', 'The article describes the airport as having modern facilities.', 1),
(2, 12, 'What is the focus of the travel magazine? \n\nThe magazine covers adventure travel.', NULL, '["A: Adventure travel", "B: Luxury travel", "C: Business travel", "D: Cultural travel"]', 'A', 'The magazine focuses on adventure travel.', 1),
(2, 12, 'Who is the target audience of the travel article? \n\nThe article targets budget travelers.', NULL, '["A: Budget travelers", "B: Luxury travelers", "C: Business travelers", "D: Families"]', 'A', 'The article is aimed at budget travelers.', 1),
(2, 12, 'What does the article say about travel apps? \n\nTravel apps help with itinerary planning.', NULL, '["A: They are unreliable.", "B: They help with planning.", "C: They are expensive.", "D: They are outdated."]', 'B', 'The article states that travel apps help with itinerary planning.', 1);


INSERT INTO questions_practice (skill_id, topic_id, question_text, audio_url, image_url, options, correct_answer, explanation, created_by, is_active) VALUES
(3, 17, 'What is the meaning of "stadium"?', NULL, NULL, '["A: A place where sports events are held", "B: A type of ball", "C: A sports team", "D: A sports rule"]', 'A', 'A stadium is a large structure where sports events and competitions take place.', 1, TRUE),
(3, 17, 'Which word means "a person who plays sports"?', NULL, NULL, '["A: Coach", "B: Athlete", "C: Referee", "D: Spectator"]', 'B', 'An athlete is a person who participates in sports activities.', 1, TRUE),
(3, 17, 'What does "tournament" refer to?', NULL, NULL, '["A: A single game", "B: A series of games to determine a winner", "C: A training session", "D: A sports injury"]', 'B', 'A tournament is a competition involving multiple games to find a champion.', 1, TRUE),
(3, 17, 'What is a "goal" in soccer?', NULL, NULL, '["A: A point scored", "B: A player position", "C: A type of ball", "D: A rule book"]', 'A', 'In soccer, a goal is scored when the ball crosses the opponent’s goal line.', 1, TRUE),
(3, 17, 'What does "scoreboard" mean?', NULL, NULL, '["A: A list of players", "B: A display of the score", "C: A game plan", "D: A sports uniform"]', 'B', 'A scoreboard shows the current score of a game.', 1, TRUE),
(3, 17, 'What is the meaning of "foul"?', NULL, NULL, '["A: A type of goal", "B: A rule violation", "C: A player’s position", "D: A cheering crowd"]', 'B', 'A foul is an illegal action that breaks the rules of the game.', 1, TRUE),
(3, 17, 'What does "teammate" mean?', NULL, NULL, '["A: An opponent", "B: A coach", "C: A person on the same team", "D: A referee"]', 'C', 'A teammate is a person who plays on the same team as you.', 1, TRUE),
(3, 17, 'What is a "coach"?', NULL, NULL, '["A: A player", "B: A person who trains the team", "C: A type of ball", "D: A game rule"]', 'B', 'A coach is responsible for training and guiding the team.', 1, TRUE),
(3, 17, 'What does "penalty" mean in sports?', NULL, NULL, '["A: A reward", "B: A punishment for breaking rules", "C: A goal", "D: A timeout"]', 'B', 'A penalty is a punishment given for violating game rules.', 1, TRUE),
(3, 17, 'What is the meaning of "referee"?', NULL, NULL, '["A: A player", "B: A person who enforces rules", "C: A fan", "D: A substitute"]', 'B', 'A referee enforces the rules during a sports game.', 1, TRUE),
(3, 17, 'What does "champion" mean?', NULL, NULL, '["A: A loser", "B: A winner of a competition", "C: A beginner", "D: A coach"]', 'B', 'A champion is the winner of a competition or tournament.', 1, TRUE),
(3, 17, 'What is a "trophy"?', NULL, NULL, '["A: A type of ball", "B: A prize for winning", "C: A sports field", "D: A rule book"]', 'B', 'A trophy is an award given to the winner of a competition.', 1, TRUE),
(3, 17, 'What does "defense" mean in sports?', NULL, NULL, '["A: Attacking the opponent", "B: Protecting your goal", "C: Scoring points", "D: Cheering"]', 'B', 'Defense refers to actions to prevent the opponent from scoring.', 1, TRUE),
(3, 17, 'What is a "match"?', NULL, NULL, '["A: A single game or contest", "B: A team", "C: A training session", "D: A rule"]', 'A', 'A match is a single game or contest between teams or players.', 1, TRUE),
(3, 17, 'What does "spectator" mean?', NULL, NULL, '["A: A player", "B: A person watching the game", "C: A coach", "D: A referee"]', 'B', 'A spectator is someone who watches a sports event.', 1, TRUE),
(3, 18, 'What does "classroom" mean?', NULL, NULL, '["A: A playground", "B: A room for lessons", "C: A library", "D: A cafeteria"]', 'B', 'A classroom is a room where students attend lessons.', 1, TRUE),
(3, 18, 'What is a "textbook"?', NULL, NULL, '["A: A notebook", "B: A book for studying", "C: A teacher’s guide", "D: A test paper"]', 'B', 'A textbook is a book used for studying a subject.', 1, TRUE),
(3, 18, 'What does "homework" mean?', NULL, NULL, '["A: Work done at school", "B: Assignments done at home", "C: A school event", "D: A teacher’s lesson"]', 'B', 'Homework is assignments given to students to complete at home.', 1, TRUE),
(3, 18, 'What is a "teacher"?', NULL, NULL, '["A: A student", "B: A person who teaches", "C: A principal", "D: A parent"]', 'B', 'A teacher is a person who instructs students.', 1, TRUE),
(3, 18, 'What does "exam" mean?', NULL, NULL, '["A: A class project", "B: A test of knowledge", "C: A school trip", "D: A homework task"]', 'B', 'An exam is a test to evaluate a student’s knowledge.', 1, TRUE),
(3, 18, 'What is a "schedule"?', NULL, NULL, '["A: A list of books", "B: A timetable for classes", "C: A test score", "D: A school rule"]', 'B', 'A schedule is a plan showing the times of classes or events.', 1, TRUE),
(3, 18, 'What does "principal" mean?', NULL, NULL, '["A: A teacher", "B: The head of a school", "C: A student", "D: A librarian"]', 'B', 'The principal is the person in charge of a school.', 1, TRUE),
(3, 18, 'What is a "notebook"?', NULL, NULL, '["A: A book for reading", "B: A book for writing notes", "C: A teacher’s guide", "D: A test"]', 'B', 'A notebook is used by students to write notes.', 1, TRUE),
(3, 18, 'What does "lesson" mean?', NULL, NULL, '["A: A school event", "B: A teaching session", "C: A homework task", "D: A playground"]', 'B', 'A lesson is a period of teaching on a specific topic.', 1, TRUE),
(3, 18, 'What is a "grade"?', NULL, NULL, '["A: A type of book", "B: A score or mark", "C: A school rule", "D: A teacher"]', 'B', 'A grade is a score or mark given for academic performance.', 1, TRUE),
(3, 18, 'What does "library" mean?', NULL, NULL, '["A: A classroom", "B: A place for books", "C: A cafeteria", "D: A playground"]', 'B', 'A library is a place where books are stored and borrowed.', 1, TRUE),
(3, 18, 'What is a "student"?', NULL, NULL, '["A: A teacher", "B: A person who learns", "C: A principal", "D: A librarian"]', 'B', 'A student is a person who is learning at a school.', 1, TRUE),
(3, 18, 'What does "assignment" mean?', NULL, NULL, '["A: A school event", "B: A task given to students", "C: A classroom", "D: A teacher"]', 'B', 'An assignment is a task given to students to complete.', 1, TRUE),
(3, 18, 'What is a "desk"?', NULL, NULL, '["A: A book", "B: A table for studying", "C: A school rule", "D: A test"]', 'B', 'A desk is a table used by students for studying or writing.', 1, TRUE),
(3, 18, 'What does "attendance" mean?', NULL, NULL, '["A: A test score", "B: Presence in class", "C: A homework task", "D: A school event"]', 'B', 'Attendance refers to being present in class.', 1, TRUE),
(3, 19, 'What is a "guitar"?', NULL, NULL, '["A: A stringed musical instrument", "B: A type of drum", "C: A singer", "D: A song"]', 'A', 'A guitar is a musical instrument with strings.', 1, TRUE),
(3, 19, 'What does "melody" mean?', NULL, NULL, '["A: A rhythm", "B: A sequence of musical notes", "C: A band", "D: A concert"]', 'B', 'A melody is a sequence of musical notes that form a tune.', 1, TRUE),
(3, 19, 'What is a "band"?', NULL, NULL, '["A: A single musician", "B: A group of musicians", "C: A song", "D: A music genre"]', 'B', 'A band is a group of musicians who perform together.', 1, TRUE),
(3, 19, 'What does "concert" mean?', NULL, NULL, '["A: A music class", "B: A live music performance", "C: A music album", "D: A music studio"]', 'B', 'A concert is a live performance of music.', 1, TRUE),
(3, 19, 'What is a "singer"?', NULL, NULL, '["A: A person who plays an instrument", "B: A person who sings", "C: A music teacher", "D: A song writer"]', 'B', 'A singer is a person who performs songs vocally.', 1, TRUE),
(3, 19, 'What does "album" mean?', NULL, NULL, '["A: A single song", "B: A collection of songs", "C: A music video", "D: A concert"]', 'B', 'An album is a collection of songs released together.', 1, TRUE),
(3, 19, 'What is a "rhythm"?', NULL, NULL, '["A: A melody", "B: The beat or tempo of music", "C: A singer", "D: A music genre"]', 'B', 'Rhythm is the pattern of beats or tempo in music.', 1, TRUE),
(3, 19, 'What does "genre" mean?', NULL, NULL, '["A: A musical instrument", "B: A type or style of music", "C: A singer", "D: A concert"]', 'B', 'A genre is a category or style of music, like jazz or pop.', 1, TRUE),
(3, 19, 'What is a "piano"?', NULL, NULL, '["A: A stringed instrument", "B: A keyboard instrument", "C: A drum", "D: A song"]', 'B', 'A piano is a musical instrument with a keyboard.', 1, TRUE),
(3, 19, 'What does "lyrics" mean?', NULL, NULL, '["A: The music notes", "B: The words of a song", "C: The rhythm", "D: The band"]', 'B', 'Lyrics are the words or text of a song.', 1, TRUE),
(3, 19, 'What is a "drummer"?', NULL, NULL, '["A: A singer", "B: A person who plays drums", "C: A music teacher", "D: A song writer"]', 'B', 'A drummer is a person who plays the drums.', 1, TRUE),
(3, 19, 'What does "orchestra" mean?', NULL, NULL, '["A: A small band", "B: A large group of musicians", "C: A single instrument", "D: A song"]', 'B', 'An orchestra is a large group of musicians playing various instruments.', 1, TRUE),
(3, 19, 'What is a "song"?', NULL, NULL, '["A: A musical instrument", "B: A piece of music with lyrics", "C: A concert", "D: A band"]', 'B', 'A song is a piece of music typically with lyrics.', 1, TRUE),
(3, 19, 'What does "composer" mean?', NULL, NULL, '["A: A singer", "B: A person who writes music", "C: A music listener", "D: A band"]', 'B', 'A composer is a person who creates or writes music.', 1, TRUE),
(3, 19, 'What is a "violin"?', NULL, NULL, '["A: A keyboard instrument", "B: A stringed instrument", "C: A drum", "D: A song"]', 'B', 'A violin is a stringed musical instrument played with a bow.', 1, TRUE),
(3, 20, 'What does "passport" mean?', NULL, NULL, '["A: A travel guide", "B: A document for international travel", "C: A map", "D: A ticket"]', 'B', 'A passport is an official document for international travel.', 1, TRUE),
(3, 20, 'What is a "suitcase"?', NULL, NULL, '["A: A type of ticket", "B: A bag for carrying clothes", "C: A travel agency", "D: A map"]', 'B', 'A suitcase is a bag used to carry clothes and items while traveling.', 1, TRUE),
(3, 20, 'What does "destination" mean?', NULL, NULL, '["A: A travel plan", "B: The place you are traveling to", "C: A ticket", "D: A tour guide"]', 'B', 'A destination is the place you plan to travel to.', 1, TRUE),
(3, 20, 'What is a "ticket"?', NULL, NULL, '["A: A travel guide", "B: A document for boarding transport", "C: A map", "D: A hotel"]', 'B', 'A ticket is a document allowing you to board a plane, train, etc.', 1, TRUE),
(3, 20, 'What does "itinerary" mean?', NULL, NULL, '["A: A travel plan or schedule", "B: A suitcase", "C: A ticket", "D: A map"]', 'A', 'An itinerary is a planned route or schedule for a trip.', 1, TRUE),
(3, 20, 'What is a "hotel"?', NULL, NULL, '["A: A place to stay during travel", "B: A type of ticket", "C: A travel agency", "D: A map"]', 'A', 'A hotel is a place where travelers stay overnight.', 1, TRUE),
(3, 20, 'What does "luggage" mean?', NULL, NULL, '["A: A travel guide", "B: Bags and items carried on a trip", "C: A ticket", "D: A destination"]', 'B', 'Luggage refers to bags and items a traveler carries.', 1, TRUE),
(3, 20, 'What is a "tourist"?', NULL, NULL, '["A: A travel agent", "B: A person visiting a place for pleasure", "C: A map", "D: A ticket"]', 'B', 'A tourist is a person who travels for enjoyment.', 1, TRUE),
(3, 20, 'What does "visa" mean?', NULL, NULL, '["A: A travel plan", "B: A permit to enter a country", "C: A suitcase", "D: A map"]', 'B', 'A visa is an official permit to enter or stay in a country.', 1, TRUE),
(3, 20, 'What is a "map"?', NULL, NULL, '["A: A ticket", "B: A guide showing locations", "C: A suitcase", "D: A hotel"]', 'B', 'A map is a visual guide showing locations and routes.', 1, TRUE),
(3, 20, 'What does "flight" mean?', NULL, NULL, '["A: A train ride", "B: A journey by airplane", "C: A hotel stay", "D: A travel plan"]', 'B', 'A flight is a journey made by airplane.', 1, TRUE),
(3, 20, 'What is a "guidebook"?', NULL, NULL, '["A: A map", "B: A book with travel information", "C: A ticket", "D: A suitcase"]', 'B', 'A guidebook provides information about a travel destination.', 1, TRUE),
(3, 20, 'What does "boarding pass" mean?', NULL, NULL, '["A: A travel plan", "B: A document to board a plane", "C: A hotel key", "D: A map"]', 'B', 'A boarding pass is a document allowing you to board a plane.', 1, TRUE),
(3, 20, 'What is a "reservation"?', NULL, NULL, '["A: A map", "B: A booking for a hotel or flight", "C: A suitcase", "D: A tourist"]', 'B', 'A reservation is a booking made in advance for travel or accommodation.', 1, TRUE),
(3, 20, 'What does "souvenir" mean?', NULL, NULL, '["A: A ticket", "B: A keepsake from a trip", "C: A travel plan", "D: A map"]', 'B', 'A souvenir is an item kept as a reminder of a trip.', 1, TRUE);


INSERT INTO questions_practice (skill_id, topic_id, question_text, audio_url, image_url, options, correct_answer, explanation, created_by, is_active) VALUES
(4, 25, 'Choose the correct form: She ___ to the store every day.', NULL, NULL, '["A: go", "B: goes", "C: going", "D: gone"]', 'B', 'The present simple tense is used for habits, and "she" takes the verb with -s.', 1, TRUE),
(4, 25, 'What is the correct tense: They ___ football yesterday.', NULL, NULL, '["A: play", "B: played", "C: playing", "D: will play"]', 'B', 'The past simple tense is used for completed actions in the past.', 1, TRUE),
(4, 25, 'Complete the sentence: I ___ my homework now.', NULL, NULL, '["A: am doing", "B: do", "C: did", "D: will do"]', 'A', 'The present continuous tense is used for actions happening now.', 1, TRUE),
(4, 25, 'Which is correct: By next year, she ___ here for 5 years.', NULL, NULL, '["A: will live", "B: will have lived", "C: lives", "D: living"]', 'B', 'The future perfect tense is used for actions completed before a future time.', 1, TRUE),
(4, 25, 'Choose the correct form: He ___ to Paris last summer.', NULL, NULL, '["A: go", "B: goes", "C: went", "D: gone"]', 'C', 'The past simple tense "went" is used for a completed action.', 1, TRUE),
(4, 25, 'What is correct: They ___ TV when I arrived.', NULL, NULL, '["A: watch", "B: watched", "C: were watching", "D: will watch"]', 'C', 'The past continuous tense is used for ongoing actions in the past.', 1, TRUE),
(4, 25, 'Complete the sentence: She ___ a doctor in two years.', NULL, NULL, '["A: becomes", "B: will become", "C: became", "D: becoming"]', 'B', 'The future simple tense is used for predictions or future actions.', 1, TRUE),
(4, 25, 'Choose the correct tense: I ___ this book since last week.', NULL, NULL, '["A: read", "B: am reading", "C: have read", "D: have been reading"]', 'D', 'The present perfect continuous tense is used for actions started in the past and continuing.', 1, TRUE),
(4, 25, 'What is correct: He ___ to school every day last year.', NULL, NULL, '["A: walks", "B: walked", "C: walking", "D: will walk"]', 'B', 'The past simple tense is used for habits in the past.', 1, TRUE),
(4, 25, 'Complete the sentence: By the time we arrived, they ___ dinner.', NULL, NULL, '["A: finish", "B: finished", "C: had finished", "D: will finish"]', 'C', 'The past perfect tense is used for actions completed before another past action.', 1, TRUE),
(4, 25, 'Choose the correct form: She ___ her homework yet.', NULL, NULL, '["A: hasn’t done", "B: doesn’t do", "C: didn’t do", "D: won’t do"]', 'A', 'The present perfect tense is used for actions not yet completed.', 1, TRUE),
(4, 25, 'What is correct: I ___ to the gym tomorrow.', NULL, NULL, '["A: go", "B: went", "C: will go", "D: going"]', 'C', 'The future simple tense is used for planned actions.', 1, TRUE),
(4, 25, 'Complete the sentence: They ___ in London since 2010.', NULL, NULL, '["A: live", "B: lived", "C: have lived", "D: are living"]', 'C', 'The present perfect tense is used for actions starting in the past and continuing.', 1, TRUE),
(4, 25, 'Choose the correct tense: He ___ when the phone rang.', NULL, NULL, '["A: sleeps", "B: slept", "C: was sleeping", "D: will sleep"]', 'C', 'The past continuous tense is used for interrupted actions.', 1, TRUE),
(4, 25, 'What is correct: She ___ to Paris next month.', NULL, NULL, '["A: travels", "B: traveled", "C: will travel", "D: traveling"]', 'C', 'The future simple tense is used for future plans.', 1, TRUE),
(4, 26, 'Choose the correct form: If I ___ rich, I would travel the world.', NULL, NULL, '["A: am", "B: was", "C: were", "D: will be"]', 'C', 'The second conditional uses "were" for hypothetical situations.', 1, TRUE),
(4, 26, 'Complete the sentence: If it ___ tomorrow, we will stay home.', NULL, NULL, '["A: rains", "B: rain", "C: rained", "D: will rain"]', 'A', 'The first conditional uses present simple for possible future conditions.', 1, TRUE),
(4, 26, 'What is correct: If she ___ harder, she would have passed.', NULL, NULL, '["A: studies", "B: studied", "C: had studied", "D: will study"]', 'C', 'The third conditional uses past perfect for unreal past situations.', 1, TRUE),
(4, 26, 'Choose the correct form: If I ___ you, I would apologize.', NULL, NULL, '["A: am", "B: was", "C: were", "D: will be"]', 'C', 'The second conditional uses "were" for advice or hypothetical situations.', 1, TRUE),
(4, 26, 'Complete the sentence: If he ___ on time, we won’t wait.', NULL, NULL, '["A: doesn’t arrive", "B: didn’t arrive", "C: won’t arrive", "D: arrives"]', 'A', 'The first conditional uses present simple for future conditions.', 1, TRUE),
(4, 26, 'What is correct: If I ___ earlier, I could have helped.', NULL, NULL, '["A: know", "B: knew", "C: had known", "D: will know"]', 'C', 'The third conditional uses past perfect for unreal past situations.', 1, TRUE),
(4, 26, 'Choose the correct form: If you ___ now, you’ll miss the bus.', NULL, NULL, '["A: don’t leave", "B: didn’t leave", "C: won’t leave", "D: leave"]', 'A', 'The first conditional uses present simple for warnings.', 1, TRUE),
(4, 26, 'Complete the sentence: If she ___ more, she would be fluent.', NULL, NULL, '["A: practices", "B: practiced", "C: had practiced", "D: will practice"]', 'B', 'The second conditional uses past simple for hypothetical situations.', 1, TRUE),
(4, 26, 'What is correct: If they ___ the rules, they wouldn’t have lost.', NULL, NULL, '["A: follow", "B: followed", "C: had followed", "D: will follow"]', 'C', 'The third conditional uses past perfect for unreal past outcomes.', 1, TRUE),
(4, 26, 'Choose the correct form: If I ___ time, I’ll help you.', NULL, NULL, '["A: have", "B: had", "C: will have", "D: having"]', 'A', 'The first conditional uses present simple for possible conditions.', 1, TRUE),
(4, 26, 'Complete the sentence: If he ___ taller, he could play basketball.', NULL, NULL, '["A: is", "B: was", "C: were", "D: will be"]', 'C', 'The second conditional uses "were" for hypothetical situations.', 1, TRUE),
(4, 26, 'What is correct: If we ___ earlier, we wouldn’t have missed the train.', NULL, NULL, '["A: leave", "B: left", "C: had left", "D: will leave"]', 'C', 'The third conditional uses past perfect for unreal past situations.', 1, TRUE),
(4, 26, 'Choose the correct form: If you ___ me, I’ll come.', NULL, NULL, '["A: call", "B: called", "C: had called", "D: will call"]', 'A', 'The first conditional uses present simple for future possibilities.', 1, TRUE),
(4, 26, 'Complete the sentence: If I ___ rich, I would have bought a car.', NULL, NULL, '["A: am", "B: was", "C: had been", "D: will be"]', 'C', 'The third conditional uses past perfect for unreal past situations.', 1, TRUE),
(4, 26, 'What is correct: If she ___ tired, she can rest.', NULL, NULL, '["A: is", "B: was", "C: were", "D: will be"]', 'A', 'The first conditional uses present simple for possible conditions.', 1, TRUE),
(4, 27, 'What part of speech is "quickly"?', NULL, NULL, '["A: Noun", "B: Verb", "C: Adjective", "D: Adverb"]', 'D', '"Quickly" describes how an action is done, making it an adverb.', 1, TRUE),
(4, 27, 'Identify the part of speech: "book" in "I read a book."', NULL, NULL, '["A: Verb", "B: Noun", "C: Adjective", "D: Adverb"]', 'B', '"Book" is a thing, so it is a noun.', 1, TRUE),
(4, 27, 'What is "beautiful" in "She is beautiful"?', NULL, NULL, '["A: Noun", "B: Verb", "C: Adjective", "D: Adverb"]', 'C', '"Beautiful" describes the subject, so it is an adjective.', 1, TRUE),
(4, 27, 'Choose the part of speech: "run" in "They run fast."', NULL, NULL, '["A: Noun", "B: Verb", "C: Adjective", "D: Adverb"]', 'B', '"Run" is an action, so it is a verb.', 1, TRUE),
(4, 27, 'What is "carefully" in "She drives carefully"?', NULL, NULL, '["A: Noun", "B: Verb", "C: Adjective", "D: Adverb"]', 'D', '"Carefully" describes how the action is performed, so it is an adverb.', 1, TRUE),
(4, 27, 'Identify the part of speech: "dog" in "The dog barks."', NULL, NULL, '["A: Verb", "B: Noun", "C: Adjective", "D: Adverb"]', 'B', '"Dog" is a thing, so it is a noun.', 1, TRUE),
(4, 27, 'What is "happy" in "He is happy"?', NULL, NULL, '["A: Noun", "B: Verb", "C: Adjective", "D: Adverb"]', 'C', '"Happy" describes the subject, so it is an adjective.', 1, TRUE),
(4, 27, 'Choose the part of speech: "and" in "Tom and Jerry."', NULL, NULL, '["A: Noun", "B: Verb", "C: Conjunction", "D: Adverb"]', 'C', '"And" connects two words, so it is a conjunction.', 1, TRUE),
(4, 27, 'What is "in" in "She lives in Paris"?', NULL, NULL, '["A: Noun", "B: Verb", "C: Preposition", "D: Adverb"]', 'C', '"In" shows location, so it is a preposition.', 1, TRUE),
(4, 27, 'Identify the part of speech: "swim" in "They swim daily."', NULL, NULL, '["A: Noun", "B: Verb", "C: Adjective", "D: Adverb"]', 'B', '"Swim" is an action, so it is a verb.', 1, TRUE),
(4, 27, 'What is "big" in "A big house"?', NULL, NULL, '["A: Noun", "B: Verb", "C: Adjective", "D: Adverb"]', 'C', '"Big" describes the noun, so it is an adjective.', 1, TRUE),
(4, 27, 'Choose the part of speech: "slowly" in "He walks slowly."', NULL, NULL, '["A: Noun", "B: Verb", "C: Adjective", "D: Adverb"]', 'D', '"Slowly" describes how the action is done, so it is an adverb.', 1, TRUE),
(4, 27, 'What is "or" in "Tea or coffee?"', NULL, NULL, '["A: Noun", "B: Verb", "C: Conjunction", "D: Adverb"]', 'C', '"Or" connects two options, so it is a conjunction.', 1, TRUE),
(4, 27, 'Identify the part of speech: "table" in "The table is wooden."', NULL, NULL, '["A: Noun", "B: Verb", "C: Adjective", "D: Adverb"]', 'B', '"Table" is a thing, so it is a noun.', 1, TRUE),
(4, 27, 'What is "on" in "The book is on the table"?', NULL, NULL, '["A: Noun", "B: Verb", "C: Preposition", "D: Adverb"]', 'C', '"On" shows location, so it is a preposition.', 1, TRUE),
(4, 28, 'Choose the correct passive form: The room ___ every day.', NULL, NULL, '["A: cleans", "B: is cleaned", "C: cleaning", "D: cleaned"]', 'B', 'The passive voice uses "is + past participle" for present actions.', 1, TRUE),
(4, 28, 'What is the passive form: They built the house last year.', NULL, NULL, '["A: The house was built.", "B: The house built.", "C: The house is built.", "D: The house builds."]', 'A', 'The past simple passive uses "was + past participle".', 1, TRUE),
(4, 28, 'Complete the passive sentence: The cake ___ by Mary.', NULL, NULL, '["A: bakes", "B: is baked", "C: baked", "D: was baked"]', 'D', 'The past simple passive uses "was + past participle".', 1, TRUE),
(4, 28, 'Choose the correct form: The car ___ tomorrow.', NULL, NULL, '["A: will repair", "B: will be repaired", "C: repairs", "D: repaired"]', 'B', 'The future passive uses "will be + past participle".', 1, TRUE),
(4, 28, 'What is the passive form: They are painting the house.', NULL, NULL, '["A: The house paints.", "B: The house is painted.", "C: The house is being painted.", "D: The house was painted."]', 'C', 'The present continuous passive uses "is being + past participle".', 1, TRUE),
(4, 28, 'Complete the sentence: The book ___ by the author last year.', NULL, NULL, '["A: wrote", "B: was written", "C: is written", "D: writes"]', 'B', 'The past simple passive uses "was + past participle".', 1, TRUE),
(4, 28, 'Choose the correct form: The letter ___ tomorrow.', NULL, NULL, '["A: sends", "B: will send", "C: will be sent", "D: sent"]', 'C', 'The future passive uses "will be + past participle".', 1, TRUE),
(4, 28, 'What is the passive form: They have finished the project.', NULL, NULL, '["A: The project finished.", "B: The project has been finished.", "C: The project is finished.", "D: The project was finished."]', 'B', 'The present perfect passive uses "has been + past participle".', 1, TRUE),
(4, 28, 'Complete the sentence: The room ___ by the team now.', NULL, NULL, '["A: cleans", "B: is cleaned", "C: is being cleaned", "D: was cleaned"]', 'C', 'The present continuous passive uses "is being + past participle".', 1, TRUE),
(4, 28, 'Choose the correct form: The song ___ by the band last week.', NULL, NULL, '["A: sang", "B: was sung", "C: is sung", "D: sings"]', 'B', 'The past simple passive uses "was + past participle".', 1, TRUE),
(4, 28, 'What is the passive form: They will deliver the package.', NULL, NULL, '["A: The package delivers.", "B: The package will be delivered.", "C: The package is delivered.", "D: The package was delivered."]', 'B', 'The future passive uses "will be + past participle".', 1, TRUE),
(4, 28, 'Complete the sentence: The movie ___ by millions.', NULL, NULL, '["A: watches", "B: is watched", "C: watched", "D: watching"]', 'B', 'The present simple passive uses "is + past participle".', 1, TRUE),
(4, 28, 'Choose the correct form: The house ___ two years ago.', NULL, NULL, '["A: builds", "B: was built", "C: is built", "D: built"]', 'B', 'The past simple passive uses "was + past participle".', 1, TRUE),
(4, 28, 'What is the passive form: They are repairing the car.', NULL, NULL, '["A: The car repairs.", "B: The car is repaired.", "C: The car is being repaired.", "D: The car was repaired."]', 'C', 'The present continuous passive uses "is being + past participle".', 1, TRUE),
(4, 28, 'Complete the sentence: The book ___ by students every year.', NULL, NULL, '["A: reads", "B: is read", "C: read", "D: reading"]', 'B', 'The present simple passive uses "is + past participle".', 1, TRUE);


-- ====================================================
-- DỮ LIỆU MẪU CHO BỘ ĐỀ THI
-- ====================================================

INSERT INTO test_sets (name, type, total_questions, time_limit, description, created_by, is_active) VALUES
('Mini Test 1 - Grade 12 English', 'mini_test', 20, 30, 'Bộ đề kiểm tra tiếng Anh cấp 3, gồm ngữ âm, từ vựng, ngữ pháp, đọc hiểu và nghe.', 1, TRUE),
('Mini Test 2 - Grade 12 English', 'mini_test', 20, 30, 'Bộ đề kiểm tra tiếng Anh cấp 3, tập trung vào kỹ năng cơ bản và nghe.', 1, TRUE),
('Mini Test 3 - Grade 12 English', 'mini_test', 20, 30, 'Bộ đề kiểm tra tiếng Anh cấp 3, luyện tập toàn diện các kỹ năng.', 1, TRUE),
('Full Test 1 - Grade 12 English', 'full_test', 50, 60, 'Bộ đề thi thử tiếng Anh cấp 3, bao gồm ngữ âm, từ vựng, ngữ pháp, đọc hiểu và nghe.', 1, TRUE);

-- ====================================================
-- CÂU HỎI CHO MINI TEST
-- ====================================================

INSERT INTO questions_test (test_set_id, part_number, question_number, question_text, audio_url, image_url, passage_text, options, correct_answer, explanation, created_by, is_active) VALUES
-- Part 1: Ngữ âm (3 câu)
(1, 1, 1, 'Choose the word with a different stress pattern.', NULL, NULL, NULL, '["A: happy", "B: teacher", "C: student", "D: begin"]', 'C', 'Student stresses the first syllable, others stress the second.', 1, TRUE),
(1, 1, 2, 'Choose the word with a different pronunciation of "ed".', NULL, NULL, NULL, '["A: watched", "B: played", "C: wanted", "D: looked"]', 'C', 'Wanted is pronounced /ɪd/, others are /t/ or /d/.', 1, TRUE),
(1, 1, 3, 'Choose the word with a different vowel sound.', NULL, NULL, NULL, '["A: cat", "B: hat", "C: pen", "D: mat"]', 'C', 'Pen has /ɛ/, others have /æ/.', 1, TRUE),

-- Part 2: Từ vựng & Ngữ pháp (7 câu)
(1, 2, 4, 'Choose the correct word: She ___ to school every day.', NULL, NULL, NULL, '["A: go", "B: goes", "C: going", "D: gone"]', 'B', 'Present simple with "she" uses verb + s.', 1, TRUE),
(1, 2, 5, 'Choose the correct preposition: I’m interested ___ learning English.', NULL, NULL, NULL, '["A: in", "B: at", "C: on", "D: with"]', 'A', 'Interested is followed by the preposition "in".', 1, TRUE),
(1, 2, 6, 'Choose the correct form: If I ___ you, I would study harder.', NULL, NULL, NULL, '["A: am", "B: was", "C: were", "D: will be"]', 'C', 'Second conditional uses "were" for hypothetical situations.', 1, TRUE),
(1, 2, 7, 'Choose the correct word: He is ___ than his brother.', NULL, NULL, NULL, '["A: tall", "B: taller", "C: tallest", "D: most tall"]', 'B', 'Comparative form is used with "than".', 1, TRUE),
(1, 2, 8, 'Choose the correct tense: They ___ TV when I called.', NULL, NULL, NULL, '["A: watch", "B: watched", "C: were watching", "D: will watch"]', 'C', 'Past continuous is used for ongoing past actions.', 1, TRUE),
(1, 2, 9, 'Choose the correct word: This is the ___ movie I’ve ever seen.', NULL, NULL, NULL, '["A: good", "B: better", "C: best", "D: most good"]', 'C', 'Superlative form is used for the highest degree.', 1, TRUE),
(1, 2, 10, 'Choose the correct form: The room ___ every day.', NULL, NULL, NULL, '["A: cleans", "B: is cleaned", "C: cleaning", "D: cleaned"]', 'B', 'Passive voice uses "is + past participle".', 1, TRUE),

-- Part 3: Đọc hiểu (5 câu)
(1, 3, 11, 'What is the main topic of the passage?', NULL, NULL, 'Lan enjoys reading books. She often visits the library to borrow novels and magazines. Her favorite books are about adventure and history.', '["A: Lan’s hobbies", "B: Lan’s school", "C: Lan’s family", "D: Lan’s friends"]', 'A', 'The passage discusses Lan’s reading habits.', 1, TRUE),
(1, 3, 12, 'Where does Lan usually go to borrow books?', NULL, NULL, 'Lan enjoys reading books. She often visits the library to borrow novels and magazines. Her favorite books are about adventure and history.', '["A: Bookstore", "B: Library", "C: School", "D: Friend’s house"]', 'B', 'The passage states she visits the library.', 1, TRUE),
(1, 3, 13, 'What types of books does Lan like?', NULL, NULL, 'Lan enjoys reading books. She often visits the library to borrow novels and magazines. Her favorite books are about adventure and history.', '["A: Science and math", "B: Adventure and history", "C: Cooking and sports", "D: Music and art"]', 'B', 'The passage mentions adventure and history.', 1, TRUE),
(1, 3, 14, 'What does Lan borrow from the library?', NULL, NULL, 'Lan enjoys reading books. She often visits the library to borrow novels and magazines. Her favorite books are about adventure and history.', '["A: Textbooks", "B: Novels and magazines", "C: Newspapers", "D: Maps"]', 'B', 'The passage specifies novels and magazines.', 1, TRUE),
(1, 3, 15, 'What is true about Lan?', NULL, NULL, 'Lan enjoys reading books. She often visits the library to borrow novels and magazines. Her favorite books are about adventure and history.', '["A: She dislikes reading", "B: She loves adventure books", "C: She never visits the library", "D: She prefers math books"]', 'B', 'The passage confirms her love for adventure books.', 1, TRUE),

-- Part 4: Nghe (5 câu)
(1, 4, 16, 'What is the man talking about?', 'https://example.com/audio/mini1_q16.mp3', NULL, NULL, '["A: His job", "B: His hobby", "C: His family", "D: His school"]', 'B', 'The man discusses his love for playing soccer.', 1, TRUE),
(1, 4, 17, 'Where is the woman going?', 'https://example.com/audio/mini1_q17.mp3', NULL, NULL, '["A: To the park", "B: To the library", "C: To the store", "D: To school"]', 'B', 'The woman mentions going to borrow books.', 1, TRUE),
(1, 4, 18, 'What does the man want to buy?', 'https://example.com/audio/mini1_q18.mp3', NULL, NULL, '["A: A book", "B: A phone", "C: A car", "D: A shirt"]', 'D', 'The man talks about buying a new shirt.', 1, TRUE),
(1, 4, 19, 'What time does the class start?', 'https://example.com/audio/mini1_q19.mp3', NULL, NULL, '["A: 7 AM", "B: 8 AM", "C: 9 AM", "D: 10 AM"]', 'B', 'The speaker says the class starts at 8 AM.', 1, TRUE),
(1, 4, 20, 'What is the weather like today?', 'https://example.com/audio/mini1_q20.mp3', NULL, NULL, '["A: Sunny", "B: Rainy", "C: Cloudy", "D: Windy"]', 'A', 'The speaker describes a sunny day.', 1, TRUE);




INSERT INTO questions_test (test_set_id, part_number, question_number, question_text, audio_url, image_url, passage_text, options, correct_answer, explanation, created_by, is_active) VALUES
-- Part 1: Ngữ âm (3 câu)
(2, 1, 1, 'Choose the word with a different stress pattern.', NULL, NULL, NULL, '["A: table", "B: pencil", "C: window", "D: computer"]', 'D', 'Computer stresses the second syllable, others stress the first.', 1, TRUE),
(2, 1, 2, 'Choose the word with a different pronunciation of "s".', NULL, NULL, NULL, '["A: cats", "B: dogs", "C: houses", "D: books"]', 'C', 'Houses is pronounced /ɪz/, others are /s/ or /z/.', 1, TRUE),
(2, 1, 3, 'Choose the word with a different vowel sound.', NULL, NULL, NULL, '["A: sit", "B: hit", "C: kite", "D: fit"]', 'C', 'Kite has /aɪ/, others have /ɪ/.', 1, TRUE),

-- Part 2: Từ vựng & Ngữ pháp (7 câu)
(2, 2, 4, 'Choose the correct word: He ___ to the park yesterday.', NULL, NULL, NULL, '["A: go", "B: goes", "C: went", "D: gone"]', 'C', 'Past simple is used for completed actions.', 1, TRUE),
(2, 2, 5, 'Choose the correct preposition: She is good ___ singing.', NULL, NULL, NULL, '["A: in", "B: at", "C: on", "D: with"]', 'B', 'Good is followed by the preposition "at".', 1, TRUE),
(2, 2, 6, 'Choose the correct form: If we ___ faster, we’ll catch the bus.', NULL, NULL, NULL, '["A: run", "B: ran", "C: had run", "D: will run"]', 'A', 'First conditional uses present simple for future possibilities.', 1, TRUE),
(2, 2, 7, 'Choose the correct word: This book is ___ than that one.', NULL, NULL, NULL, '["A: interesting", "B: more interesting", "C: most interesting", "D: interest"]', 'B', 'Comparative form is used with "than".', 1, TRUE),
(2, 2, 8, 'Choose the correct tense: I ___ my homework now.', NULL, NULL, NULL, '["A: do", "B: am doing", "C: did", "D: will do"]', 'B', 'Present continuous is used for actions happening now.', 1, TRUE),
(2, 2, 9, 'Choose the correct word: She is the ___ student in the class.', NULL, NULL, NULL, '["A: good", "B: better", "C: best", "D: most good"]', 'C', 'Superlative form is used for the highest degree.', 1, TRUE),
(2, 2, 10, 'Choose the correct form: The house ___ by the workers.', NULL, NULL, NULL, '["A: builds", "B: is built", "C: building", "D: built"]', 'B', 'Passive voice uses "is + past participle".', 1, TRUE),

-- Part 3: Đọc hiểu (5 câu)
(2, 3, 11, 'What is the main topic of the passage?', NULL, NULL, 'Nam loves playing sports. He plays soccer with his friends every weekend. His favorite sport is basketball.', '["A: Nam’s hobbies", "B: Nam’s school", "C: Nam’s family", "D: Nam’s studies"]', 'A', 'The passage discusses Nam’s sports activities.', 1, TRUE),
(2, 3, 12, 'When does Nam play soccer?', NULL, NULL, 'Nam loves playing sports. He plays soccer with his friends every weekend. His favorite sport is basketball.', '["A: Every day", "B: Every weekend", "C: Every month", "D: Every year"]', 'B', 'The passage states he plays soccer every weekend.', 1, TRUE),
(2, 3, 13, 'What is Nam’s favorite sport?', NULL, NULL, 'Nam loves playing sports. He plays soccer with his friends every weekend. His favorite sport is basketball.', '["A: Soccer", "B: Basketball", "C: Tennis", "D: Swimming"]', 'B', 'The passage mentions basketball as his favorite sport.', 1, TRUE),
(2, 3, 14, 'Who does Nam play soccer with?', NULL, NULL, 'Nam loves playing sports. He plays soccer with his friends every weekend. His favorite sport is basketball.', '["A: His family", "B: His teachers", "C: His friends", "D: His classmates"]', 'C', 'The passage specifies he plays with friends.', 1, TRUE),
(2, 3, 15, 'What is true about Nam?', NULL, NULL, 'Nam loves playing sports. He plays soccer with his friends every weekend. His favorite sport is basketball.', '["A: He dislikes sports", "B: He loves basketball", "C: He plays tennis", "D: He plays alone"]', 'B', 'The passage confirms his love for basketball.', 1, TRUE),

-- Part 4: Nghe (5 câu)
(2, 4, 16, 'What does the woman like to do?', 'https://example.com/audio/mini2_q16.mp3', NULL, NULL, '["A: Read books", "B: Watch movies", "C: Play sports", "D: Sing songs"]', 'B', 'The woman mentions watching movies as her hobby.', 1, TRUE),
(2, 4, 17, 'Where is the man going?', 'https://example.com/audio/mini2_q17.mp3', NULL, NULL, '["A: To the park", "B: To the market", "C: To school", "D: To the library"]', 'B', 'The man says he is going to buy food.', 1, TRUE),
(2, 4, 18, 'What does the woman want to eat?', 'https://example.com/audio/mini2_q18.mp3', NULL, NULL, '["A: Pizza", "B: Noodles", "C: Rice", "D: Salad"]', 'A', 'The woman mentions she wants pizza.', 1, TRUE),
(2, 4, 19, 'What time does the movie start?', 'https://example.com/audio/mini2_q19.mp3', NULL, NULL, '["A: 6 PM", "B: 7 PM", "C: 8 PM", "D: 9 PM"]', 'C', 'The speaker says the movie starts at 8 PM.', 1, TRUE),
(2, 4, 20, 'What is the man’s favorite subject?', 'https://example.com/audio/mini2_q20.mp3', NULL, NULL, '["A: Math", "B: English", "C: History", "D: Science"]', 'B', 'The man says English is his favorite subject.', 1, TRUE);



INSERT INTO questions_test (test_set_id, part_number, question_number, question_text, audio_url, image_url, passage_text, options, correct_answer, explanation, created_by, is_active) VALUES
-- Part 1: Ngữ âm (3 câu)
(3, 1, 1, 'Choose the word with a different stress pattern.', NULL, NULL, NULL, '["A: father", "B: mother", "C: sister", "D: engineer"]', 'D', 'Engineer stresses the third syllable, others stress the first.', 1, TRUE),
(3, 1, 2, 'Choose the word with a different pronunciation of "th".', NULL, NULL, NULL, '["A: think", "B: this", "C: thank", "D: thing"]', 'B', 'This is pronounced /ð/, others are /θ/.', 1, TRUE),
(3, 1, 3, 'Choose the word with a different vowel sound.', NULL, NULL, NULL, '["A: hot", "B: not", "C: cut", "D: put"]', 'D', 'Put has /ʊ/, others have /ʌ/ or /ɒ/.', 1, TRUE),

-- Part 2: Từ vựng & Ngữ pháp (7 câu)
(3, 2, 4, 'Choose the correct word: They ___ in Hanoi last year.', NULL, NULL, NULL, '["A: live", "B: lived", "C: living", "D: lives"]', 'B', 'Past simple is used for actions in the past.', 1, TRUE),
(3, 2, 5, 'Choose the correct preposition: He is afraid ___ spiders.', NULL, NULL, NULL, '["A: of", "B: at", "C: on", "D: with"]', 'A', 'Afraid is followed by the preposition "of".', 1, TRUE),
(3, 2, 6, 'Choose the correct form: If I ___ rich, I would travel.', NULL, NULL, NULL, '["A: am", "B: was", "C: were", "D: will be"]', 'C', 'Second conditional uses "were" for hypothetical situations.', 1, TRUE),
(3, 2, 7, 'Choose the correct word: She is ___ than her sister.', NULL, NULL, NULL, '["A: young", "B: younger", "C: youngest", "D: most young"]', 'B', 'Comparative form is used with "than".', 1, TRUE),
(3, 2, 8, 'Choose the correct tense: We ___ a movie now.', NULL, NULL, NULL, '["A: watch", "B: are watching", "C: watched", "D: will watch"]', 'B', 'Present continuous is used for actions happening now.', 1, TRUE),
(3, 2, 9, 'Choose the correct word: This is the ___ place I’ve visited.', NULL, NULL, NULL, '["A: beautiful", "B: more beautiful", "C: most beautiful", "D: beauty"]', 'C', 'Superlative form is used for the highest degree.', 1, TRUE),
(3, 2, 10, 'Choose the correct form: The book ___ by the teacher.', NULL, NULL, NULL, '["A: reads", "B: is read", "C: reading", "D: read"]', 'B', 'Passive voice uses "is + past participle".', 1, TRUE),

-- Part 3: Đọc hiểu (5 câu)
(3, 3, 11, 'What is the main topic of the passage?', NULL, NULL, 'Mai enjoys traveling. She has visited many places in Vietnam, such as Hanoi and Da Nang. Her favorite destination is Ha Long Bay.', '["A: Mai’s travels", "B: Mai’s studies", "C: Mai’s family", "D: Mai’s hobbies"]', 'A', 'The passage discusses Mai’s travel experiences.', 1, TRUE),
(3, 3, 12, 'Where has Mai visited?', NULL, NULL, 'Mai enjoys traveling. She has visited many places in Vietnam, such as Hanoi and Da Nang. Her favorite destination is Ha Long Bay.', '["A: Japan", "B: Hanoi and Da Nang", "C: Thailand", "D: Singapore"]', 'B', 'The passage mentions Hanoi and Da Nang.', 1, TRUE),
(3, 3, 13, 'What is Mai’s favorite destination?', NULL, NULL, 'Mai enjoys traveling. She has visited many places in Vietnam, such as Hanoi and Da Nang. Her favorite destination is Ha Long Bay.', '["A: Hanoi", "B: Da Nang", "C: Ha Long Bay", "D: Ho Chi Minh City"]', 'C', 'The passage states Ha Long Bay is her favorite.', 1, TRUE),
(3, 3, 14, 'What does Mai enjoy doing?', NULL, NULL, 'Mai enjoys traveling. She has visited many places in Vietnam, such as Hanoi and Da Nang. Her favorite destination is Ha Long Bay.', '["A: Studying", "B: Traveling", "C: Cooking", "D: Singing"]', 'B', 'The passage confirms she enjoys traveling.', 1, TRUE),
(3, 3, 15, 'What is true about Mai?', NULL, NULL, 'Mai enjoys traveling. She has visited many places in Vietnam, such as Hanoi and Da Nang. Her favorite destination is Ha Long Bay.', '["A: She dislikes traveling", "B: She loves Ha Long Bay", "C: She never travels", "D: She prefers studying"]', 'B', 'The passage confirms her love for Ha Long Bay.', 1, TRUE),

-- Part 4: Nghe (5 câu)
(3, 4, 16, 'What is the man’s favorite hobby?', 'https://example.com/audio/mini3_q16.mp3', NULL, NULL, '["A: Reading", "B: Swimming", "C: Singing", "D: Painting"]', 'B', 'The man mentions swimming as his favorite hobby.', 1, TRUE),
(3, 4, 17, 'Where is the woman going?', 'https://example.com/audio/mini3_q17.mp3', NULL, NULL, '["A: To the cinema", "B: To the park", "C: To school", "D: To the market"]', 'A', 'The woman says she is going to watch a movie.', 1, TRUE),
(3, 4, 18, 'What does the man want to do?', 'https://example.com/audio/mini3_q18.mp3', NULL, NULL, '["A: Play soccer", "B: Read a book", "C: Watch TV", "D: Eat dinner"]', 'A', 'The man mentions playing soccer.', 1, TRUE),
(3, 4, 19, 'What time does the bus leave?', 'https://example.com/audio/mini3_q19.mp3', NULL, NULL, '["A: 7 AM", "B: 8 AM", "C: 9 AM", "D: 10 AM"]', 'C', 'The speaker says the bus leaves at 9 AM.', 1, TRUE),
(3, 4, 20, 'What is the weather like today?', 'https://example.com/audio/mini3_q20.mp3', NULL, NULL, '["A: Rainy", "B: Sunny", "C: Cloudy", "D: Windy"]', 'B', 'The speaker describes a sunny day.', 1, TRUE);



INSERT INTO questions_test (test_set_id, part_number, question_number, question_text, audio_url, image_url, passage_text, options, correct_answer, explanation, created_by, is_active) VALUES
-- Part 1: Ngữ âm (5 câu)
(4, 1, 1, 'Choose the word with a different stress pattern.', NULL, NULL, NULL, '["A: apple", "B: banana", "C: orange", "D: holiday"]', 'D', 'Holiday stresses the first syllable, others stress the second.', 1, TRUE),
(4, 1, 2, 'Choose the word with a different pronunciation of "ed".', NULL, NULL, NULL, '["A: worked", "B: played", "C: needed", "D: stopped"]', 'C', 'Needed is pronounced /ɪd/, others are /t/ or /d/.', 1, TRUE),
(4, 1, 3, 'Choose the word with a different vowel sound.', NULL, NULL, NULL, '["A: bed", "B: pen", "C: ten", "D: fine"]', 'D', 'Fine has /aɪ/, others have /ɛ/.', 1, TRUE),
(4, 1, 4, 'Choose the word with a different pronunciation of "s".', NULL, NULL, NULL, '["A: cats", "B: dogs", "C: buses", "D: pens"]', 'C', 'Buses is pronounced /ɪz/, others are /s/ or /z/.', 1, TRUE),
(4, 1, 5, 'Choose the word with a different stress pattern.', NULL, NULL, NULL, '["A: teacher", "B: doctor", "C: student", "D: engineer"]', 'D', 'Engineer stresses the third syllable, others stress the first.', 1, TRUE),

-- Part 2: Từ vựng & Ngữ pháp (20 câu)
(4, 2, 6, 'Choose the correct word: She ___ to school every day.', NULL, NULL, NULL, '["A: go", "B: goes", "C: going", "D: gone"]', 'B', 'Present simple with "she" uses verb + s.', 1, TRUE),
(4, 2, 7, 'Choose the correct preposition: I’m good ___ math.', NULL, NULL, NULL, '["A: in", "B: at", "C: on", "D: with"]', 'B', 'Good is followed by the preposition "at".', 1, TRUE),
(4, 2, 8, 'Choose the correct form: If I ___ rich, I would travel.', NULL, NULL, NULL, '["A: am", "B: was", "C: were", "D: will be"]', 'C', 'Second conditional uses "were" for hypothetical situations.', 1, TRUE),
(4, 2, 9, 'Choose the correct word: He is ___ than his brother.', NULL, NULL, NULL, '["A: tall", "B: taller", "C: tallest", "D: most tall"]', 'B', 'Comparative form is used with "than".', 1, TRUE),
(4, 2, 10, 'Choose the correct tense: They ___ TV now.', NULL, NULL, NULL, '["A: watch", "B: are watching", "C: watched", "D: will watch"]', 'B', 'Present continuous is used for actions happening now.', 1, TRUE),
(4, 2, 11, 'Choose the correct word: This is the ___ book I’ve read.', NULL, NULL, NULL, '["A: good", "B: better", "C: best", "D: most good"]', 'C', 'Superlative form is used for the highest degree.', 1, TRUE),
(4, 2, 12, 'Choose the correct form: The room ___ every day.', NULL, NULL, NULL, '["A: cleans", "B: is cleaned", "C: cleaning", "D: cleaned"]', 'B', 'Passive voice uses "is + past participle".', 1, TRUE),
(4, 2, 13, 'Choose the correct word: She ___ to Hanoi last year.', NULL, NULL, NULL, '["A: go", "B: goes", "C: went", "D: gone"]', 'C', 'Past simple is used for completed actions.', 1, TRUE),
(4, 2, 14, 'Choose the correct preposition: He is fond ___ music.', NULL, NULL, NULL, '["A: of", "B: at", "C: on", "D: with"]', 'A', 'Fond is followed by the preposition "of".', 1, TRUE),
(4, 2, 15, 'Choose the correct form: If it ___ tomorrow, we’ll stay home.', NULL, NULL, NULL, '["A: rains", "B: rain", "C: rained", "D: will rain"]', 'A', 'First conditional uses present simple for future possibilities.', 1, TRUE),
(4, 2, 16, 'Choose the correct word: This is ___ house in the village.', NULL, NULL, NULL, '["A: big", "B: bigger", "C: biggest", "D: most big"]', 'C', 'Superlative form is used for the highest degree.', 1, TRUE),
(4, 2, 17, 'Choose the correct tense: I ___ my homework yesterday.', NULL, NULL, NULL, '["A: do", "B: did", "C: am doing", "D: will do"]', 'B', 'Past simple is used for completed actions.', 1, TRUE),
(4, 2, 18, 'Choose the correct word: She is interested ___ books.', NULL, NULL, NULL, '["A: in", "B: at", "C: on", "D: with"]', 'A', 'Interested is followed by the preposition "in".', 1, TRUE),
(4, 2, 19, 'Choose the correct form: The house ___ by workers last year.', NULL, NULL, NULL, '["A: builds", "B: was built", "C: is built", "D: built"]', 'B', 'Past simple passive uses "was + past participle".', 1, TRUE),
(4, 2, 20, 'Choose the correct word: He ___ to school by bus.', NULL, NULL, NULL, '["A: go", "B: goes", "C: going", "D: gone"]', 'B', 'Present simple with "he" uses verb + s.', 1, TRUE),
(4, 2, 21, 'Choose the correct tense: They ___ in London since 2010.', NULL, NULL, NULL, '["A: live", "B: lived", "C: have lived", "D: are living"]', 'C', 'Present perfect is used for actions continuing to the present.', 1, TRUE),
(4, 2, 22, 'Choose the correct word: This is the ___ movie I’ve seen.', NULL, NULL, NULL, '["A: good", "B: better", "C: best", "D: most good"]', 'C', 'Superlative form is used for the highest degree.', 1, TRUE),
(4, 2, 23, 'Choose the correct form: If I ___ you, I’d apologize.', NULL, NULL, NULL, '["A: am", "B: was", "C: were", "D: will be"]', 'C', 'Second conditional uses "were" for hypothetical situations.', 1, TRUE),
(4, 2, 24, 'Choose the correct preposition: She is good ___ drawing.', NULL, NULL, NULL, '["A: in", "B: at", "C: on", "D: with"]', 'B', 'Good is followed by the preposition "at".', 1, TRUE),
(4, 2, 25, 'Choose the correct tense: He ___ when I called.', NULL, NULL, NULL, '["A: sleeps", "B: slept", "C: was sleeping", "D: will sleep"]', 'C', 'Past continuous is used for ongoing past actions.', 1, TRUE),

-- Part 3: Đọc hiểu (15 câu)
(4, 3, 26, 'What is the main topic of the passage?', NULL, NULL, 'Huy is a high school student. He enjoys playing video games and reading books. His favorite subject is English, and he wants to become an English teacher.', '["A: Huy’s hobbies", "B: Huy’s family", "C: Huy’s school", "D: Huy’s friends"]', 'A', 'The passage discusses Huy’s hobbies and aspirations.', 1, TRUE),
(4, 3, 27, 'What does Huy enjoy doing?', NULL, NULL, 'Huy is a high school student. He enjoys playing video games and reading books. His favorite subject is English, and he wants to become an English teacher.', '["A: Playing sports", "B: Playing video games", "C: Cooking", "D: Singing"]', 'B', 'The passage mentions playing video games.', 1, TRUE),
(4, 3, 28, 'What is Huy’s favorite subject?', NULL, NULL, 'Huy is a high school student. He enjoys playing video games and reading books. His favorite subject is English, and he wants to become an English teacher.', '["A: Math", "B: English", "C: Science", "D: History"]', 'B', 'The passage states English is his favorite subject.', 1, TRUE),
(4, 3, 29, 'What does Huy want to become?', NULL, NULL, 'Huy is a high school student. He enjoys playing video games and reading books. His favorite subject is English, and he wants to become an English teacher.', '["A: A doctor", "B: A teacher", "C: A singer", "D: A chef"]', 'B', 'The passage mentions he wants to be an English teacher.', 1, TRUE),
(4, 3, 30, 'What is true about Huy?', NULL, NULL, 'Huy is a high school student. He enjoys playing video games and reading books. His favorite subject is English, and he wants to become an English teacher.', '["A: He dislikes English", "B: He loves video games", "C: He wants to be a doctor", "D: He hates reading"]', 'B', 'The passage confirms his love for video games.', 1, TRUE),
(4, 3, 31, 'What is the main topic of the passage?', NULL, NULL, 'Vietnam is famous for its beautiful beaches. Many tourists visit Phu Quoc and Nha Trang every year. These places offer clear water and sunny weather.', '["A: Vietnam’s cities", "B: Vietnam’s beaches", "C: Vietnam’s food", "D: Vietnam’s culture"]', 'B', 'The passage discusses Vietnam’s beaches.', 1, TRUE),
(4, 3, 32, 'Where do tourists often visit in Vietnam?', NULL, NULL, 'Vietnam is famous for its beautiful beaches. Many tourists visit Phu Quoc and Nha Trang every year. These places offer clear water and sunny weather.', '["A: Hanoi and Da Nang", "B: Phu Quoc and Nha Trang", "C: Ho Chi Minh City", "D: Hue"]', 'B', 'The passage mentions Phu Quoc and Nha Trang.', 1, TRUE),
(4, 3, 33, 'What do Phu Quoc and Nha Trang offer?', NULL, NULL, 'Vietnam is famous for its beautiful beaches. Many tourists visit Phu Quoc and Nha Trang every year. These places offer clear water and sunny weather.', '["A: Clear water", "B: Cold weather", "C: Big cities", "D: Old temples"]', 'A', 'The passage states they offer clear water.', 1, TRUE),
(4, 3, 34, 'Why do tourists visit Vietnam?', NULL, NULL, 'Vietnam is famous for its beautiful beaches. Many tourists visit Phu Quoc and Nha Trang every year. These places offer clear water and sunny weather.', '["A: For its food", "B: For its beaches", "C: For its schools", "D: For its markets"]', 'B', 'The passage highlights the beaches.', 1, TRUE),
(4, 3, 35, 'What is true about Vietnam’s beaches?', NULL, NULL, 'Vietnam is famous for its beautiful beaches. Many tourists visit Phu Quoc and Nha Trang every year. These places offer clear water and sunny weather.', '["A: They are cold", "B: They have clear water", "C: They are unpopular", "D: They are in cities"]', 'B', 'The passage confirms clear water.', 1, TRUE),
(4, 3, 36, 'What is the main topic of the passage?', NULL, NULL, 'Lan loves music. She plays the guitar and sings with her friends. She wants to join a music club at school.', '["A: Lan’s hobbies", "B: Lan’s family", "C: Lan’s school", "D: Lan’s studies"]', 'A', 'The passage discusses Lan’s music hobbies.', 1, TRUE),
(4, 3, 37, 'What instrument does Lan play?', NULL, NULL, 'Lan loves music. She plays the guitar and sings with her friends. She wants to join a music club at school.', '["A: Piano", "B: Guitar", "C: Violin", "D: Drums"]', 'B', 'The passage mentions she plays the guitar.', 1, TRUE),
(4, 3, 38, 'What does Lan want to do?', NULL, NULL, 'Lan loves music. She plays the guitar and sings with her friends. She wants to join a music club at school.', '["A: Join a sports club", "B: Join a music club", "C: Join a book club", "D: Join a math club"]', 'B', 'The passage states she wants to join a music club.', 1, TRUE),
(4, 3, 39, 'Who does Lan sing with?', NULL, NULL, 'Lan loves music. She plays the guitar and sings with her friends. She wants to join a music club at school.', '["A: Her family", "B: Her teachers", "C: Her friends", "D: Her classmates"]', 'C', 'The passage mentions she sings with friends.', 1, TRUE),
(4, 3, 40, 'What is true about Lan?', NULL, NULL, 'Lan loves music. She plays the guitar and sings with her friends. She wants to join a music club at school.', '["A: She dislikes music", "B: She loves singing", "C: She plays sports", "D: She hates school"]', 'B', 'The passage confirms her love for singing.', 1, TRUE),

-- Part 4: Nghe (10 câu)
(4, 4, 41, 'What is the man talking about?', 'https://example.com/audio/full1_q41.mp3', NULL, NULL, '["A: His job", "B: His hobby", "C: His family", "D: His school"]', 'B', 'The man discusses his love for painting.', 1, TRUE),
(4, 4, 42, 'Where is the woman going?', 'https://example.com/audio/full1_q42.mp3', NULL, NULL, '["A: To the park", "B: To the library", "C: To the store", "D: To school"]', 'B', 'The woman mentions going to borrow books.', 1, TRUE),
(4, 4, 43, 'What does the man want to buy?', 'https://example.com/audio/full1_q43.mp3', NULL, NULL, '["A: A book", "B: A phone", "C: A car", "D: A shirt"]', 'D', 'The man talks about buying a new shirt.', 1, TRUE),
(4, 4, 44, 'What time does the class start?', 'https://example.com/audio/full1_q44.mp3', NULL, NULL, '["A: 7 AM", "B: 8 AM", "C: 9 AM", "D: 10 AM"]', 'B', 'The speaker says the class starts at 8 AM.', 1, TRUE),
(4, 4, 45, 'What is the weather like today?', 'https://example.com/audio/full1_q45.mp3', NULL, NULL, '["A: Sunny", "B: Rainy", "C: Cloudy", "D: Windy"]', 'A', 'The speaker describes a sunny day.', 1, TRUE),
(4, 4, 46, 'What does the woman like to do?', 'https://example.com/audio/full1_q46.mp3', NULL, NULL, '["A: Read books", "B: Watch movies", "C: Play sports", "D: Sing songs"]', 'B', 'The woman mentions watching movies as her hobby.', 1, TRUE),
(4, 4, 47, 'Where is the man going?', 'https://example.com/audio/full1_q47.mp3', NULL, NULL, '["A: To the park", "B: To the market", "C: To school", "D: To the library"]', 'B', 'The man says he is going to buy food.', 1, TRUE),
(4, 4, 48, 'What does the woman want to eat?', 'https://example.com/audio/full1_q48.mp3', NULL, NULL, '["A: Pizza", "B: Noodles", "C: Rice", "D: Salad"]', 'A', 'The woman mentions she wants pizza.', 1, TRUE),
(4, 4, 49, 'What time does the movie start?', 'https://example.com/audio/full1_q49.mp3', NULL, NULL, '["A: 6 PM", "B: 7 PM", "C: 8 PM", "D: 9 PM"]', 'C', 'The speaker says the movie starts at 8 PM.', 1, TRUE),
(4, 4, 50, 'What is the man’s favorite subject?', 'https://example.com/audio/full1_q50.mp3', NULL, NULL, '["A: Math", "B: English", "C: History", "D: Science"]', 'B', 'The man says English is his favorite subject.', 1, TRUE);



INSERT INTO test_sets (name, type, total_questions, time_limit, description, created_by, is_active) VALUES
('Mini Test 4 - Grade 12 English', 'mini_test', 20, 30, 'Bộ đề kiểm tra tiếng Anh cấp 3, bao gồm ngữ âm, từ vựng, ngữ pháp, đọc hiểu và nghe.', 1, TRUE),
('Full Test 2 - Grade 12 English', 'full_test', 50, 60, 'Bộ đề thi thử tiếng Anh cấp 3, luyện tập toàn diện các kỹ năng ngữ âm, từ vựng, ngữ pháp, đọc hiểu và nghe.', 1, TRUE);



INSERT INTO questions_test (test_set_id, part_number, question_number, question_text, audio_url, image_url, passage_text, options, correct_answer, explanation, created_by, is_active) VALUES
-- Part 1: Ngữ âm (3 câu)
(5, 1, 1, 'Choose the word with a different stress pattern.', NULL, NULL, NULL, '["A: father", "B: mother", "C: brother", "D: hospital"]', 'D', 'Hospital stresses the first syllable, others stress the second.', 1, TRUE),
(5, 1, 2, 'Choose the word with a different pronunciation of "ch".', NULL, NULL, NULL, '["A: chair", "B: cheese", "C: machine", "D: child"]', 'C', 'Machine is pronounced /ʃ/, others are /tʃ/.', 1, TRUE),
(5, 1, 3, 'Choose the word with a different vowel sound.', NULL, NULL, NULL, '["A: book", "B: look", "C: food", "D: foot"]', 'C', 'Food has /uː/, others have /ʊ/.', 1, TRUE),

-- Part 2: Từ vựng & Ngữ pháp (7 câu)
(5, 2, 4, 'Choose the correct word: He ___ to the market every weekend.', NULL, NULL, NULL, '["A: go", "B: goes", "C: going", "D: gone"]', 'B', 'Present simple with "he" uses verb + s.', 1, TRUE),
(5, 2, 5, 'Choose the correct preposition: She is keen ___ learning English.', NULL, NULL, NULL, '["A: on", "B: at", "C: in", "D: with"]', 'A', 'Keen is followed by the preposition "on".', 1, TRUE),
(5, 2, 6, 'Choose the correct form: If I ___ you, I would call her.', NULL, NULL, NULL, '["A: am", "B: was", "C: were", "D: will be"]', 'C', 'Second conditional uses "were" for hypothetical situations.', 1, TRUE),
(5, 2, 7, 'Choose the correct word: This is ___ book in the library.', NULL, NULL, NULL, '["A: interesting", "B: more interesting", "C: most interesting", "D: the most interesting"]', 'D', 'Superlative form with "the" is used for the highest degree.', 1, TRUE),
(5, 2, 8, 'Choose the correct tense: They ___ a movie last night.', NULL, NULL, NULL, '["A: watch", "B: watched", "C: are watching", "D: will watch"]', 'B', 'Past simple is used for completed actions.', 1, TRUE),
(5, 2, 9, 'Choose the correct word: She is ___ than her friend.', NULL, NULL, NULL, '["A: smart", "B: smarter", "C: smartest", "D: most smart"]', 'B', 'Comparative form is used with "than".', 1, TRUE),
(5, 2, 10, 'Choose the correct form: The cake ___ by my mother yesterday.', NULL, NULL, NULL, '["A: bakes", "B: is baked", "C: was baked", "D: baking"]', 'C', 'Past simple passive uses "was + past participle".', 1, TRUE),

-- Part 3: Đọc hiểu (5 câu)
(5, 3, 11, 'What is the main topic of the passage?', NULL, NULL, 'Hoa enjoys painting. She often paints landscapes and flowers. Her favorite place to paint is in the park.', '["A: Hoa’s hobbies", "B: Hoa’s school", "C: Hoa’s family", "D: Hoa’s friends"]', 'A', 'The passage discusses Hoa’s painting hobby.', 1, TRUE),
(5, 3, 12, 'What does Hoa like to paint?', NULL, NULL, 'Hoa enjoys painting. She often paints landscapes and flowers. Her favorite place to paint is in the park.', '["A: Animals", "B: Landscapes and flowers", "C: Buildings", "D: People"]', 'B', 'The passage mentions landscapes and flowers.', 1, TRUE),
(5, 3, 13, 'Where does Hoa like to paint?', NULL, NULL, 'Hoa enjoys painting. She often paints landscapes and flowers. Her favorite place to paint is in the park.', '["A: At school", "B: At home", "C: In the park", "D: In the library"]', 'C', 'The passage states she paints in the park.', 1, TRUE),
(5, 3, 14, 'What is true about Hoa?', NULL, NULL, 'Hoa enjoys painting. She often paints landscapes and flowers. Her favorite place to paint is in the park.', '["A: She dislikes painting", "B: She loves painting", "C: She paints buildings", "D: She paints at school"]', 'B', 'The passage confirms her love for painting.', 1, TRUE),
(5, 3, 15, 'What does Hoa often paint?', NULL, NULL, 'Hoa enjoys painting. She often paints landscapes and flowers. Her favorite place to paint is in the park.', '["A: Portraits", "B: Landscapes", "C: Cars", "D: Books"]', 'B', 'The passage specifies landscapes as one of her subjects.', 1, TRUE),

-- Part 4: Nghe (5 câu)
(5, 4, 16, 'What is the woman talking about?', 'https://example.com/audio/mini4_q16.mp3', NULL, NULL, '["A: Her job", "B: Her hobby", "C: Her family", "D: Her school"]', 'B', 'The woman discusses her love for dancing.', 1, TRUE),
(5, 4, 17, 'Where is the man going?', 'https://example.com/audio/mini4_q17.mp3', NULL, NULL, '["A: To the cinema", "B: To the park", "C: To school", "D: To the market"]', 'A', 'The man says he is going to watch a movie.', 1, TRUE),
(5, 4, 18, 'What does the woman want to buy?', 'https://example.com/audio/mini4_q18.mp3', NULL, NULL, '["A: A book", "B: A dress", "C: A phone", "D: A car"]', 'B', 'The woman mentions buying a new dress.', 1, TRUE),
(5, 4, 19, 'What time does the train leave?', 'https://example.com/audio/mini4_q19.mp3', NULL, NULL, '["A: 6 AM", "B: 7 AM", "C: 8 AM", "D: 9 AM"]', 'C', 'The speaker says the train leaves at 8 AM.', 1, TRUE),
(5, 4, 20, 'What is the weather like today?', 'https://example.com/audio/mini4_q20.mp3', NULL, NULL, '["A: Rainy", "B: Sunny", "C: Cloudy", "D: Windy"]', 'B', 'The speaker describes a sunny day.', 1, TRUE);



INSERT INTO questions_test (test_set_id, part_number, question_number, question_text, audio_url, image_url, passage_text, options, correct_answer, explanation, created_by, is_active) VALUES
-- Part 1: Ngữ âm (5 câu)
(6, 1, 1, 'Choose the word with a different stress pattern.', NULL, NULL, NULL, '["A: water", "B: river", "C: forest", "D: holiday"]', 'D', 'Holiday stresses the first syllable, others stress the second.', 1, TRUE),
(6, 1, 2, 'Choose the word with a different pronunciation of "ed".', NULL, NULL, NULL, '["A: worked", "B: played", "C: needed", "D: stopped"]', 'C', 'Needed is pronounced /ɪd/, others are /t/ or /d/.', 1, TRUE),
(6, 1, 3, 'Choose the word with a different vowel sound.', NULL, NULL, NULL, '["A: sit", "B: hit", "C: kite", "D: fit"]', 'C', 'Kite has /aɪ/, others have /ɪ/.', 1, TRUE),
(6, 1, 4, 'Choose the word with a different pronunciation of "s".', NULL, NULL, NULL, '["A: cats", "B: dogs", "C: houses", "D: pens"]', 'C', 'Houses is pronounced /ɪz/, others are /s/ or /z/.', 1, TRUE),
(6, 1, 5, 'Choose the word with a different stress pattern.', NULL, NULL, NULL, '["A: teacher", "B: doctor", "C: student", "D: engineer"]', 'D', 'Engineer stresses the third syllable, others stress the first.', 1, TRUE);


INSERT INTO questions_test (test_set_id, part_number, question_number, question_text, audio_url, image_url, passage_text, options, correct_answer, explanation, created_by, is_active) VALUES
-- Part 2: Từ vựng & Ngữ pháp (20 câu)
(6, 2, 6, 'Choose the correct word: She ___ to school every day.', NULL, NULL, NULL, '["A: go", "B: goes", "C: going", "D: gone"]', 'B', 'Present simple with "she" uses verb + s.', 1, TRUE),
(6, 2, 7, 'Choose the correct preposition: He is good ___ playing football.', NULL, NULL, NULL, '["A: in", "B: at", "C: on", "D: with"]', 'B', 'Good is followed by the preposition "at".', 1, TRUE),
(6, 2, 8, 'Choose the correct form: If I ___ rich, I would travel the world.', NULL, NULL, NULL, '["A: am", "B: was", "C: were", "D: will be"]', 'C', 'Second conditional uses "were" for hypothetical situations.', 1, TRUE),
(6, 2, 9, 'Choose the correct word: This is ___ book I’ve ever read.', NULL, NULL, NULL, '["A: good", "B: better", "C: best", "D: most good"]', 'C', 'Superlative form is used for the highest degree.', 1, TRUE),
(6, 2, 10, 'Choose the correct tense: They ___ a movie now.', NULL, NULL, NULL, '["A: watch", "B: are watching", "C: watched", "D: will watch"]', 'B', 'Present continuous is used for actions happening now.', 1, TRUE),
(6, 2, 11, 'Choose the correct word: She is ___ than her sister.', NULL, NULL, NULL, '["A: tall", "B: taller", "C: tallest", "D: most tall"]', 'B', 'Comparative form is used with "than".', 1, TRUE),
(6, 2, 12, 'Choose the correct form: The house ___ by workers last year.', NULL, NULL, NULL, '["A: builds", "B: was built", "C: is built", "D: built"]', 'B', 'Past simple passive uses "was + past participle".', 1, TRUE),
(6, 2, 13, 'Choose the correct word: He ___ to Hanoi yesterday.', NULL, NULL, NULL, '["A: go", "B: goes", "C: went", "D: gone"]', 'C', 'Past simple is used for completed actions.', 1, TRUE),
(6, 2, 14, 'Choose the correct preposition: She is fond ___ music.', NULL, NULL, NULL, '["A: of", "B: at", "C: on", "D: with"]', 'A', 'Fond is followed by the preposition "of".', 1, TRUE),
(6, 2, 15, 'Choose the correct form: If it ___ tomorrow, we’ll cancel the picnic.', NULL, NULL, NULL, '["A: rains", "B: rain", "C: rained", "D: will rain"]', 'A', 'First conditional uses present simple for future possibilities.', 1, TRUE),
(6, 2, 16, 'Choose the correct word: This is the ___ place I’ve visited.', NULL, NULL, NULL, '["A: beautiful", "B: more beautiful", "C: most beautiful", "D: beauty"]', 'C', 'Superlative form is used for the highest degree.', 1, TRUE),
(6, 2, 17, 'Choose the correct tense: I ___ my homework yesterday.', NULL, NULL, NULL, '["A: do", "B: did", "C: am doing", "D: will do"]', 'B', 'Past simple is used for completed actions.', 1, TRUE),
(6, 2, 18, 'Choose the correct preposition: He is interested ___ science.', NULL, NULL, NULL, '["A: in", "B: at", "C: on", "D: with"]', 'A', 'Interested is followed by the preposition "in".', 1, TRUE),
(6, 2, 19, 'Choose the correct form: The book ___ by students every day.', NULL, NULL, NULL, '["A: reads", "B: is read", "C: reading", "D: read"]', 'B', 'Present simple passive uses "is + past participle".', 1, TRUE),
(6, 2, 20, 'Choose the correct word: She ___ to school by bike.', NULL, NULL, NULL, '["A: go", "B: goes", "C: going", "D: gone"]', 'B', 'Present simple with "she" uses verb + s.', 1, TRUE),
(6, 2, 21, 'Choose the correct tense: They ___ in Da Nang since 2015.', NULL, NULL, NULL, '["A: live", "B: lived", "C: have lived", "D: are living"]', 'C', 'Present perfect is used for actions continuing to the present.', 1, TRUE),
(6, 2, 22, 'Choose the correct word: This is the ___ movie I’ve seen.', NULL, NULL, NULL, '["A: good", "B: better", "C: best", "D: most good"]', 'C', 'Superlative form is used for the highest degree.', 1, TRUE),
(6, 2, 23, 'Choose the correct form: If I ___ you, I’d study harder.', NULL, NULL, NULL, '["A: am", "B: was", "C: were", "D: will be"]', 'C', 'Second conditional uses "were" for hypothetical situations.', 1, TRUE),
(6, 2, 24, 'Choose the correct preposition: She is good ___ dancing.', NULL, NULL, NULL, '["A: in", "B: at", "C: on", "D: with"]', 'B', 'Good is followed by the preposition "at".', 1, TRUE),
(6, 2, 25, 'Choose the correct tense: He ___ when I called him.', NULL, NULL, NULL, '["A: sleeps", "B: slept", "C: was sleeping", "D: will sleep"]', 'C', 'Past continuous is used for ongoing past actions.', 1, TRUE),
(6, 3, 26, 'What is the main topic of the passage?', NULL, NULL, 'Minh enjoys playing soccer. He practices with his team every weekend. His dream is to become a professional player.', '["A: Minh’s hobbies", "B: Minh’s school", "C: Minh’s family", "D: Minh’s studies"]', 'A', 'The passage discusses Minh’s soccer hobby and dream.', 1, TRUE),
(6, 3, 27, 'What does Minh enjoy doing?', NULL, NULL, 'Minh enjoys playing soccer. He practices with his team every weekend. His dream is to become a professional player.', '["A: Playing soccer", "B: Reading books", "C: Singing", "D: Painting"]', 'A', 'The passage mentions playing soccer.', 1, TRUE),
(6, 3, 28, 'When does Minh practice soccer?', NULL, NULL, 'Minh enjoys playing soccer. He practices with his team every weekend. His dream is to become a professional player.', '["A: Every day", "B: Every weekend", "C: Every month", "D: Every year"]', 'B', 'The passage states he practices every weekend.', 1, TRUE),
(6, 3, 29, 'What is Minh’s dream?', NULL, NULL, 'Minh enjoys playing soccer. He practices with his team every weekend. His dream is to become a professional player.', '["A: To be a teacher", "B: To be a professional player", "C: To be a singer", "D: To be a doctor"]', 'B', 'The passage mentions his dream to be a professional player.', 1, TRUE),
(6, 3, 30, 'What is true about Minh?', NULL, NULL, 'Minh enjoys playing soccer. He practices with his team every weekend. His dream is to become a professional player.', '["A: He dislikes soccer", "B: He loves soccer", "C: He plays alone", "D: He wants to be a chef"]', 'B', 'The passage confirms his love for soccer.', 1, TRUE),
(6, 3, 31, 'What is the main topic of the passage?', NULL, NULL, 'Hanoi is the capital of Vietnam. It is famous for its old temples, beautiful lakes, and delicious food. Many tourists visit Hanoi every year.', '["A: Hanoi’s culture", "B: Hanoi’s schools", "C: Hanoi’s markets", "D: Hanoi’s weather"]', 'A', 'The passage discusses Hanoi’s cultural attractions.', 1, TRUE),
(6, 3, 32, 'What is Hanoi famous for?', NULL, NULL, 'Hanoi is the capital of Vietnam. It is famous for its old temples, beautiful lakes, and delicious food. Many tourists visit Hanoi every year.', '["A: Temples and lakes", "B: Skyscrapers", "C: Beaches", "D: Mountains"]', 'A', 'The passage mentions temples, lakes, and food.', 1, TRUE),
(6, 3, 33, 'Who visits Hanoi every year?', NULL, NULL, 'Hanoi is the capital of Vietnam. It is famous for its old temples, beautiful lakes, and delicious food. Many tourists visit Hanoi every year.', '["A: Students", "B: Tourists", "C: Teachers", "D: Doctors"]', 'B', 'The passage states many tourists visit Hanoi.', 1, TRUE),
(6, 3, 34, 'What is true about Hanoi?', NULL, NULL, 'Hanoi is the capital of Vietnam. It is famous for its old temples, beautiful lakes, and delicious food. Many tourists visit Hanoi every year.', '["A: It has no lakes", "B: It is famous for food", "C: It is not a capital", "D: It has no tourists"]', 'B', 'The passage confirms Hanoi’s fame for food.', 1, TRUE),
(6, 3, 35, 'What attracts tourists to Hanoi?', NULL, NULL, 'Hanoi is the capital of Vietnam. It is famous for its old temples, beautiful lakes, and delicious food. Many tourists visit Hanoi every year.', '["A: Modern buildings", "B: Temples and lakes", "C: Deserts", "D: Sports events"]', 'B', 'The passage highlights temples and lakes.', 1, TRUE),
(6, 3, 36, 'What is the main topic of the passage?', NULL, NULL, 'Lan loves reading books. She visits the library every week to borrow novels. Her favorite books are about adventure.', '["A: Lan’s hobbies", "B: Lan’s family", "C: Lan’s school", "D: Lan’s friends"]', 'A', 'The passage discusses Lan’s reading hobby.', 1, TRUE),
(6, 3, 37, 'What does Lan love to do?', NULL, NULL, 'Lan loves reading books. She visits the library every week to borrow novels. Her favorite books are about adventure.', '["A: Singing", "B: Reading books", "C: Playing sports", "D: Painting"]', 'B', 'The passage mentions reading books.', 1, TRUE),
(6, 3, 38, 'Where does Lan go every week?', NULL, NULL, 'Lan loves reading books. She visits the library every week to borrow novels. Her favorite books are about adventure.', '["A: Park", "B: Library", "C: Market", "D: School"]', 'B', 'The passage states she visits the library.', 1, TRUE),
(6, 3, 39, 'What type of books does Lan like?', NULL, NULL, 'Lan loves reading books. She visits the library every week to borrow novels. Her favorite books are about adventure.', '["A: History", "B: Adventure", "C: Science", "D: Math"]', 'B', 'The passage mentions adventure books.', 1, TRUE),
(6, 3, 40, 'What is true about Lan?', NULL, NULL, 'Lan loves reading books. She visits the library every week to borrow novels. Her favorite books are about adventure.', '["A: She dislikes reading", "B: She loves adventure books", "C: She never visits the library", "D: She prefers sports"]', 'B', 'The passage confirms her love for adventure books.', 1, TRUE),
(6, 4, 41, 'What is the man talking about?', 'https://example.com/audio/full2_q41.mp3', NULL, NULL, '["A: His job", "B: His hobby", "C: His family", "D: His school"]', 'B', 'The man discusses his love for playing guitar.', 1, TRUE),
(6, 4, 42, 'Where is the woman going?', 'https://example.com/audio/full2_q42.mp3', NULL, NULL, '["A: To the park", "B: To the library", "C: To the store", "D: To school"]', 'B', 'The woman mentions going to borrow books.', 1, TRUE),
(6, 4, 43, 'What does the man want to buy?', 'https://example.com/audio/full2_q43.mp3', NULL, NULL, '["A: A book", "B: A phone", "C: A car", "D: A shirt"]', 'D', 'The man talks about buying a new shirt.', 1, TRUE),
(6, 4, 44, 'What time does the class start?', 'https://example.com/audio/full2_q44.mp3', NULL, NULL, '["A: 7 AM", "B: 8 AM", "C: 9 AM", "D: 10 AM"]', 'B', 'The speaker says the class starts at 8 AM.', 1, TRUE),
(6, 4, 45, 'What is the weather like today?', 'https://example.com/audio/full2_q45.mp3', NULL, NULL, '["A: Sunny", "B: Rainy", "C: Cloudy", "D: Windy"]', 'A', 'The speaker describes a sunny day.', 1, TRUE),
(6, 4, 46, 'What does the woman like to do?', 'https://example.com/audio/full2_q46.mp3', NULL, NULL, '["A: Read books", "B: Watch movies", "C: Play sports", "D: Sing songs"]', 'B', 'The woman mentions watching movies as her hobby.', 1, TRUE),
(6, 4, 47, 'Where is the man going?', 'https://example.com/audio/full2_q47.mp3', NULL, NULL, '["A: To the park", "B: To the market", "C: To school", "D: To the library"]', 'B', 'The man says he is going to buy food.', 1, TRUE),
(6, 4, 48, 'What does the woman want to eat?', 'https://example.com/audio/full2_q48.mp3', NULL, NULL, '["A: Pizza", "B: Noodles", "C: Rice", "D: Salad"]', 'A', 'The woman mentions she wants pizza.', 1, TRUE),
(6, 4, 49, 'What time does the movie start?', 'https://example.com/audio/full2_q49.mp3', NULL, NULL, '["A: 6 PM", "B: 7 PM", "C: 8 PM", "D: 9 PM"]', 'C', 'The speaker says the movie starts at 8 PM.', 1, TRUE),
(6, 4, 50, 'What is the man’s favorite subject?', 'https://example.com/audio/full2_q50.mp3', NULL, NULL, '["A: Math", "B: English", "C: History", "D: Science"]', 'B', 'The man says English is his favorite subject.', 1, TRUE);