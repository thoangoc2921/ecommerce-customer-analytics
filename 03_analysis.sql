--  ONLINE SHOP 2024 — PHÂN TÍCH DỮ LIỆU
--  Yêu cầu: chạy sau 02_cleaning.sql

-- PHẦN 1: TỔNG QUAN DỮ LIỆU (EDA)
-- ================================================================

-- Tổng số bản ghi mỗi bảng và tổng doanh thu đã thanh toán
SELECT
    (SELECT COUNT(*) FROM customers)                            AS total_customers,
    (SELECT COUNT(*) FROM orders)                               AS total_orders,
    (SELECT COUNT(*) FROM products)                             AS total_products,
    (SELECT ROUND(SUM(amount), 2) FROM payment
     WHERE transaction_status = 'Completed')                   AS total_revenue;

-- Số đơn và doanh thu từng tháng — xem xu hướng và mùa vụ
SELECT
    DATE_FORMAT(order_date, '%Y-%m')    AS order_month,
    COUNT(*)                            AS total_orders,
    ROUND(SUM(total_price), 2)          AS monthly_revenue
FROM orders
GROUP BY order_month
ORDER BY order_month;

-- Top 10 sản phẩm bán chạy theo doanh thu
SELECT
    p.product_name,
    p.category,
    SUM(oi.quantity)                                    AS units_sold,
    ROUND(SUM(oi.quantity * oi.price_at_purchase), 2)   AS revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.category
ORDER BY revenue DESC
LIMIT 10;

-- Doanh thu và số đơn theo từng category sản phẩm
SELECT
    p.category,
    COUNT(DISTINCT oi.order_id)                         AS total_orders,
    SUM(oi.quantity)                                    AS units_sold,
    ROUND(SUM(oi.quantity * oi.price_at_purchase), 2)   AS revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY revenue DESC;

-- Phân bố phương thức thanh toán — tỷ lệ sử dụng và giá trị trung bình
SELECT
    payment_method,
    COUNT(*)                                                    AS total_transactions,
    ROUND(SUM(amount), 2)                                       AS total_amount,
    ROUND(AVG(amount), 2)                                       AS avg_amount,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM payment), 2) AS pct_share
FROM payment
GROUP BY payment_method
ORDER BY total_transactions DESC;

-- Tỷ lệ trạng thái giao hàng — Delivered / Shipped / Pending / Cancelled
SELECT
    shipment_status,
    COUNT(*)                                                            AS cnt,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM shipments), 2)      AS pct
FROM shipments
GROUP BY shipment_status;

-- Rating trung bình theo từng category sản phẩm
SELECT
    p.category,
    ROUND(AVG(r.rating), 2) AS avg_rating,
    COUNT(r.review_id)      AS total_reviews
FROM reviews r
JOIN products p ON r.product_id = p.product_id
GROUP BY p.category
ORDER BY avg_rating DESC;

-- Phân phối số lần mua mỗi khách — xác định tỷ lệ one-time vs repeat buyers
SELECT
    order_count         AS times_purchased,
    COUNT(*)            AS num_customers
FROM (
    SELECT customer_id, COUNT(DISTINCT order_id) AS order_count
    FROM orders
    GROUP BY customer_id
) sub
GROUP BY order_count
ORDER BY order_count;


-- ================================================================
-- PHẦN 2: ĐỊNH NGHĨA CHURN VÀ GẮN NHÃN
-- ================================================================

-- VIEW này là nền tảng cho toàn bộ phân tích RFM, cohort và churn
CREATE OR REPLACE VIEW customer_order_summary AS
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    COUNT(DISTINCT o.order_id)      AS frequency,
    MAX(o.order_date)               AS last_order_date,
    ROUND(SUM(p.amount), 2)         AS monetary,
    DATEDIFF(
        (SELECT MAX(order_date) FROM orders),
        MAX(o.order_date)
    )                               AS recency_days,
    CASE
        WHEN DATEDIFF(
            (SELECT MAX(order_date) FROM orders),
            MAX(o.order_date)
        ) >= 90 THEN 'Churned'
        ELSE 'Active'
    END                             AS churn_status
