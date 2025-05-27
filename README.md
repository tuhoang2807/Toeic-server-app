
# 🚀 TOEIC App - Hướng dẫn chạy Server

## Yêu cầu cài đặt
- Docker đã cài sẵn  
- Node.js (nếu muốn chạy ngoài Docker)  
- Postman để test API  

---

## Xem API endpoint
- Tải và cài đặt Postman: https://www.postman.com/downloads/ ->
- tk mk đăng nhập Postman: minhquan090303@gmail.com/09032003qqq
- Bảo Quân truy cập hộ cho ae nếu xác minh 2 lớp


## Sau khi clone code về:
- Tạo file .env, copy nội dung từ .env.example vào 
- Kiểm tra Node version >= 18

## 🐳 Khởi chạy ứng dụng

1. **Cài Docker**  
   Truy cập: https://www.docker.com/ → tải và cài đặt Docker

2. **Mở terminal tại thư mục chứa source code**

3. **Build và chạy Docker container:**
```bash
docker-compose up --build        // cái này chạy lần đầu tiên để build server
docker-compose up                // các lần sau chạy thì chạy lệnh này hoặc dùng lệnh docker-compose up -d
docker-compose up -d             // Để server chạy nền 
```
4. **Tắt Docker:**
```bash
docker-compose stop        # Tạm dừng (giữ nguyên dữ liệu)
docker-compose down        # Tắt và xóa container (giữ nguyên dữ liệu)
# hoặc Ctrl + C
```

5. **Xóa sạch dữ liệu:**
```bash
docker-compose down -v     # Xóa cả volumes (mất hết data)
```
---

## 💾 Backup và Restore Database

### 📤 Tạo backup (khi bạn có dữ liệu muốn chia sẻ):

Bước 1: Đảm bảo Docker đang chạy
```bash
docker-compose up -d
```

Bước 2: Tạo file backup
```bash
docker exec toeic_mysql mysqldump -u root -p12345678 --routines --triggers toeic_db > backup.sql
```
- File `backup.sql` sẽ được tạo trong thư mục hiện tại

---

### 📥 Khôi phục dữ liệu (khi nhận backup từ người khác):

Bước 1: Build Docker
```bash
docker-compose up --build -d
```
Bước 2: Copy file backup vào container
```bash
docker cp backup.sql toeic_mysql:/backup.sql
```

Bước 3: Khôi phục dữ liệu
```bash
docker exec -i toeic_mysql mysql -u root -p12345678 toeic_db < backup.sql
```

Hoặc cách khác (vào trong container):
```bash
# Vào container MySQL
docker exec -it toeic_mysql bash

# Chạy lệnh restore bên trong container
mysql -u root -p12345678 toeic_db < /backup.sql

# Thoát container
exit
```

---

## 🔧 Các lệnh hữu ích

- Xem logs:
```bash
docker-compose logs -f        # Xem tất cả logs
docker-compose logs -f app    # Chỉ xem logs của Node.js
docker-compose logs -f mysql  # Chỉ xem logs của MySQL
```

- Truy cập MySQL trực tiếp:
```bash
docker exec -it toeic_mysql mysql -u root -p12345678
```

- Kiểm tra container đang chạy:
```bash
docker ps
```

- Restart chỉ một service:
```bash
docker-compose restart app    # Restart Node.js
docker-compose restart mysql  # Restart MySQL
```

---

## 📋 Thông tin kết nối
- Vào extensions, tải SQL Tool, SQL Driver (MariaDB)
- API Server: `http://localhost:8000`  
- MySQL Host: `localhost:3307`  
- Database: `toeic_db`  
- Username: `root`  
- Password: `12345678`

---

## ⚠️ Lưu ý quan trọng

- File `backup.sql` chứa toàn bộ dữ liệu → cần chia sẻ file này khi muốn share database  
- Không commit file `backup.sql` lên Git (thêm vào `.gitignore`)  
- Volumes được mount → dữ liệu sẽ được lưu persistent ngay cả khi container bị xóa  
- Thay đổi password trong production environment  
