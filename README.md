# 🛒 E-Commerce Sales & Customer Analytics
### Customer Behavior & Operational Efficiency | 2023–2024

---

## 📌 Project Overview

Một nền tảng thương mại điện tử ghi nhận **10.000 khách hàng**, **15.000 đơn hàng** và **tổng doanh thu ~$42.5M** trong 13 tháng (11/2023 – 11/2024) — nhưng ẩn sau con số doanh thu ổn định là một vấn đề nghiêm trọng: **hơn 65% khách hàng không quay lại sau 90 ngày**, và phần lớn doanh thu ($31.2M) đang đến từ các nhóm khách hàng đang dần rời đi thay vì nhóm trung thành bền vững.

Project này áp dụng **RFM Segmentation, Cohort Retention Analysis và Operational Funnel** để trả lời: *Tại sao khách hàng không quay lại? Nhóm nào tạo ra giá trị cao nhất? Và đâu là điểm nghẽn vận hành đang làm mất doanh thu tiềm năng?*

Kết quả: xác định **$8M+ doanh thu có thể phục hồi** từ nhóm At Risk, phát hiện **20% đơn hàng thất bại ngay ở bước thanh toán**, và đề xuất bộ action cụ thể theo từng phân khúc khách hàng.

---

## 📸 Dashboard Preview

![Summary Page](visuals/summary_page.png)

> *Dashboard 5 trang xây dựng trên Power BI Desktop. Xem thêm screenshot đầy đủ trong thư mục `/visuals/`.*

---

## 🎯 Objectives

1. **Xác định xu hướng doanh thu** theo thời gian và danh mục sản phẩm dẫn đầu — liệu tăng trưởng có đến từ danh mục đúng không?
2. **Đo lường và định nghĩa churn** bằng ngưỡng 90 ngày, phân loại toàn bộ khách hàng thành Active / Churned.
3. **Phân khúc khách hàng theo RFM** để xác định ai đang tạo giá trị, ai đang rời đi — và ưu tiên nguồn lực theo đúng nhóm.
4. **Đánh giá Cohort Retention theo tháng ra nhập** — tỷ lệ quay lại có cải thiện theo thời gian không, hay vấn đề mang tính hệ thống?
5. **Phân tích phễu vận hành** (payment → shipment → delivered) — mất bao nhiêu % doanh thu ở mỗi bước?
6. **Đưa ra khuyến nghị hành động** có thể thực thi ngay, gắn với từng phân khúc và từng điểm nghẽn cụ thể.

---

## 🛠 Project Scope & Tools

| Thành phần | Chi tiết |
|---|---|
| **Data scope** | Tháng 11/2023 – Tháng 11/2024 (~13 tháng) |
| **Dataset** | 7 bảng: `customers`, `orders`, `order_items`, `products`, `payment`, `shipments`, `reviews` |
| **SQL** | MySQL — EDA, data cleaning, VIEW-based modeling, RFM scoring, Cohort analysis |
| **Visualization** | Power BI Desktop — DAX measures, Power Query, 5-trang dashboard |
| **Phương pháp** | RFM Segmentation (NTILE), Cohort Retention Matrix, Order Fulfillment Funnel |

---

## 📁 Repository Structure

```
ecommerce-customer-analytics/
├── queries/
│   ├── exploratory/
│   │   └── 01_exploration.sql        # EDA ban đầu: kiểm tra phân phối, null, duplicate
│   ├── transformations/
│   │   └── 02_cleaning.sql           # Làm sạch và chuẩn hóa dữ liệu
│   └── final/
│       └── 03_analysis.sql           # VIEW: customer_order_summary, vw_rfm_churn, vw_cohort_retention
├── reports/
│   └── E-Commerce_Sales_Customer_Analytics.pdf
├── visuals/
│   └── [screenshots từng trang dashboard]
├── docs/
│   └── data_dictionary.md
└── README.md
```

---

## 🔄 Data Workflow

```
Raw Data (MySQL — 7 bảng, ~15K orders)
    ↓
02_cleaning.sql     → Xử lý NULL, chuẩn hóa định dạng ngày/chuỗi, loại bỏ duplicate
    ↓
03_analysis.sql     → Tạo VIEW phân tích:
                       · customer_order_summary  (base metrics per customer)
                       · vw_rfm_churn            (RFM score + churn flag)
                       · vw_cohort_retention     (monthly cohort × retention rate)
    ↓
Power BI            → Import VIEW, xây dựng DimDate, DAX measures, 5-page dashboard
    ↓
Insights & Recommendations (README + PDF report)
```

---

## 🗂 Data Model & Schema

| Bảng | Mô tả | Số dòng (ước tính) |
|---|---|---|
| `customers` | Thông tin khách hàng | ~10.000 |
| `orders` | Đơn hàng | ~15.000 |
| `order_items` | Chi tiết sản phẩm trong từng đơn | ~94.000 units |
| `products` | Danh mục và thông tin sản phẩm | ~2.000 |
| `payment` | Giao dịch thanh toán theo đơn | ~15.000 |
| `shipments` | Trạng thái và thời gian giao hàng | ~15.000 |
| `reviews` | Đánh giá sản phẩm từ khách hàng | ~1.000 |

