-- ============================================================
-- 02_CLEANING.SQL — Chuẩn hóa & Làm sạch dữ liệu
-- Xử lý các vấn đề đã phát hiện ở 01_eda.sql
-- ============================================================

-- 1.9 Xem trước dữ liệu sau khi làm sạch chuỗi — bảng customers

SELECT
    customer_id,
    TRIM(first_name)                        AS first_name_clean,
    TRIM(last_name)                         AS last_name_clean,
    TRIM(email)                             AS email_clean,
    COALESCE(TRIM(phone_number), 'Unknown') AS phone_clean,
    TRIM(address)                           AS address_clean
FROM customers
LIMIT 20;

-- 1.10 Kiểm tra products — CAST price sang đúng kiểu + COALESCE supplier
SELECT
    product_id,
    TRIM(product_name)                       AS product_name_clean,
    TRIM(category)                           AS category_clean,
    CAST(price AS DECIMAL(10,2))             AS price_cast,
    COALESCE(supplier_id, 0)                 AS supplier_id_clean
FROM products
LIMIT 20;

-- 1.11 Kiểm tra order_items — CAST quantity và price
-- Nếu có kết quả → đây là outlier cần xử lý trước khi tính revenue
SELECT
    order_item_id,
    order_id,
    product_id,
    CAST(quantity AS UNSIGNED)               AS quantity_cast,
    CAST(price_at_purchase AS DECIMAL(10,2)) AS price_cast
FROM order_items
WHERE quantity <= 0 OR price_at_purchase <= 0;

-- 1.12 Chuẩn hóa transaction_status
-- Phòng trường hợp có khoảng trắng hoặc case không đồng nhất
SELECT DISTINCT
    transaction_status,
    TRIM(UPPER(transaction_status))          AS status_clean
FROM payment;
