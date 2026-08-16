# ==========================================
# Egypt External Debt Analysis
# Phase 1: Packages
# ==========================================

install.packages("WDI")
install.packages("tidyverse")
install.packages("janitor")
library(WDI)
library(tidyverse)
library(janitor)
data <- WDI(
  country = "EG",
  indicator = c(
    debt = "DT.DOD.DPPG.CD",
    gdp_growth = "NY.GDP.MKTP.KD.ZG",
    inflation = "FP.CPI.TOTL.ZG",
    fdi = "BX.KLT.DINV.WD.GD.ZS",
    exports = "NE.EXP.GNFS.ZS",
    current_account = "BN.CAB.XOKA.GD.ZS"
  ),
  start = 1970,
  end = 2024
)
head(data)
str(data)
summary(data)
data <- data %>%
  clean_names()
names(data)
data <- data %>%
  select(
    country,
    iso2c,
    year,
    debt,
    gdp_growth,
    inflation,
    fdi,
    exports,
    current_account
  )
head(data)
summary(data)
colSums(is.na(data))
##what1
sapply(data, function(x) sum(!is.na(x)))
data_complete <- data %>%
  drop_na()
range(data_complete$year)
##what2
library(ggplot2)
library(scales)
ggplot(data, aes(x = year, y = debt / 1e9)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2) +
  labs(
    title = "Egypt's External Public Debt Over Time",
    subtitle = "Public and publicly guaranteed external debt, 1970–2024",
    x = "Year",
    y = "External Debt (US$ Billion)"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 16),
    plot.subtitle = element_text(size = 11),
    axis.title = element_text(face = "bold")
  )
## more attarcative 
ggplot(data, aes(x = year, y = debt / 1e9)) +
  geom_area(alpha = 0.25) +
  geom_line(linewidth = 1.2) +
  labs(
    title = "Egypt's External Public Debt",
    subtitle = "External debt stock, 1970–2024",
    x = " year",
    y = "US$ Billion"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold", size = 18),
    plot.subtitle = element_text(color = "gray40"),
    panel.grid.minor = element_blank()
  )
#what3 
data <- data %>%
  arrange(year) %>%
  mutate(
    debt_change = debt - lag(debt),
    debt_growth = (debt / lag(debt) - 1) * 100
  )
#visual
ggplot(data, aes(x = year, y = debt_growth)) +
  geom_col(alpha = 0.8) +
  geom_hline(yintercept = 0, linewidth = 0.8) +
  labs(
    title = "Year-over-Year Growth in Egypt's External Debt",
    subtitle = "Annual percentage change in external public debt",
    x = NULL,
    y = "Debt Growth (%)"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold", size = 16),
    plot.subtitle = element_text(color = "gray40"),
    panel.grid.minor = element_blank()
  )
#what4
economic_data <- data %>%
  select(
    year,
    gdp_growth,
    inflation,
    fdi,
    exports,
    current_account
  )
economic_data <- data %>%
  select(
    year,
    gdp_growth,
    inflation,
    fdi,
    exports,
    current_account
  )
#infaltion 
ggplot(data, aes(x = year, y = inflation)) +
  geom_line(linewidth = 1.1) +
  geom_point(size = 1.8) +
  labs(
    title = "Egypt's Inflation Rate Over Time",
    subtitle = "Annual consumer price inflation, 1970–2024",
    x = "Year",
    y = "Inflation (%)"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold", size = 16),
    plot.subtitle = element_text(color = "gray40"),
    panel.grid.minor = element_blank()
  )
#FDi
ggplot(data, aes(x = year, y = fdi)) +
  geom_line(linewidth = 1.1) +
  geom_point(size = 1.8) +
  labs(
    title = "Foreign Direct Investment in Egypt",
    subtitle = "FDI net inflows (% of GDP), 1970–2024",
    x = "Year",
    y = "FDI (% of GDP)"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold", size = 16),
    plot.subtitle = element_text(color = "gray40"),
    panel.grid.minor = element_blank()
  )
#export
ggplot(data, aes(x = year, y = exports)) +
  geom_line(linewidth = 1.1) +
  geom_point(size = 1.8) +
  labs(
    title = "Egypt's Exports Over Time",
    subtitle = "Exports of goods and services (% of GDP), 1970–2024",
    x = "Year",
    y = "Exports (% of GDP)"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold", size = 16),
    plot.subtitle = element_text(color = "gray40"),
    panel.grid.minor = element_blank()
  )
