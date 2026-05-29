# 🛒 E-Commerce Sales & Customer Analytics
### Customer Behavior & Operational Efficiency | 2023–2024

---

## 1. Project Overview

An e-commerce platform recorded **10,000 customers**, **15,000 orders**, and **total revenue of approximately $42.5M** over 13 months (November 2023 to November 2024). However, behind the stable revenue figures lies a critical problem: **more than 65% of customers did not return within 90 days**, and the majority of revenue ($31.2M) is coming from customer groups that are gradually leaving rather than a sustainable loyal base.

This project applies **RFM Segmentation, Cohort Retention Analysis, and an Operational Funnel** to answer: *Why are customers not coming back? Which customer groups generate the highest value? And where are the operational bottlenecks creating the risk of losing potential revenue?*

The results identify **$8M+ in recoverable revenue** from at-risk customer groups, reveal that **20% of orders fail at the payment step**, and propose concrete action plans tailored to each customer segment.

---

## 2. Objectives

1. **Identify revenue trends** over time and by product category to determine whether growth is coming from the right categories.
2. **Define and measure customer churn rate** using a 90-day threshold, classifying all customers as either Active or Churned (customers who have not returned within the defined inactivity window).
3. **Perform RFM Segmentation** to identify which customers generate the highest value and which are at risk of leaving, enabling better resource allocation across customer groups.
4. **Conduct cohort-based retention analysis by first purchase month** to assess whether retention rates are improving over time or whether the problem is structural.
5. **Analyze the operational funnel** (Payment, Shipping, and Delivery) to identify the proportion of revenue lost at each stage.
6. **Provide actionable recommendations** tailored to each customer segment and specific operational bottlenecks for immediate implementation.

---

## 3. Project Scope & Tools

| Component | Details |
|---|---|
| **Data scope** | November 2023 to November 2024 (approximately 13 months) |
| **Dataset** | 8 tables, 44 columns: `customers`, `orders`, `order_items`, `products`, `payment`, `shipments`, `reviews`, `suppliers` |
| **SQL** | MySQL, covering EDA, data cleaning, VIEW-based modeling, RFM scoring, and Cohort analysis |
| **Visualization** | Power BI Desktop, including DAX measures, Power Query, and a 6-page dashboard |
| **Methods** | RFM Segmentation (NTILE), Cohort Retention Matrix, Order Fulfillment Funnel |

---

## 4. Repository Structure

```
ecommerce-customer-analytics/
├── queries/
│   ├── 01_eda.sql              # Data exploration & diagnosis: null, duplicate, outlier, range checks
│   ├── 02_cleaning.sql         # Standardization & cleaning: TRIM, CAST, COALESCE
│   └── 03_analysis.sql         # Consolidated EDA, VIEWs: customer_order_summary, vw_rfm_churn, vw_cohort_retention
├── reports/
│   └── E-Commerce_Sales_Customer_Analytics.pdf
├── visuals/
│   └── [dashboard page screenshots]
└── README.md
```

---

## 5. Data Workflow

```
Raw Data
└── Online Shop 2024 — Kaggle (8 tables, 44 columns)
        │
        ▼
[01_eda.sql]
    Check for NULLs, duplicate emails, orphan orders
    Check for abnormal values (negative payment amounts, ratings outside 1–5)
    Confirm date range of data and define churn cutoff
    Full issue summary across all tables
        │
        ▼
[02_cleaning.sql]
    TRIM whitespace: customers, products
    CAST data types: price to DECIMAL, quantity to UNSIGNED
    COALESCE to handle NULLs: phone_number set to 'Unknown', supplier_id set to 0
    Standardize transaction_status: TRIM combined with UPPER
        │
        ▼
[03_analysis.sql]
    Consolidated EDA: monthly revenue, top products, payment distribution, rating by category
    VIEW customer_order_summary  → base metrics per customer (frequency, monetary, recency, activity status)
    VIEW vw_rfm_churn            → RFM score (NTILE 4) combined with 7 customer segments
    VIEW vw_cohort_retention     → monthly cohort matrix with retention rate
        │
        ▼
Power BI
    Import 3 VIEWs from MySQL
    Build DAX measures: Approval Rate, YoY, Churn %
    6-page dashboard: Summary, Overview, Customer Behavior, RFM & Retention, Product Performance, Operations
        │
        ▼
Insights & Recommendations
```

---

## 6. Data Model & Schema

