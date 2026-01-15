CREATE DATABASE session11_db;
USE session11_db;
-- EX1:
-- Tạo bảng acount và thêm dữ liệu
CREATE TABLE acounts(
    acount_id INT PRIMARY KEY AUTO_INCREMENT,
    balance DECIMAL(10,2)
);
INSERT INTO acounts(balance)
VALUES (5000000),
       (3000000),
       (7000000),
       (1000000),
       (2500000),
       (9000000),
       (4000000),
       (6000000),
       (8000000),
       (2000000);
SELECT * FROM acounts;
-- kiểm tra số dư trc khi gửi tiền
SELECT * FROM acounts WHERE acount_id = 1;
-- Cộng 1000000 vào tài khoản
START TRANSACTION;
    UPDATE acounts
    SET balance = balance + 1000000
    WHERE acount_id = 1;
COMMIT ;
-- kiểm tra số dư sau khi gửi tiền
SELECT * FROM acounts WHERE acount_id = 1;