#CA
ggplot(data, aes(x = year, y = current_account)) +
  geom_line(linewidth = 1.1, na.rm = TRUE) +
  geom_point(size = 1.8, na.rm = TRUE) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  labs(
    title = "Egypt's Current Account Balance",
    subtitle = "Current account balance (% of GDP), 1970–2024",
    x = "Year",
    y = "Current Account (% of GDP)"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold", size = 16),
    plot.subtitle = element_text(color = "gray40"),
    panel.grid.minor = element_blank()
  )
geom_hline(yintercept = 0)
#wide to long 
library(tidyr)

economic_long <- data %>%
  select(
    year,
    gdp_growth,
    inflation,
    fdi,
    exports,
    current_account
  ) %>%
  pivot_longer(
    cols = -year,
    names_to = "indicator",
    values_to = "value"
  )
#visual
ggplot(economic_long, aes(x = year, y = value)) +
  geom_line(linewidth = 0.9, na.rm = TRUE) +
  facet_wrap(~ indicator, scales = "free_y") +
  labs(
    title = "Egypt's Key Economic Indicators Over Time",
    x = NULL,
    y = NULL
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold", size = 17),
    strip.text = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )
#attractive
my_theme <- theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(
      face = "bold",
      size = 18,
      color = "#111827"
    ),
    plot.subtitle = element_text(
      size = 11,
      color = "#6B7280"
    ),
    axis.title = element_text(
      face = "bold",
      color = "#374151"
    ),
    axis.text = element_text(
      color = "#4B5563"
    ),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank()
  )
--
ggplot(data, aes(x = year, y = gdp_growth)) +
  geom_line(color = "#2563EB", linewidth = 1.2) +
  geom_point(color = "#1D4ED8", size = 2) +
  labs(
    title = "Egypt's GDP Growth Over Time",
    subtitle = "Annual GDP growth, 1970–2024",
    x = NULL,
    y = "GDP Growth (%)"
  ) +
  my_theme
##
ggplot(economic_long, aes(x = year, y = value, color = indicator)) +
  geom_line(
    linewidth = 1,
    na.rm = TRUE
  ) +
  facet_wrap(
    ~ indicator,
    scales = "free_y",
    ncol = 2
  ) +
  scale_color_manual(
    values = c(
      "gdp_growth" = "#2563EB",
      "inflation" = "#DC2626",
      "fdi" = "#059669",
      "exports" = "#7C3AED",
      "current_account" = "#EA580C"
    )
  ) +
  labs(
    title = "Egypt's Key Economic Indicators",
    subtitle = "Evolution of major macroeconomic indicators, 1970–2024",
    x = NULL,
    y = NULL
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(
      face = "bold",
      size = 19,
      color = "#111827"
    ),
    plot.subtitle = element_text(
      size = 11.5,
      color = "#6B7280",
      margin = margin(b = 15)
    ),
    strip.text = element_text(
      face = "bold",
      size = 12,
      color = "#1F2937"
    ),
    strip.background = element_rect(
      fill = "#F3F4F6",
      color = NA
    ),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_line(
      color = "#E5E7EB",
      linewidth = 0.4
    ),
    legend.position = "none",
    plot.margin = margin(15, 15, 15, 15)
  )
install.packages("ggthemes")
library(ggthemes)
##
library(ggplot2)
ggplot(economic_long_2, aes(x = year, y = value, color = indicator)) +
  geom_line(linewidth = 1) +
  facet_wrap(~ indicator, scales = "free_y", ncol = 2) +
  scale_color_manual(
    values = c(
      "fdi" = "#00897B",
      "exports" = "#1565C0",
      "current_account" = "#EF6C00"
    )
  ) +
  labs(
    title = "Egypt's External Economic Indicators",
    subtitle = "FDI, exports and current account balance over time",
    x = NULL,
    y = NULL
  ) +
  theme_economist(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold", size = 18),
    plot.subtitle = element_text(size = 11),
    strip.text = element_text(face = "bold"),
    legend.position = "none"
  )
economic_long_2 <- data %>%
  select(year, fdi, exports, current_account) %>%
  pivot_longer(
    cols = c(fdi, exports, current_account),
    names_to = "indicator",
    values_to = "value"
  )
head(economic_long_2)
library(dplyr)

library(ggplot2)
library(ggthemes)
install.packages("ggthemes")

ggplot(economic_long_2, aes(x = year, y = value, color = indicator)) +
  geom_line(linewidth = 1) +
  facet_wrap(~ indicator, scales = "free_y", ncol = 2) +
  scale_color_manual(
    values = c(
      "fdi" = "#00897B",
      "exports" = "#1565C0",
      "current_account" = "#EF6C00"
    )
  ) +
  labs(
    title = "Egypt's External Economic Indicators",
    subtitle = "FDI, exports and current account balance over time",
    x = NULL,
    y = NULL
  ) +
  theme_economist(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold", size = 18),
    plot.subtitle = element_text(size = 11),
    strip.text = element_text(face = "bold"),
    legend.position = "none"
  )
