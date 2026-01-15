
use session11_db ;

-- Tạo 2 bảng products và orders

CREATE TABLE products (
                          id INT AUTO_INCREMENT PRIMARY KEY,
                          product_name VARCHAR(100),
                          price DECIMAL(10, 2),
                          stock INT
);

-- Setup bảng Orders
CREATE TABLE orders (
                        id INT AUTO_INCREMENT PRIMARY KEY,
                        product_id INT,
                        quantity INT,
                        total_price DECIMAL(10, 2),
                        order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
                        FOREIGN KEY (product_id) REFERENCES products(id)
);

-- Thêm sản phẩm mẫu: Kho có 10 cái
INSERT INTO products (product_name, price, stock)
VALUES ('Laptop Gaming', 20000000, 10);


-- Tạo procedure place_order
DROP PROCEDURE IF EXISTS place_order;

DELIMITER //

CREATE PROCEDURE place_order(
    IN p_product_id INT,
    IN p_quantity INT
)
BEGIN
    DECLARE v_stock INT;
    DECLARE v_price DECIMAL(10, 2);

    -- Khai báo Handler: Gặp lỗi hệ thống thì Rollback ngay
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            SELECT 'Lỗi hệ thống! Đã rollback.' AS message;
        END;

    -- Bắt đầu giao dịch
    START TRANSACTION;

    -- 1. Lấy thông tin tồn kho và giá hiện tại (Khóa dòng này lại để tránh xung đột)
    SELECT stock, price INTO v_stock, v_price
    FROM products
    WHERE id = p_product_id
        FOR UPDATE; --  sử dụng FOR UPDATE, các hàng được chọn sẽ bị khóa, ngăn không cho các giao dịch khác thay đổi hoặc xóa chúng cho đến khi giao dịch hiện tại được commit hoặc rollback.

    -- 2. Kiểm tra điều kiện
    IF v_stock >= p_quantity THEN

        -- Bước A: Trừ tồn kho
        UPDATE products
        SET stock = stock - p_quantity
        WHERE id = p_product_id;

        -- Bước B: Tạo đơn hàng
        INSERT INTO orders (product_id, quantity, total_price)
        VALUES (p_product_id, p_quantity, v_price * p_quantity);

        -- Bước C: Chốt giao dịch
        COMMIT;
        SELECT 'Đặt hàng thành công!' AS message;

    ELSE
        -- Hàng không đủ -> Hủy
        ROLLBACK;
        SELECT 'Đặt hàng thất bại: Kho không đủ hàng!' AS message;
    END IF;

END //

DELIMITER ;


-- Kiểm tra trước khi mua
SELECT * FROM products;

-- TEST 1: Mua hợp lệ (Mua 2 cái)
CALL place_order(1, 2);
-- Kết quả mong đợi: Stock còn 8, Orders có 1 dòng.

-- TEST 2: Mua quá số lượng (Mua 20 cái - trong khi kho chỉ còn 8)
CALL place_order(1, 20);
-- Kết quả mong đợi: Báo lỗi, Stock vẫn là 8, Orders không tăng thêm.

-- Xem kết quả cuối cùng
SELECT * FROM products;
SELECT * FROM orders;
