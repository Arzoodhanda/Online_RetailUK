# Online_RetailUK

# Customer Segmentation & Classification using Machine Learning

## 📌 Project Overview
This project applies **Machine Learning techniques** to analyze customer purchasing behavior using the **RFM (Recency, Frequency, Monetary) model**. The goal is to segment customers into meaningful groups using **K-Means Clustering** and classify them using **K-Nearest Neighbors (KNN) and Decision Tree models**. The insights derived from this analysis help businesses optimize their marketing strategies and improve customer retention.

## 📂 Dataset
The dataset used in this project is an **online retail dataset**, containing transactional data, including:
- **Customer ID**: Unique identifier for each customer
- **Invoice Date**: Date of purchase
- **Quantity & Price**: Number of products purchased and their unit prices
- **Total Spend**: Calculated as `Quantity * Price`

## 🚀 Methodology
The project follows a structured pipeline to ensure robust analysis:

1. **Data Preprocessing & Cleaning**  
   - Remove missing values & negative transactions.  
   - Convert dates to a proper format.  
   - Compute **Total Spend** per transaction.

2. **RFM Analysis & Feature Engineering**  
   - Compute **Recency** (days since last purchase).  
   - Compute **Frequency** (number of purchases).  
   - Compute **Monetary** (total spending).  

3. **Customer Segmentation with K-Means Clustering**  
   - Scale data for consistency.  
   - Use the **Elbow Method** to determine the optimal number of clusters.  
   - Assign customers to clusters.  

4. **Classification using KNN & Decision Tree**  
   - Split data into **train/test sets (80/20)**.  
   - Train a **K-Nearest Neighbors (KNN)** classifier.  
   - Train a **Decision Tree**, prune it to avoid overfitting.  
   - Evaluate models using **confusion matrices**.  

5. **Visualization & Interpretation**  
   - **Cluster Profiles** using bar plots.  
   - **Decision Tree Visualization** using `rpart.plot()`.

## 📊 Key Findings
- Customers were grouped into **4 segments**:
  1. **High-Value Customers** (Frequent buyers with high spending)
  2. **Moderate Spenders** (Regular buyers with average spending)
  3. **Occasional Shoppers** (Infrequent purchases but high spending)
  4. **Churn-Risk Customers** (Haven’t shopped in a long time)

- The **Decision Tree Model** identified **Recency and Frequency** as the most significant factors influencing customer segmentation.
- The **KNN classifier** effectively categorized customers based on their purchasing behavior.

## 📌 Technologies Used
- **R programming** for data analysis & visualization.
- **Libraries Used**:  
  - `dplyr`, `tidyr` (Data Manipulation)  
  - `ggplot2` (Data Visualization)  
  - `cluster`, `caret` (Machine Learning)  
  - `rpart`, `rpart.plot` (Decision Trees)  

## 📦 Installation & Usage
### **1. Clone this Repository**
```bash
git clone https://github.com/your-username/customer-segmentation-ml.git
cd customer-segmentation-ml
