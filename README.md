# 🚀 TOEIC App - Hướng dẫn chạy Server

Tải và cài đặt: 

- [Docker](https://www.docker.com/) đã cài sẵn
- [Node.js](https://nodejs.org/) (nếu muốn chạy ngoài Docker)
- [Postman](https://www.postman.com/downloads/) để test API

---

### 1. Cài Docker

Ae truy cập: https://www.docker.com/ → tải và cài đặt Docker nhé

### 2. Mở terminal tại thư mục chứa source code

### 3. Build và chạy Docker container:

docker-compose up --build

✅ Lần đầu cần --build để Docker dựng image và cài đặt mọi thứ.

### 4. Ae muốn tắt docker thì dùng:  

docker-compose stop hoặc docker-compose down hoặc Ctrl + C

### TRƯỜNG HỢP MUỐN XÓA SẠCH DỮ LIỆU DÙNG 

docker-compose down -v


### 5. Trường hợp làm data xong muốn thêm lại dữ liệu thì dùng back-up docker
docker exec toeic_mysql mysqldump -u root -pYourPassword toeic_db > backup.sql

### 6. Ae clone code về rồi làm các bước sau để khôi phục dữ liệu
# Bước 1: build và khởi động Docker
docker-compose up --build

# Bước 2: copy file backup.sql vào trong container MySQL
docker cp backup.sql toeic_mysql:/backup.sql

# Bước 3: vào trong container
docker exec -it toeic_mysql bash

# Bước 4: khôi phục dữ liệu
mysql -u root -p$MYSQL_ROOT_PASSWORD toeic_db < /backup.sql

Lưu ý file backup nếu 1 người làm rồi mà muốn đẩy lên cho ae kia pull về


docker exec -it toeic_mysql mysql -uroot -p12345678
