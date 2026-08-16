# Egypt External Debt Analysis

## Overview

This project analyzes the evolution of Egypt's public and publicly guaranteed external debt from 1970 to 2024 using World Bank data.

The main objective is to explore the historical behavior of external debt and examine which macroeconomic indicators are statistically associated with annual changes in debt.

## Research Question

**Which macroeconomic factors are associated with changes in Egypt's external public debt?**

## Data Source

The data was collected directly from the World Bank using the `WDI` package in R.

### Variables Used

- External public and publicly guaranteed debt
- GDP growth
- Inflation
- Foreign direct investment (FDI)
- Exports of goods and services
- Current account balance

## Tools and Libraries

- R
- WDI
- tidyverse
- ggplot2
- janitor
- corrplot
- ggrepel

## Methodology

The project followed the following analytical workflow:

1. Data collection from the World Bank API
2. Data cleaning and missing-value assessment
3. Creation of annual debt growth and annual debt change variables
4. Exploratory Data Analysis (EDA)
5. Time-series visualization of debt and macroeconomic indicators
6. Correlation analysis
7. Scatterplot analysis
8. Identification of unusual debt-growth years using the IQR method
9. Simple linear regression
10. Multiple linear regression

---

## External Debt Trend

Egypt's external public debt shows substantial changes over the 1970–2024 period.

![Egypt External Public Debt](plots/debt_over_time.png)

---

## Annual Debt Growth

Annual percentage changes reveal that debt growth varied considerably across the period.

![Annual Debt Growth](plots/annual_debt_growth.png)

Using the IQR method, 1975 and 1977 were identified as statistical outliers in annual debt growth.

---

## Inflation Over Time

![Egypt Inflation Over Time](plots/inflation_over_time.png)

---

## Current Account Balance

![Egypt Current Account Balance](plots/current_account_balance.png)

---

## Debt and Inflation

The relationship between external debt and inflation was explored visually using a scatterplot and linear trend.

![Debt vs Inflation](plots/debt_vs_inflation.png)

---

## Regression Analysis

### Simple Linear Regression

A simple linear regression was first estimated between annual external debt growth and GDP growth.

The model found a statistically significant positive association between GDP growth and annual debt growth:

- GDP growth coefficient: **3.846**
- p-value: **0.002**
- R²: **0.169**

However, this relationship changed after other macroeconomic variables were included in the model.

### Multiple Linear Regression

The final model included:

- GDP growth
- Inflation
- FDI
- Exports
- Current account balance

The overall regression model was statistically significant:

- **F-test p-value: 0.004**
- **R²: 0.325**
- **Adjusted R²: 0.245**

This means that the model explains approximately **32.5% of the variation in annual external debt growth**.

### Regression Results

| Variable | Coefficient | p-value | Statistical Significance |
|---|---:|---:|---|
| GDP Growth | 0.725 | 0.490 | Not significant |
| Inflation | 0.251 | 0.321 | Not significant |
| FDI | -1.648 | 0.052 | Marginal |
| Exports | 0.579 | 0.151 | Not significant |
| Current Account | -1.855 | 0.003 | Significant |

The current account balance showed the strongest statistically significant association with annual external debt growth.

A one-percentage-point improvement in the current account balance was associated with approximately a **1.86 percentage-point decrease in annual debt growth**, holding the other variables constant.

FDI showed suggestive evidence of a negative association but narrowly missed the conventional 5% significance threshold.

---

## Key Findings

- Egypt's external public debt experienced substantial variation across the period studied.
- Annual debt growth included several unusually large changes, particularly in the 1970s.
- GDP growth appeared statistically significant when analyzed alone.
- After controlling for other macroeconomic indicators, GDP growth was no longer statistically significant.
- The multiple regression model was statistically significant overall.
- The model explained approximately 32.5% of the observed variation in annual debt growth.
- The current account balance showed the strongest statistically significant association with debt growth.
- The results demonstrate the importance of examining multiple variables together rather than relying only on simple correlations or individual regressions.

---

## Limitations

This analysis is exploratory and identifies statistical associations rather than causal relationships.

The dataset contains a relatively small number of annual observations, and the analysis does not explicitly model all factors that may influence external borrowing.

Potential influential observations, structural breaks, exchange-rate effects, serial correlation, and other time-series characteristics were not modeled explicitly.

Therefore, the regression results should be interpreted as exploratory statistical evidence rather than causal estimates.

---

## Repository Structure

```text
Egypt-external-debt-analysis/
│
├── README.md
├── egypt_external_debt_analysis.R
└── plots/
    ├── debt_over_time.png
    ├── inflation_over_time.png
    ├── debt_growth_yoy.png
    ├── annual_debt_growth.png
    ├── debt_vs_inflation.png
    └── current_account_balance.png
