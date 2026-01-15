USE session11_db;
-- Ex4:
-- Tạo procedure transfer_money
DROP PROCEDURE IF EXISTS transfer_money;

DELIMITER //

CREATE PROCEDURE transfer_money(
    IN p_sender_id INT,
    IN p_receiver_id INT,
    IN p_amount DECIMAL(15, 2)
)
BEGIN
    -- Khai báo biến để kiểm tra số dư
    DECLARE v_sender_balance DECIMAL(15, 2);

    -- KHỐI XỬ LÝ LỖI TỰ ĐỘNG:
    -- Nếu gặp bất kỳ lỗi SQL nào (SQLEXCEPTION) -> Tự động Rollback
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            SELECT 'Giao dịch thất bại: Lỗi hệ thống SQL!' AS message;
        END;

    -- Bắt đầu giao dịch
    START TRANSACTION;

    -- 1. Kiểm tra số dư người gửi (Sử dụng "FOR UPDATE" để khóa dòng này lại tránh xung đột)
    SELECT balance INTO v_sender_balance
    FROM acounts
    WHERE acount_id = p_sender_id
        FOR UPDATE;

    -- 2. Kiểm tra điều kiện logic
    IF v_sender_balance >= p_amount THEN

        -- Trừ tiền người gửi
        UPDATE acounts
        SET balance = balance - p_amount
        WHERE acount_id = p_sender_id;

        -- Cộng tiền người nhận
        UPDATE acounts
        SET balance = balance + p_amount
        WHERE acount_id = p_receiver_id;

        -- Xác nhận thành công
        COMMIT;
        SELECT 'Chuyển tiền thành công!' AS message;

    ELSE
        -- Tiền không đủ -> Hủy
        ROLLBACK;
        SELECT 'Giao dịch thất bại: Số dư không đủ!' AS message;
    END IF;

END //

DELIMITER ;

-- Kiểm thử
-- Kiểm tra trước khi chuyển
SELECT * FROM acounts WHERE acount_id IN (4, 5);

-- Thực hiện chuyển 300.000
CALL transfer_money(4, 5, 3000000);

SELECT * FROM acounts WHERE acount_id IN (4, 5);