**Source:** [Online Shop 2024](https://www.kaggle.com/datasets/marthadimgba/online-shop-2024) on Kaggle, License: Apache 2.0

| Table | Description | Estimated Rows |
|---|---|---|
| `customers` | Customer information | ~10,000 |
| `orders` | Orders | ~15,000 |
| `order_items` | Product details within each order | ~94,000 units |
| `products` | Product catalog and information | ~2,000 |
| `payment` | Payment transactions per order | ~15,000 |
| `shipments` | Shipment status and timing | ~15,000 |
| `reviews` | Customer product reviews | ~1,000 |

**Key joins:**
- `orders → payment` (order_id)
- `orders → order_items → products` (order_id, product_id)
- `customers → orders` (customer_id)

---

## 7. ERD

```
customers ──< orders ──< order_items >── products >── suppliers
                 │
                 ├──< payment
                 └──< shipments

customers ──< reviews >── products
```

---

## 8. Analysis & Metrics

### Churn Definition
- **Churned:** No order placed within **90 days** from the most recent order date
- **Active:** At least one order placed within the last 90 days, measured against `MAX(order_date)` across the entire system
- *Rationale for the 90-day threshold: this is the common standard for multi-category e-commerce; see the Assumptions section for details*

### RFM Scoring
- `NTILE(4)` is used to assign scores from 1 to 4 for each of the three dimensions: **Recency, Frequency, and Monetary**
- Recency: higher score means more recent purchase, ordered by `recency_days DESC`
- Frequency and Monetary: higher score means higher values, ordered `ASC`
- **7 segments:** Highest-value customers (Champions), Repeat customers (Loyal Customers), Customers with loyalty potential (Potential Loyalists), First-time buyers (New Customers), Previously high-value customers showing disengagement (At Risk), High-spend inactive customers (Can't Lose Them), and Long-term inactive customers (Hibernating)

### Cohort Retention
- Cohorts are defined by the month of first order: `DATE_FORMAT(MIN(order_date), '%Y-%m')`
- `months_since_first` is calculated using `TIMESTAMPDIFF(MONTH, first_order_month, order_month)`
- Retention rate equals `active_customers / cohort_size × 100`

---

## 9. Key Insights

### 1. 65% Churn Rate, as most customers purchase only once or twice
Only **34.8%** (3,480 customers) remain active at the time of analysis. The purchase frequency distribution is nearly split in half: approximately 5,000 customers purchased exactly once and approximately 5,000 purchased twice, with no meaningful group purchasing three or more times. Retention effectively does not exist beyond the second purchase, pointing to an absence of systematic retention mechanisms rather than a product quality issue.

### 2. $31M in revenue is dependent on customer groups that are already leaving
**Previously high-value customers showing disengagement ($19.6M)** and **long-term inactive customers ($11.6M)** account for approximately 73% of total revenue, while highest-value customers (Champions), the most sustainable group, contribute only $4.6M (approximately 11%). The business is relying on customers who are gradually disappearing rather than on a loyal, durable base. This is a direct growth risk, not a forward-looking warning.

### 3. Cohort retention collapses in the first month and does not recover
Every cohort drops from 100% (Month 0) to **5–9%** by Month 1, then stabilizes at that level. No cohort improves over time, including more recent ones. This rules out seasonality as the cause and points to a structural problem: there is no onboarding flow, email remarketing, or loyalty mechanism effective enough to retain customers after their first purchase.

### 4. Electronics leads in revenue but has the lowest rating, indicating a hidden churn signal
Electronics generates **$15.2M (36% of revenue)** and 34K units sold, the highest of all categories. However, the average rating for this category is notably lower than Home & Kitchen (Food Processor: 4.5 stars). High revenue combined with low satisfaction means Electronics customers carry the highest risk of not returning.

### 5. The payment funnel loses 20% of potential revenue before orders are processed
Of the 15,000 orders created, only **12,000 (approximately 80%) completed payment**, meaning 3,000 orders failed before entering the fulfillment pipeline. After payment, 71.4% proceed to shipping and 35.8% are successfully delivered. Each drop-off point in this funnel represents unrecorded revenue, on top of the acquisition cost already spent to generate those orders.

### 6. The top 20% of customers generate 43% of revenue, approaching the Pareto principle
The top 20% ($18.4M) compared to the bottom 80% ($24.1M) gives a ratio of 43%, which is close to the Pareto principle. Given limited customer service resources, focusing on this group will yield a significantly higher return on investment than applying a uniform retention strategy across the entire customer base.

---

## 10. Recommendations

### 🎯 Retention & Win-Back

| Segment | Insight driving the recommendation | Specific action | Priority |
|---|---|---|---|
| **Previously high-value customers showing disengagement** (3.4K customers, $19.6M) | Recency is high but spending history is strong, so recovery is still feasible with the right timing | Deploy win-back emails between days 60 and 80 after the last purchase, with personalized offers based on previously purchased categories; prioritize the high-monetary sub-group to maximize ROI | 🔴 Highest |
| **Cohort Month 0 to Month 1 drop-off** | More than 90% of customers leave after the first purchase because there is no retention mechanism in place | Design an onboarding flow: thank-you email combined with related product suggestions and a second-purchase incentive within the first 30 days | 🔴 High |
| **Long-term inactive customers** (4.1K customers, $11.6M) | Inactive for a long time but previously valuable, so reactivation cost is lower than acquiring equivalent new customers | Reactivation campaign with a discount combined with social proof (trending products); limit to 2 outreach attempts and stop if there is no response, to optimize cost | 🟠 High |
| **Highest-value customers** (817 customers, $4.6M) | A small group but with high lifetime value, and retention cost is significantly lower than acquiring equivalent new customers | Build a loyalty tier with early access, free shipping, and a birthday offer | 🟡 Medium |

### ⚙️ Operational Improvement

| Issue | Suspected cause | Action | Team |
|---|---|---|---|
| **20% failed payments** | Unsuitable payment methods or UX friction at checkout | Audit the payment methods with the highest failure rates; add a retry flow and alternative options such as e-wallets and BNPL | Product and Payment |
| **Low Electronics rating** | Product descriptions do not match reality, or packaging and shipping issues | Review products with ratings of 2.5 or below: check descriptions, images, and packaging processes | Category Management |
| **35.8% delivery completion rate** | Possibly a data cutoff issue or a real bottleneck in last-mile delivery | Cross-reference with warehouse logs; establish SLAs for Shipped to Delivered by region | Logistics and Operations |

---

## 11. Assumptions & Limitations

**Assumptions:**
- **The 90-day churn threshold** is the common standard for multi-category e-commerce. However, Electronics (long purchase cycles) and FMCG (short purchase cycles) may each require a different threshold. This is a point that should be validated with the business if deeper category-level analysis is needed.
- **November 2024 contains partial data** (fewer than 30 days available at the time of data extraction), so the cohort for that month is excluded from trend conclusions.
- **RFM uses NTILE(4)**: scores are based on percentile distribution within the actual dataset rather than fixed absolute thresholds, so segment results may shift if the dataset is expanded.

**Limitations:**
- **No acquisition channel data available**: it is not possible to determine which channel (organic, paid, or referral) brings in customers with higher lifetime value, which is an important missing piece for evaluating marketing ROI.
- **Review count is very low**: approximately 1,000 reviews across roughly 94,000 units sold (approximately 1%), so average ratings by category may not accurately represent actual customer satisfaction.
- **No customer support data available**: it is not possible to link service experience (tickets and complaints) to churn, which means one potentially important analytical dimension is missing.
- **No industry benchmark available**: churn rates, retention rates, and RFM results are evaluated relative to this dataset only, without an external market reference for comparison.

---

## 12. Future Enhancements

- [ ] **Customer Lifetime Value (CLV) prediction**: build a predictive model in Python using BG/NBD or Pareto/NBD
- [ ] **Product affinity and basket analysis**: identify which products are frequently purchased together to support cross-sell recommendations
- [ ] **Churn prediction model**: analyze by customer characteristics including category, payment method, and region
- [ ] **A/B test framework**: design a standardized structure to measure the effectiveness of win-back and onboarding campaigns

---

## 13. Deliverables

- ✅ `queries/01_eda.sql` — Data exploration & diagnosis: null, duplicate, outlier, and range checks
- ✅ `queries/02_cleaning.sql` — Standardization & cleaning: TRIM, CAST, COALESCE
- ✅ `queries/03_analysis.sql` — Consolidated EDA, RFM VIEW, Cohort Retention VIEW
- 📎 Original dataset: [Online Shop 2024](https://www.kaggle.com/datasets/marthadimgba/online-shop-2024) on Kaggle, License: Apache 2.0, containing 8 tables and 44 columns
- ✅ Power BI Dashboard (6 pages): Summary, Overview, Customer Behavior, RFM & Retention, Product Performance, Operations
- ✅ `reports/E-Commerce_Sales_Customer_Analytics.pdf` — Dashboard export
- ✅ README with full insights and recommendations

---

## 14. Dashboard Preview

### Page 1 — Summary
![Summary](visuals/summary_page.png)

### Page 2 — Overview
![Overview](visuals/overview_page.png)

### Page 3 — Customer Behavior
![Customer Behavior](visuals/customer_behavior_page.png)

### Page 4 — RFM & Retention
![RFM & Retention](visuals/rfm_retention_page.png)

### Page 5 — Product Performance
![Product Performance](visuals/product_performance_page.png)

### Page 6 — Operations
![Operations](visuals/operations_page.png)

---

## 15. Author

**Phan Ngoc Kim Thoa**
- 📧 thoaphan2921@gmail.com
- 💼 [LinkedIn](https://www.linkedin.com/in/thoangoc2906)
- 🐙 [GitHub](https://github.com/thoangoc2921)

---

*A hands-on data analytics case study applying SQL and Power BI to customer analytics in e-commerce.*
