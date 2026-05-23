-- ============================================================
-- 01_EDA.SQL — Khám phá & Chẩn đoán dữ liệu
-- ============================================================

-- 1.1 Kiểm tra NULL ở các cột quan trọng
SELECT
    COUNT(*)                                                     AS total_customers,
    SUM(CASE WHEN first_name   IS NULL THEN 1 ELSE 0 END)        AS null_firstname,
    SUM(CASE WHEN email        IS NULL THEN 1 ELSE 0 END)        AS null_email,
    SUM(CASE WHEN phone_number IS NULL THEN 1 ELSE 0 END)        AS null_phone
FROM customers;

-- 1.2 Kiểm tra duplicate email
SELECT email, COUNT(*) AS dup_count
FROM customers
GROUP BY email
HAVING COUNT(*) > 1;

-- 1.3 Kiểm tra orders không có customer tương ứng
-- Nếu có → dữ liệu bị lỗi khi import, cần xử lý trước khi JOIN
SELECT COUNT(*) AS orphan_orders
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- 1.4 Kiểm tra giá trị âm hoặc bất thường trong payment
SELECT
    MIN(amount)                                    AS min_amount,
    MAX(amount)                                    AS max_amount,
    AVG(amount)                                    AS avg_amount,
    COUNT(CASE WHEN amount <= 0 THEN 1 END)        AS invalid_amount
FROM payment;

-- 1.5 Xác nhận range ngày dữ liệu
-- Quan trọng để định nghĩa "ngày cuối" cho churn cutoff
SELECT
    MIN(order_date)                                 AS first_order_date,
    MAX(order_date)                                 AS last_order_date,
    DATEDIFF(MAX(order_date), MIN(order_date))      AS date_span_days
FROM orders;

-- 1.6 Kiểm tra transaction_status hợp lệ
SELECT transaction_status, COUNT(*) AS cnt
FROM payment
GROUP BY transaction_status;

-- 1.7 Kiểm tra shipment_status hợp lệ
SELECT shipment_status, COUNT(*) AS cnt
FROM shipments
GROUP BY shipment_status;

-- 1.8 Kiểm tra review rating ngoài thang 1-5
SELECT rating, COUNT(*) AS cnt
FROM reviews
GROUP BY rating
ORDER BY rating;

-- 1.13 Summary: tổng hợp vấn đề tìm thấy
-- Chạy cuối bước EDA để có cái nhìn tổng trước khi cleaning
SELECT
    'customers'     AS table_name,
    COUNT(*)        AS total_rows,
    SUM(
        CASE
            WHEN first_name IS NULL OR email IS NULL THEN 1 ELSE 0
        END)        AS rows_with_null
FROM customers
UNION ALL
SELECT 'orders',    COUNT(*), SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END)         FROM orders
UNION ALL
SELECT 'payment',   COUNT(*), SUM(CASE WHEN amount <= 0 THEN 1 ELSE 0 END)                 FROM payment
UNION ALL
SELECT 'shipments', COUNT(*), SUM(CASE WHEN shipment_status IS NULL THEN 1 ELSE 0 END)     FROM shipments
UNION ALL
SELECT 'products',  COUNT(*), SUM(CASE WHEN price IS NULL OR price <= 0 THEN 1 ELSE 0 END) FROM products;
