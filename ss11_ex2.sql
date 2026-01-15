USE session11_db;
-- Ex2:
-- Tạo Stored Procedure withdraw_money
DELIMITER $$
CREATE PROCEDURE withdraw_money (
    IN p_account_id INT,
    IN p_amount DECIMAL(10,2)
)
BEGIN
    DECLARE current_balance DECIMAL(10,2);

    START TRANSACTION;
    -- Trừ tiền
    UPDATE acounts
    SET balance = balance - p_amount
    WHERE acount_id = p_account_id;
    -- Lấy số dư hiện tại
    SELECT balance
    INTO current_balance
    FROM acounts
    WHERE acount_id = p_account_id;
    -- Kiểm tra số dư
    IF current_balance < 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Số dư không đủ';
    ELSE
        COMMIT;
        SELECT 'Rút tiền thành công' AS message;
    END IF;
END$$
DELIMITER ;
SELECT * FROM acounts;
CALL withdraw_money(1,55000000);
CALL withdraw_money(1,100000);
SELECT * FROM acounts WHERE acount_id = 1;