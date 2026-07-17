**📖 Project Overview**

This project focuses on analyzing e-commerce returns to identify the key factors driving product returns, revenue loss, and customer dissatisfaction. The analysis helps businesses understand return behavior and develop strategies to reduce return rates and improve profitability.

**The project follows a complete Data Analytics workflow**:

- Data Cleaning using Python
- Data Modeling & Normalization using MySQL
- Business Analysis using SQL
- Interactive Dashboard Development using Power BI

**🎯 Business Problem**

High product return rates can significantly impact revenue, operational efficiency, and customer satisfaction.

**This project aims to answer**:

- Why are customers returning products?
- Which products and categories have the highest return rates?
- Which regions generate the most returns?
- What is the financial impact of returns?
- How do delivery performance and payment methods affect returns?
- 
**🛠️ Tools & Technologies**
- Python (Pandas)
- MySQL
- Power BI
- DAX
- Canva
- 
**📂 Project Workflow**
**1️⃣ Data Cleaning (Python)**

**Performed data quality checks and preprocessing using Pandas:**

- Converted date columns to proper datetime format
- Handled missing values
- Checked duplicate records
- Validated return request dates
- Exported cleaned dataset for SQL analysis

**2️⃣ Database Design & Normalization (MySQL)**

- Created a normalized database structure to improve query performance and reduce redundancy.

**Customers Table**
- customer_id
- customer_age
- customer_gender
- region

**Products Table**
- product_id
- category
- price

**Orders Table**
- order_id
- customer_id
- product_id
- quantity
- discount
- payment_method
- order_date
- delivered_date
- total_amount
- shipping_cost
- profit_margin

**Returns Table**
- order_id
- returned
- request_date
- return_reason

**3️⃣ SQL Business Analysis**

- Performed comprehensive business analysis including:

- Product Analysis
- Highest Revenue Category
- Highest Profit Category
- Top Returned Products
- Return Rate by Category
- Revenue Contribution Analysis
- Customer Analysis
- Customer Revenue Analysis
- Customer Segmentation
- Top Customers by Revenue
- Revenue Per Customer
- Regional Analysis
- Revenue by Region
- Profit by Region
- Return Rate by Region
- Average Order Value by Region
- Delivery & Return Analysis
- Delivery Time Impact on Returns
- Top Return Reasons
- Revenue Loss Due to Returns
- Return Trends

**📊 Power BI Dashboard**
**Executive Overview**
- Total Revenue
- Total Profit
- Total Orders
- Total Returns
- Return Rate %
- Returned Revenue
- Average Delivery Days
  
**Return Analysis**
- Return Reasons Analysis
- Return Rate by Category
- Return Rate by Region
- Return Rate by Payment Method
- Top Returned Products
- Returned Revenue by Category
  
- **Product Analysis**
- Revenue by Category
- Profit by Category
- Top Revenue Products
- Top Returned Products
- Revenue Contribution Analysis

**Customer Analysis**
- Revenue by Gender
- Revenue by Age Group
- Top Customers by Revenue
- Customer Segmentation
- Revenue by Region

**Regional Analysis**
- Revenue by Region
- Profit by Region
- Orders by Region
- Return Rate by Region
- Average Order Value by Region

**📈 Key Insights**
Fashion category recorded the highest return rate.
"Not as Described" was the most common return reason.
East region generated the highest return rate.
Returns resulted in significant revenue loss.
Delivery delays showed moderate impact on return behavior.
A small group of customers contributed a large portion of revenue.

**🚀 Business Recommendations**
Improve product descriptions and images.
Strengthen quality control for high-return categories.
Monitor high-risk products and regions.
Optimize delivery performance.
Implement proactive customer feedback collection.

**📌 Project Outcome**

This project demonstrates the complete Data Analytics lifecycle, from data cleaning and database design to SQL analysis and interactive dashboard development. It highlights how data-driven insights can help reduce return rates, improve customer satisfaction, and increase profitability.