library(tidyr)
##correlation
cor(
  data_complete[, c(
    "debt",
    "gdp_growth",
    "inflation",
    "fdi",
    "exports",
    "current_account"
  )]
)
#cor visual
install.packages("corrplot")
library(corrplot)
cor_matrix <- cor(
  data_complete[, c(
    "debt",
    "gdp_growth",
    "inflation",
    "fdi",
    "exports",
    "current_account"
  )]
)

corrplot(
  cor_matrix,
  method = "color",
  type = "upper",
  addCoef.col = "black",
  tl.col = "black",
  tl.srt = 45
)
##scatterplot
ggplot(data, aes(x = gdp_growth, y = debt / 1e9)) +
  geom_point(
    color = "#1565C0",
    size = 3,
    alpha = 0.7
  ) +
  geom_smooth(
    method = "lm",
    se = TRUE,
    color = "#D32F2F",
    linewidth = 1
  ) +
  labs(
    title = "External Debt vs GDP Growth in Egypt",
    subtitle = "Annual observations, 1970–2024",
    x = "GDP Growth (%)",
    y = "External Debt (USD Billion)",
    caption = "Source: World Bank"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold", size = 17),
    plot.subtitle = element_text(color = "grey40"),
    panel.grid.minor = element_blank()
  )
#scatter gdp -inflation
ggplot(data, aes(x = inflation, y = debt / 1e9)) +
  geom_point(
    color = "#00897B",
    size = 3,
    alpha = 0.7
  ) +
  geom_smooth(
    method = "lm",
    se = TRUE,
    color = "#D32F2F",
    linewidth = 1
  ) +
  labs(
    title = "External Debt vs Inflation in Egypt",
    subtitle = "Annual observations, 1970–2024",
    x = "Inflation (%)",
    y = "External Debt (USD Billion)",
    caption = "Source: World Bank"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold", size = 17),
    plot.subtitle = element_text(color = "grey40"),
    panel.grid.minor = element_blank()
  )
##
install.packages("ggrepel")
library(ggrepel)
library(ggplot2)
library(ggrepel)

ggplot(data, aes(x = inflation, y = debt / 1e9)) +
  
  geom_point(
    color = "#00897B",
    size = 3,
    alpha = 0.7
  ) +
  
  geom_smooth(
    method = "lm",
    se = TRUE,
    color = "#D32F2F",
    linewidth = 1
  ) +
  
  geom_text_repel(
    data = subset(data, debt / 1e9 > 80 | inflation > 25),
    aes(label = year),
    size = 3.5,
    max.overlaps = Inf
  ) +
  
  labs(
    title = "External Debt vs Inflation in Egypt",
    subtitle = "Annual observations, 1970–2024",
    x = "Inflation (%)",
    y = "External Debt (USD Billion)",
    caption = "Source: World Bank"
  ) +
  
  theme_minimal(base_size = 13) +
  
  theme(
    plot.title = element_text(face = "bold", size = 17),
    plot.subtitle = element_text(color = "grey40"),
    panel.grid.minor = element_blank()
  )
##
# Load required packages
library(dplyr)
library(tidyr)
library(ggplot2)

# Create the long-format dataset
economic_scatter <- data %>%
  select(year, debt, fdi, exports, current_account) %>%
  pivot_longer(
    cols = c(fdi, exports, current_account),
    names_to = "indicator",
    values_to = "value"
  )

# Create the scatterplots
ggplot(
  economic_scatter,
  aes(x = value, y = debt / 1e9)
) +
  geom_point(
    color = "#1565C0",
    size = 2.7,
    alpha = 0.7
  ) +
  geom_smooth(
    method = "lm",
    se = TRUE,
    color = "#D32F2F",
    linewidth = 0.9,
    na.rm = TRUE
  ) +
  facet_wrap(
    ~ indicator,
    scales = "free_x",
    ncol = 3
  ) +
  labs(
    title = "External Debt and Egypt's External Economic Indicators",
    subtitle = "Relationship with FDI, exports and current account balance",
    x = NULL,
    y = "External Debt (USD Billion)",
    caption = "Source: World Bank"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold", size = 17),
    plot.subtitle = element_text(color = "grey40"),
    strip.text = element_text(face = "bold", size = 11),
    panel.grid.minor = element_blank()
  )
## Create a new dataset to analyze annual changes in external debt

