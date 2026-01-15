USE session11_db;
-- 2. Setup bảng Transactions (Yêu cầu của bài)
CREATE TABLE transactions (
                              transaction_id INT AUTO_INCREMENT PRIMARY KEY,
                              account_id INT,
                              amount DECIMAL(15, 2),
                              log_message VARCHAR(255),
                              transaction_date DATETIME DEFAULT CURRENT_TIMESTAMP,
                              FOREIGN KEY (account_id) REFERENCES acounts(acount_id)
);

-- Tạo procedure deposit_with_logging

DELIMITER //

CREATE PROCEDURE deposit_with_logging(
    IN p_account_id INT,
    IN p_amount DECIMAL(15, 2)
)
BEGIN
    -- Khai báo biến xử lý lỗi: Nếu gặp lỗi SQL (SQLEXCEPTION) thì Rollback
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            SELECT 'Đã xảy ra lỗi hệ thống! Giao dịch bị hủy.' AS status;
        END;

    -- Bắt đầu giao dịch
    START TRANSACTION;

    -- Thao tác 1: Cộng tiền
    UPDATE acounts
    SET balance = balance + p_amount
    WHERE acount_id = p_account_id;

    -- Thao tác 2: Ghi lịch sử
    INSERT INTO transactions(account_id, amount, log_message)
    VALUES (p_account_id, p_amount, 'Nạp tiền vào tài khoản');

    -- Nếu chạy đến đây mà không lỗi gì thì Commit
    COMMIT;

    SELECT 'Nạp tiền và ghi log thành công!' AS status;

END //

DELIMITER ;

-- Kiểm thử
-- Kiểm tra trước khi nạp
SELECT * FROM acounts WHERE acount_id = 3;
SELECT * FROM transactions;

-- Thực hiện nạp 1.000.000
CALL deposit_with_logging(3, 1000000);

-- Kiểm tra kết quả sau khi nạp (Mong đợi: Balance = 1tr, có 1 dòng log)
SELECT * FROM acounts WHERE acount_id = 3;
SELECT * FROM transactions;