**Key joins:**
- `orders → payment` (order_id)
- `orders → order_items → products` (order_id, product_id)
- `customers → orders` (customer_id)

---

## 📊 Analysis & Metrics

### Churn Definition
- **Churned:** Không có đơn hàng trong **90 ngày** tính từ ngày đặt hàng gần nhất
- **Active:** Có đơn hàng trong vòng 90 ngày gần nhất (so với `MAX(order_date)` toàn hệ thống)
- *Lý do chọn 90 ngày: ngưỡng phổ biến với e-commerce đa danh mục; chi tiết xem phần Assumptions*

### RFM Scoring
- Dùng `NTILE(4)` để chia điểm 1–4 cho từng chiều **Recency / Frequency / Monetary**
- Recency: điểm cao = mua gần nhất → `ORDER BY recency_days DESC`
- Frequency & Monetary: điểm cao = nhiều/cao hơn → `ORDER BY ASC`
- **7 phân khúc:** Champions · Loyal Customers · Potential Loyalists · New Customers · At Risk · Can't Lose Them · Hibernating

### Cohort Retention
- Cohort xác định theo tháng đặt hàng đầu tiên: `DATE_FORMAT(MIN(order_date), '%Y-%m')`
- `months_since_first` tính bằng `TIMESTAMPDIFF(MONTH, first_order_month, order_month)`
- Retention rate = `active_customers / cohort_size × 100`

---

## 💡 Key Insights

### 1. Churn 65% — phần lớn khách hàng chỉ mua một hoặc hai lần
Chỉ **34.8%** (3.480 khách) còn Active tại thời điểm phân tích. Phân phối số lần mua gần như chia đôi: ~5.000 người mua đúng 1 lần, ~5.000 người mua 2 lần — không có nhóm mua 3 lần trở lên đáng kể. Retention gần như không tồn tại sau lần mua thứ 2, cho thấy thiếu cơ chế giữ chân hệ thống chứ không phải vấn đề sản phẩm.

### 2. $31M doanh thu đang "sống nhờ" nhóm khách hàng sắp rời đi
**At Risk ($19.6M)** và **Hibernating ($11.6M)** chiếm ~73% tổng doanh thu, trong khi Champions — nhóm lý tưởng — chỉ đóng góp $4.6M (~11%). Doanh nghiệp đang phụ thuộc vào khách hàng đang dần biến mất thay vì nhóm gắn bó lâu dài. Đây là rủi ro tăng trưởng trực tiếp, không phải cảnh báo mang tính dự báo.

### 3. Cohort Retention sụp đổ ngay tháng đầu tiên và không phục hồi
Mọi cohort đều rơi từ 100% (Month 0) xuống **5–9%** từ tháng thứ 1, sau đó duy trì ổn định ở mức đó. Không cohort nào cải thiện theo thời gian — kể cả các cohort mới hơn. Điều này loại trừ nguyên nhân mùa vụ và chỉ ra vấn đề cơ cấu: không có onboarding flow, email remarketing, hay loyalty mechanism nào đủ hiệu quả để giữ khách sau lần mua đầu.

### 4. Electronics dẫn đầu doanh thu nhưng có rating thấp nhất — tín hiệu churn ẩn
Electronics đạt **$15.2M (36% doanh thu)** và 34K units bán ra — cao nhất tất cả danh mục. Tuy nhiên, rating trung bình của danh mục này thấp hơn đáng kể so với Home & Kitchen (Food Processor: 4.5 sao). Doanh thu cao + satisfaction thấp = nhóm khách hàng Electronics có nguy cơ không quay lại cao nhất, và điều này chưa được phản ánh vào churn metric hiện tại.

### 5. Phễu thanh toán làm mất 20% doanh thu tiềm năng trước khi đơn được xử lý
Trong 15.000 đơn tạo, chỉ **12.000 (~80%) hoàn thành thanh toán** — tức 3.000 đơn thất bại trước khi vào hệ thống xử lý. Sau thanh toán, 71.4% chuyển sang giao hàng và 35.8% giao thành công đến tay khách. Mỗi điểm rơi trong phễu này là doanh thu không được ghi nhận, chưa kể chi phí acquisition đã bỏ ra để có đơn đó.

### 6. Top 20% khách hàng tạo ra 43% doanh thu — cao hơn dự kiến so với Pareto
Nhóm top 20% ($18.4M) so với bottom 80% ($24.1M): tỷ lệ 43% tiệm cận nguyên tắc Pareto. Với nguồn lực chăm sóc khách hàng có hạn, tập trung vào nhóm này sẽ cho ROI cao hơn đáng kể so với chiến lược giữ chân đồng đều toàn bộ tệp.

---

## ✅ Recommendations

### 🎯 Retention & Win-Back