FROM customers c
JOIN orders o  ON c.customer_id = o.customer_id
JOIN payment p ON o.order_id    = p.order_id
WHERE p.transaction_status = 'Completed'
GROUP BY c.customer_id, c.first_name, c.last_name, c.email;

-- Kiểm tra kết quả phân loại churn
SELECT
    churn_status,
    COUNT(*)                                        AS customer_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct,
    ROUND(AVG(monetary), 2)                         AS avg_spend,
    ROUND(AVG(frequency), 2)                        AS avg_orders,
    ROUND(AVG(recency_days), 0)                     AS avg_recency_days
FROM customer_order_summary
GROUP BY churn_status;

-- Số khách chưa từng đặt hàng
SELECT COUNT(*) AS never_purchased
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- ================================================================
-- PHẦN 3: RFM — PHÂN KHÚC KHÁCH HÀNG
-- ================================================================

-- View RFM + Segment cho Power BI
CREATE OR REPLACE VIEW vw_rfm_churn AS
WITH rfm_scored AS (
    SELECT
        customer_id, first_name, last_name, email,
        recency_days, frequency, monetary, churn_status,
        NTILE(4) OVER (ORDER BY recency_days DESC) AS r_score,
        NTILE(4) OVER (ORDER BY frequency ASC)     AS f_score,
        NTILE(4) OVER (ORDER BY monetary ASC)      AS m_score
    FROM customer_order_summary
)
SELECT *,
    (r_score + f_score + m_score) AS rfm_total,
    CONCAT(r_score, f_score, m_score) AS rfm_cell,
    CASE
        WHEN r_score = 4 AND f_score >= 3 AND m_score >= 3  THEN 'Champions'
        WHEN r_score >= 3 AND f_score >= 3                  THEN 'Loyal Customers'
        WHEN r_score >= 3 AND f_score <= 2                  THEN 'Potential Loyalists'
        WHEN r_score = 4 AND f_score = 1                    THEN 'New Customers'
        WHEN r_score <= 2 AND f_score >= 3 AND m_score >= 3 THEN 'At Risk'
        WHEN r_score = 1 AND f_score >= 3                   THEN 'Cant Lose Them'
        WHEN r_score <= 2 AND f_score <= 2                  THEN 'Hibernating'
        ELSE 'About to Sleep'
    END AS rfm_segment
FROM rfm_scored;

-- Kiểm tra ngay sau khi tạo
SELECT * FROM vw_rfm_churn;

-- ================================================================
-- PHẦN 4: COHORT ANALYSIS — RETENTION RATE
-- ================================================================

-- View Cohort Retention cho Power BI (Matrix/Heatmap)
CREATE OR REPLACE VIEW vw_cohort_retention AS
WITH first_order AS (
    SELECT customer_id,
           DATE_FORMAT(MIN(order_date), '%Y-%m') AS cohort_month
    FROM orders
    GROUP BY customer_id
),
cohort_size AS (
    SELECT cohort_month, COUNT(DISTINCT customer_id) AS cohort_customers
    FROM first_order
    GROUP BY cohort_month
),
cohort_activity AS (
    SELECT 
        f.cohort_month,
        TIMESTAMPDIFF(
            MONTH,
            STR_TO_DATE(CONCAT(f.cohort_month, '-01'), '%Y-%m-%d'),
            STR_TO_DATE(CONCAT(DATE_FORMAT(o.order_date, '%Y-%m'), '-01'), '%Y-%m-%d')
        ) AS months_since_first,
        COUNT(DISTINCT o.customer_id) AS active_customers
    FROM orders o 
    JOIN first_order f ON o.customer_id = f.customer_id
    GROUP BY f.cohort_month, months_since_first
)
SELECT
    ca.cohort_month,
    cs.cohort_customers,
    ca.months_since_first,
    ca.active_customers,
    ROUND(ca.active_customers * 100.0 / cs.cohort_customers, 1) AS retention_rate_pct
FROM cohort_activity ca
JOIN cohort_size cs ON ca.cohort_month = cs.cohort_month
ORDER BY ca.cohort_month, ca.months_since_first;

-- Kiểm tra ngay sau khi tạo
SELECT * FROM vw_cohort_retention;
