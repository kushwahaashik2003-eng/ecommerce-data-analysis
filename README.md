# ecommerce-data-analysis

A complete end-to-end Data Analytics Project using
SQL, Python (Pandas, Matplotlib, Seaborn), and Power BI
to analyze e-commerce sales performance, customer behavior, and product insights.

🚀 Project Overview

This project aims to derive meaningful business insights from an e-commerce dataset by performing:

Data Cleaning

Exploratory Data Analysis (EDA)

Python-based Visualizations

SQL-based Business Queries

Power BI Dashboard Development

Customer Segmentation (High-value, CLV, RFM)

🧰 Tech Stack Used
Tool	Purpose
SQL (MySQL)	Data cleaning, aggregations, business insights
Python	Data manipulation & EDA
Pandas	Data structuring & cleaning
Matplotlib	Trend & line charts
Seaborn	Advanced statistical visualizations
Power BI	Dashboard creation & reporting
📂 Dataset Description
Column	Description
order_id	Unique order number
cust_id	Customer ID
age	Customer age
gender	Gender
order_date	Order placed date
status	Delivered / Cancelled / Returned
channel	Myntra, Amazon, Ajio, etc.
sku	Product code
category	Product category
size	Product size
qty	Quantity sold
amount	Sales amount
ship_city	Delivery city
ship_state	Delivery state
country	Country
b2b	B2B/B2C order type
🧹 Data Cleaning
✔ SQL Cleaning Tasks

Removed duplicates

Fixed date format (ORDER_DATE)

Standardized categories & channel names

Removed invalid qty values

Extracted platform from order_id prefix

Handled inconsistent city/state text