| Nhóm | Insight dẫn đến đề xuất | Hành động cụ thể | Ưu tiên |
|---|---|---|---|
| **At Risk** (3.4K khách, $19.6M) | Recency cao nhưng lịch sử chi tiêu tốt — còn khả năng phục hồi nếu tiếp cận đúng thời điểm | Triển khai win-back email trong ngày 60–80 sau lần mua cuối, ưu đãi cá nhân hóa theo danh mục đã mua; ưu tiên sub-group monetary cao để tối đa ROI | 🔴 Cao nhất |
| **Cohort Month 0→1 drop-off** | 90%+ khách rời đi sau lần mua đầu vì không có cơ chế giữ chân | Thiết kế onboarding flow: email cảm ơn + gợi ý sản phẩm liên quan + ưu đãi mua lần 2 trong 30 ngày đầu | 🔴 Cao |
| **Hibernating** (4.1K khách, $11.6M) | Đã lâu không mua nhưng từng có giá trị — chi phí reactivation thấp hơn acquisition | Reactivation campaign: discount + social proof (trending products); giới hạn 2 lần tiếp cận, dừng nếu không phản hồi để tối ưu chi phí | 🟠 Cao |
| **Champions** (817 khách, $4.6M) | Nhóm nhỏ nhưng LTV cao — chi phí giữ chân thấp hơn nhiều so với acquisition tương đương | Xây dựng loyalty tier: early access, free shipping, birthday offer | 🟡 Trung bình |

### ⚙️ Operational Improvement

| Vấn đề | Nguyên nhân nghi ngờ | Hành động | Team |
|---|---|---|---|
| **20% failed payment** | Phương thức thanh toán không phù hợp hoặc lỗi UX tại checkout | Audit payment method có tỷ lệ fail cao nhất; thêm retry flow và alternative options (ví điện tử, BNPL) | Product / Payment |
| **Electronics rating thấp** | Mô tả sản phẩm không khớp thực tế hoặc vấn đề đóng gói/vận chuyển | Review sản phẩm có rating ≤ 2.5: kiểm tra mô tả, hình ảnh, quy trình đóng gói | Category Management |
| **Delivered rate 35.8%** | Có thể là data cutoff issue hoặc bottleneck thực tại khâu last-mile | Đối chiếu với warehouse logs; thiết lập SLA Shipped → Delivered theo khu vực | Logistics / Ops |

---

## ⚠️ Assumptions & Limitations

**Assumptions:**
- **Ngưỡng churn 90 ngày** là chuẩn phổ biến với e-commerce đa danh mục. Tuy nhiên Electronics (chu kỳ mua dài) và FMCG (chu kỳ mua ngắn) có thể cần ngưỡng khác nhau — đây là điểm cần validate với business nếu phân tích sâu theo danh mục.
- **Tháng 11/2024 là partial data** (chưa đủ 30 ngày tại thời điểm cắt) — cohort tháng này không dùng để kết luận xu hướng.
- **RFM dùng NTILE(4)**: điểm phân vị theo phân phối thực tế của dataset, không phải ngưỡng tuyệt đối cố định — kết quả phân khúc có thể thay đổi nếu dataset mở rộng.

**Limitations:**
- **Không có dữ liệu acquisition channel**: không thể xác định kênh nào (organic, paid, referral) mang lại khách hàng có LTV cao hơn — đây là missing piece quan trọng để đánh giá ROI marketing.
- **Review count quá thấp**: ~1.000 reviews cho ~94.000 units sold (~1%) — rating trung bình theo danh mục có thể không đại diện cho mức độ hài lòng thực sự.
- **Không có customer support data**: không thể liên kết trải nghiệm dịch vụ (ticket, complaint) với churn — bỏ sót một chiều phân tích có thể quan trọng.
- **Không có industry benchmark**: các tỷ lệ churn, retention, RFM được đánh giá tương đối trong nội bộ dataset, không có cơ sở so sánh với thị trường.

---

## 🚀 Future Enhancements

- [ ] **Customer Lifetime Value (CLV) prediction** — xây dựng model dự báo bằng Python (BG/NBD hoặc Pareto/NBD)
- [ ] **Product affinity / basket analysis** — sản phẩm nào thường được mua cùng nhau → gợi ý cross-sell
- [ ] **Churn prediction model** — phân tích theo đặc điểm: category, payment method, region
- [ ] **A/B test framework** — thiết kế chuẩn để đo hiệu quả win-back và onboarding campaign

---

## 📦 Deliverables

- [x] `03_analysis.sql` — EDA, VIEW RFM, Cohort Retention
- [x] Dataset gốc: [Online Shop 2024](https://www.kaggle.com/datasets/marthadimgba/online-shop-2024) — Kaggle, License: Apache 2.0 
8 bảng, 44 cột: orders, customers, products, order_items, suppliers, reviews, payments, shipments
- [x] Power BI Dashboard (5 trang): Summary · Overview · Customer Behavior · RFM & Retention · Operations
- [x] PDF export dashboard (`reports/`)
- [x] README với full insights & recommendations

---

## 👤 Author

**Phan Ngoc Kim Thoa**
- 📧 thoaphan2921@gmail.com
- 💼 [LinkedIn](https://www.linkedin.com/in/thoangoc2906)
- 🐙 [GitHub](https://github.com/thoangoc2921)

---

*Case study phân tích dữ liệu thực chiến — SQL + Power BI cho bài toán Customer Analytics trong thương mại điện tử.*