debt_changes <- data %>%
  arrange(year) %>%
  mutate(
    
    debt_billion = debt / 1e9,  ## Convert debt from US dollars to USD billions
    
    debt_change = debt_billion - lag(debt_billion),  
    ## Calculate the absolute annual change in debt
    
    debt_growth = ((debt / lag(debt)) - 1) * 100  
    ## Calculate the annual percentage growth in external debt
  )


## Display the 10 years with the highest percentage growth in external debt

debt_changes %>%
  select(
    year,
    debt_billion,
    debt_change,
    debt_growth
  ) %>%
  arrange(desc(debt_growth)) %>%
  head(10)

library(dplyr)
library(ggplot2)
library(ggrepel)


## Plot annual percentage change in Egypt's external debt

ggplot(debt_changes, aes(x = year, y = debt_growth)) +
  
  geom_hline(
    yintercept = 0,
    linetype = "dashed",
    color = "grey50"
  ) +
  
  geom_line(
    color = "#1565C0",
    linewidth = 0.9,
    na.rm = TRUE
  ) +
  
  geom_point(
    color = "#1565C0",
    size = 2.5,
    alpha = 0.8,
    na.rm = TRUE
  ) +
  
  geom_text_repel(
    data = debt_changes %>%
      filter(abs(debt_growth) > 20),
    aes(label = year),
    size = 3.5,
    max.overlaps = Inf
  ) +
  
  labs(
    title = "Annual Growth in Egypt's External Debt",
    subtitle = "Year-over-year percentage change, 1970–2024",
    x = NULL,
    y = "Annual Debt Growth (%)",
    caption = "Source: World Bank"
  ) +
  
  theme_minimal(base_size = 13) +
  
  theme(
    plot.title = element_text(face = "bold", size = 17),
    plot.subtitle = element_text(color = "grey40"),
    panel.grid.minor = element_blank()
  )

library(dplyr)


## Calculate Q1 and Q3 for annual debt growth

q1 <- quantile(
  debt_changes$debt_growth,
  0.25,
  na.rm = TRUE
)

q3 <- quantile(
  debt_changes$debt_growth,
  0.75,
  na.rm = TRUE
)


## Calculate the Interquartile Range

iqr_debt <- q3 - q1


## Calculate the lower and upper outlier boundaries

lower_bound <- q1 - 1.5 * iqr_debt

upper_bound <- q3 + 1.5 * iqr_debt


## Display the calculated boundaries

q1
q3
iqr_debt
lower_bound
upper_bound


## Identify years outside the IQR boundaries

unusual_years <- debt_changes %>%
  filter(
    debt_growth < lower_bound |
      debt_growth > upper_bound
  ) %>%
  select(
    year,
    debt_billion,
    debt_change,
    debt_growth
  ) %>%
  arrange(desc(abs(debt_growth)))


## Display unusual years

unusual_years
library(dplyr)


## Select unusual years and the year immediately before each one

unusual_context <- data %>%
  filter(
    year %in% c(1974, 1975, 1976, 1977)
  ) %>%
  select(
    year,
    debt,
    gdp_growth,
    inflation,
    fdi,
    exports,
    current_account
  ) %>%
  mutate(
    debt_billion = debt / 1e9
  ) %>%
  select(
    year,
    debt_billion,
    gdp_growth,
    inflation,
    fdi,
    exports,
    current_account
  )


## Display the economic context around the unusual debt-growth years

unusual_context




library(dplyr)


## Create the final dataset for statistical analysis

analysis_data <- data %>%
  arrange(year) %>%
  mutate(
    debt_growth = ((debt / lag(debt)) - 1) * 100
  ) %>%
  select(
    year,
    debt_growth,
    gdp_growth,
    inflation,
    fdi,
    exports,
    current_account
  )


## Check the structure of the analysis dataset

str(analysis_data)


## Check missing values

colSums(is.na(analysis_data))


## Display descriptive statistics

summary(analysis_data)

## Remove rows with missing debt growth

reg_data <- analysis_data %>%
  filter(!is.na(debt_growth))


## Build a simple linear regression model

model_gdp <- lm(
  debt_growth ~ gdp_growth,
  data = reg_data
)


## Display the regression results

summary(model_gdp)



library(dplyr)


## Create a complete dataset containing only observations available for all model variables

model_data <- analysis_data %>%
  select(
    year,
    debt_growth,
    gdp_growth,
    inflation,
    fdi,
    exports,
    current_account
  ) %>%
  drop_na()


## Check the number of observations that will actually enter the regression

nrow(model_data)


## Check the years included in the regression

range(model_data$year)


## Build the multiple linear regression model

model_multiple <- lm(
  debt_growth ~ gdp_growth + inflation + fdi + exports + current_account,
  data = model_data
)


## Display the full regression results

summary(model_multiple)