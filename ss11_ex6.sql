USE session11_db;
-- Ex6:

-- Thêm cột status vào bảng orders cũ
ALTER TABLE orders
    ADD COLUMN status VARCHAR(20) DEFAULT 'Completed';

-- (Tùy chọn) Reset lại dữ liệu nếu cần để test cho sạch
#     DELETE FROM orders;
# UPDATE products SET stock = 10 WHERE id = 1;
# TRUNCATE TABLE orders;

-- Tiến hành tạo procedure
DROP PROCEDURE IF EXISTS cancel_order;

DELIMITER //

CREATE PROCEDURE cancel_order(
    IN p_order_id INT
)
BEGIN
    -- Khai báo biến để lưu thông tin đơn hàng
    DECLARE v_product_id INT;
    DECLARE v_quantity INT;
    DECLARE v_current_status VARCHAR(20);

    -- Handler xử lý lỗi hệ thống
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            SELECT 'Lỗi hệ thống! Đã rollback.' AS message;
        END;

    -- Bắt đầu giao dịch
    START TRANSACTION;

    -- 1. Lấy thông tin đơn hàng (Khóa dòng để tránh tranh chấp)
    SELECT product_id, quantity, status
    INTO v_product_id, v_quantity, v_current_status
    FROM orders
    WHERE id = p_order_id
        FOR UPDATE;

    -- 2. Kiểm tra điều kiện
    IF v_product_id IS NULL THEN
        -- Không tìm thấy đơn hàng
        ROLLBACK;
        SELECT 'Đơn hàng không tồn tại!' AS message;

    ELSEIF v_current_status = 'Cancelled' THEN
        -- Đơn đã hủy rồi thì thôi
        ROLLBACK;
        SELECT 'Đơn hàng này đã bị hủy trước đó!' AS message;

    ELSE
        -- 3. Tiến hành hủy

        -- Bước A: Cập nhật trạng thái đơn hàng
        UPDATE orders
        SET status = 'Cancelled'
        WHERE id = p_order_id;

        -- Bước B: Hoàn trả tồn kho
        UPDATE products
        SET stock = stock + v_quantity
        WHERE id = v_product_id;

        -- Bước C: Xác nhận
        COMMIT;
        SELECT 'Hủy đơn hàng thành công! Đã hoàn tồn kho.' AS message;

    END IF;

END //

DELIMITER ;

-- Tiến hành kiểm tra
-- BƯỚC 1: Tạo tình huống (Đặt mua 3 Laptop)
-- Giả sử kho đang có 10, mua 3 -> Kho còn 7
CALL place_order(1, 1);

-- Kiểm tra xem đơn hàng vừa tạo ID là bao nhiêu (ví dụ ID = 1)
SELECT * FROM orders ORDER BY id DESC;
SELECT * FROM products WHERE id = 1; -- Mong đợi: Stock = 5

-- BƯỚC 2: Hủy đơn hàng vừa tạo (ID = 3)
CALL cancel_order(5);

-- BƯỚC 3: Kiểm tra kết quả
-- Mong đợi: Order status = 'Cancelled'
SELECT * FROM orders WHERE id = 3;

-- Mong đợi: Stock quay về 8
SELECT * FROM products WHERE id = 1;
