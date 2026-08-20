# ============================================================
# Egypt external public debt and macroeconomic indicators
# Data source: World Bank, via the WDI package
# Period: 1970-2024
# ============================================================

# Install missing packages once. Packages already installed are skipped.
required_packages <- c(
  "WDI", "dplyr", "tidyr", "janitor", "ggplot2",
  "scales", "ggrepel", "corrplot", "ggthemes"
)

missing_packages <- required_packages[
  !required_packages %in% rownames(installed.packages())
]

if (length(missing_packages) > 0) {
  install.packages(missing_packages)
}

suppressPackageStartupMessages({
  library(WDI)
  library(dplyr)
  library(tidyr)
  library(janitor)
  library(ggplot2)
  library(scales)
  library(ggrepel)
  library(corrplot)
  library(ggthemes)
})

# ------------------------------------------------------------
# 1. Download and prepare the data
# ------------------------------------------------------------

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
  end = 2024,
  extra = FALSE
) %>%
  clean_names() %>%
  select(
    country, iso2c, year, debt, gdp_growth,
    inflation, fdi, exports, current_account
  ) %>%
  arrange(year) %>%
  mutate(
    debt_billion = debt / 1e9,
    debt_change = debt_billion - lag(debt_billion),
    debt_growth = 100 * (debt / lag(debt) - 1)
  )

head(data)
str(data)
summary(data)
colSums(is.na(data))
sapply(data, function(x) sum(!is.na(x)))

# A complete-case dataset is useful for models that require the same years
# for every variable. It should not replace `data` for individual charts.
data_complete <- data %>%
  drop_na(debt, gdp_growth, inflation, fdi, exports, current_account)

range(data$year, na.rm = TRUE)
range(data_complete$year, na.rm = TRUE)

# ------------------------------------------------------------
# 2. Reusable chart theme
# ------------------------------------------------------------

my_theme <- theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold", size = 17, color = "#111827"),
    plot.subtitle = element_text(size = 11, color = "#6B7280"),
    axis.title = element_text(face = "bold", color = "#374151"),
    axis.text = element_text(color = "#4B5563"),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank()
  )

# ------------------------------------------------------------
# 3. External debt over time
# ------------------------------------------------------------

ggplot(data, aes(x = year, y = debt_billion)) +
  geom_area(fill = "#93C5FD", alpha = 0.35, na.rm = TRUE) +
  geom_line(color = "#1D4ED8", linewidth = 1.2, na.rm = TRUE) +
  scale_y_continuous(labels = label_number(accuracy = 1)) +
  labs(
    title = "Egypt's External Public Debt",
    subtitle = "Public and publicly guaranteed external debt, 1970-2024",
    x = NULL,
    y = "US$ billion",
    caption = "Source: World Bank (WDI)"
  ) +
  my_theme

# Annual debt growth
ggplot(data, aes(x = year, y = debt_growth)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_col(
    aes(fill = debt_growth >= 0),
    alpha = 0.85,
    na.rm = TRUE,
    show.legend = FALSE
  ) +
  scale_fill_manual(values = c(`TRUE` = "#2563EB", `FALSE` = "#DC2626")) +
  labs(
    title = "Annual Growth in Egypt's External Debt",
    subtitle = "Year-over-year percentage change, 1970-2024",
    x = NULL,
    y = "Debt growth (%)",
    caption = "Source: World Bank (WDI)"
  ) +
  my_theme

# ------------------------------------------------------------
# 4. Individual macroeconomic charts
# ------------------------------------------------------------

# GDP growth -- the erroneous standalone `--` before ggplot was removed.
ggplot(data, aes(x = year, y = gdp_growth)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey60") +
  geom_line(color = "#2563EB", linewidth = 1.1, na.rm = TRUE) +
  labs(
    title = "Egypt's GDP Growth Over Time",
    subtitle = "Annual real GDP growth, 1970-2024",
    x = NULL,
    y = "GDP growth (%)"
  ) +
  my_theme

ggplot(data, aes(x = year, y = inflation)) +
  geom_line(color = "#DC2626", linewidth = 1.1, na.rm = TRUE) +
  labs(
    title = "Egypt's Inflation Rate Over Time",
    subtitle = "Annual consumer-price inflation, 1970-2024",
    x = NULL,
    y = "Inflation (%)"
  ) +
  my_theme

ggplot(data, aes(x = year, y = fdi)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey60") +
  geom_line(color = "#059669", linewidth = 1.1, na.rm = TRUE) +
  labs(
    title = "Foreign Direct Investment in Egypt",
    subtitle = "FDI net inflows as a share of GDP, 1970-2024",
    x = NULL,
    y = "FDI (% of GDP)"
  ) +
  my_theme

ggplot(data, aes(x = year, y = exports)) +
  geom_line(color = "#7C3AED", linewidth = 1.1, na.rm = TRUE) +
  labs(
    title = "Egypt's Exports Over Time",
    subtitle = "Exports of goods and services as a share of GDP, 1970-2024",
    x = NULL,
    y = "Exports (% of GDP)"
  ) +
  my_theme

ggplot(data, aes(x = year, y = current_account)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_line(color = "#EA580C", linewidth = 1.1, na.rm = TRUE) +
  labs(
    title = "Egypt's Current Account Balance",
    subtitle = "Current-account balance as a share of GDP, 1970-2024",
    x = NULL,
    y = "Current account (% of GDP)"
  ) +
  my_theme

# ------------------------------------------------------------
# 5. Faceted macroeconomic charts
# ------------------------------------------------------------

economic_long <- data %>%
  select(year, gdp_growth, inflation, fdi, exports, current_account) %>%
  pivot_longer(
    cols = -year,
    names_to = "indicator",
    values_to = "value"
  ) %>%
  mutate(
    indicator = recode(
      indicator,
      gdp_growth = "GDP growth",
      inflation = "Inflation",
      fdi = "FDI",
      exports = "Exports",
      current_account = "Current account"
    )
  )

indicator_colors <- c(
  "GDP growth" = "#2563EB",
  "Inflation" = "#DC2626",
  "FDI" = "#059669",
  "Exports" = "#7C3AED",
  "Current account" = "#EA580C"
)

ggplot(economic_long, aes(x = year, y = value, color = indicator)) +
  geom_line(linewidth = 0.95, na.rm = TRUE) +
  facet_wrap(~indicator, scales = "free_y", ncol = 2) +
  scale_color_manual(values = indicator_colors) +
  labs(
    title = "Egypt's Key Economic Indicators",
    subtitle = "Evolution of major macroeconomic indicators, 1970-2024",
    x = NULL,
    y = NULL
  ) +
  my_theme +
  theme(
    strip.text = element_text(face = "bold"),
    legend.position = "none"
  )

# This object is now created before it is used.
economic_long_2 <- data %>%
  select(year, fdi, exports, current_account) %>%
  pivot_longer(
    cols = -year,
    names_to = "indicator",
    values_to = "value"
  )

ggplot(economic_long_2, aes(x = year, y = value, color = indicator)) +
  geom_line(linewidth = 1, na.rm = TRUE) +
  facet_wrap(~indicator, scales = "free_y", ncol = 2) +
  scale_color_manual(
    values = c(
      fdi = "#00897B",
      exports = "#1565C0",
      current_account = "#EF6C00"
    )
  ) +
  labs(
    title = "Egypt's External Economic Indicators",
    subtitle = "FDI, exports and current-account balance over time",
    x = NULL,
    y = NULL
  ) +
  theme_economist(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold", size = 18),
    strip.text = element_text(face = "bold"),
    legend.position = "none"
  )

# ------------------------------------------------------------
# 6. Correlations
# ------------------------------------------------------------

cor_variables <- data %>%
  select(debt, gdp_growth, inflation, fdi, exports, current_account)

# Pairwise complete observations retain all available year-pairs.
cor_matrix <- cor(
  cor_variables,
  use = "pairwise.complete.obs",
  method = "pearson"
)

round(cor_matrix, 2)

corrplot(
  cor_matrix,
  method = "color",
  type = "upper",
  addCoef.col = "black",
  number.cex = 0.75,
  tl.col = "black",
  tl.srt = 45
)

# ------------------------------------------------------------
# 7. Scatterplots and linear trend lines
# ------------------------------------------------------------

ggplot(data, aes(x = gdp_growth, y = debt_billion)) +
  geom_point(color = "#1565C0", size = 2.7, alpha = 0.7, na.rm = TRUE) +
  geom_smooth(
    method = "lm", formula = y ~ x, se = TRUE,
    color = "#D32F2F", linewidth = 1, na.rm = TRUE
  ) +
  labs(
    title = "External Debt vs GDP Growth in Egypt",
    subtitle = "Annual observations, 1970-2024",
    x = "GDP growth (%)",
    y = "External debt (US$ billion)",
    caption = "Source: World Bank (WDI)"
  ) +
  my_theme

ggplot(data, aes(x = inflation, y = debt_billion)) +
  geom_point(color = "#00897B", size = 2.7, alpha = 0.7, na.rm = TRUE) +
  geom_smooth(
    method = "lm", formula = y ~ x, se = TRUE,
    color = "#D32F2F", linewidth = 1, na.rm = TRUE
  ) +
  geom_text_repel(
    data = data %>% filter(debt_billion > 80 | inflation > 25),
    aes(label = year),
    size = 3.3,
    max.overlaps = Inf,
    na.rm = TRUE
  ) +
  labs(
    title = "External Debt vs Inflation in Egypt",
    subtitle = "Annual observations, 1970-2024",
    x = "Inflation (%)",
    y = "External debt (US$ billion)",
    caption = "Source: World Bank (WDI)"
  ) +
  my_theme

economic_scatter <- data %>%
  select(year, debt_billion, fdi, exports, current_account) %>%
  pivot_longer(
    cols = c(fdi, exports, current_account),
    names_to = "indicator",
    values_to = "value"
  )

ggplot(economic_scatter, aes(x = value, y = debt_billion)) +
  geom_point(color = "#1565C0", size = 2.5, alpha = 0.7, na.rm = TRUE) +
  geom_smooth(
    method = "lm", formula = y ~ x, se = TRUE,
    color = "#D32F2F", linewidth = 0.9, na.rm = TRUE
  ) +
  facet_wrap(~indicator, scales = "free_x", ncol = 3) +
  labs(
    title = "External Debt and Egypt's External Economic Indicators",
    subtitle = "Relationships with FDI, exports and current-account balance",
    x = NULL,
    y = "External debt (US$ billion)",
    caption = "Source: World Bank (WDI)"
  ) +
  my_theme +
  theme(strip.text = element_text(face = "bold"))

# ------------------------------------------------------------
# 8. Unusual annual debt-growth observations
# ------------------------------------------------------------

top_debt_growth <- data %>%
  filter(!is.na(debt_growth)) %>%
  select(year, debt_billion, debt_change, debt_growth) %>%
  arrange(desc(debt_growth)) %>%
  slice_head(n = 10)

top_debt_growth

q1 <- quantile(data$debt_growth, 0.25, na.rm = TRUE)
q3 <- quantile(data$debt_growth, 0.75, na.rm = TRUE)
iqr_debt <- IQR(data$debt_growth, na.rm = TRUE)
lower_bound <- q1 - 1.5 * iqr_debt
upper_bound <- q3 + 1.5 * iqr_debt

unusual_years <- data %>%
  filter(debt_growth < lower_bound | debt_growth > upper_bound) %>%
  select(
    year, debt_billion, debt_change, debt_growth,
    gdp_growth, inflation, fdi, exports, current_account
  ) %>%
  arrange(desc(abs(debt_growth)))

unusual_years

ggplot(data, aes(x = year, y = debt_growth)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_line(color = "#1565C0", linewidth = 0.9, na.rm = TRUE) +
  geom_point(color = "#1565C0", size = 2.2, alpha = 0.8, na.rm = TRUE) +
  geom_text_repel(
    data = unusual_years,
    aes(label = year),
    size = 3.3,
    max.overlaps = Inf,
    na.rm = TRUE
  ) +
  labs(
    title = "Unusual Annual Changes in Egypt's External Debt",
    subtitle = "Labels identify observations outside the 1.5 x IQR boundaries",
    x = NULL,
    y = "Annual debt growth (%)",
    caption = "Source: World Bank (WDI)"
  ) +
  my_theme

# ------------------------------------------------------------
# 9. Simple regression: debt growth and GDP growth
# ------------------------------------------------------------

reg_data <- data %>%
  select(year, debt_growth, gdp_growth) %>%
  drop_na(debt_growth, gdp_growth)

model_gdp <- lm(debt_growth ~ gdp_growth, data = reg_data)
summary(model_gdp)
       
# ------------------------------------------------------------
# 10. Multiple regression: debt growth and macroeconomic factors
# ------------------------------------------------------------

multiple_reg_data <- data %>%
  select(
    year,
    debt_growth,
    gdp_growth,
    inflation,
    fdi,
    exports,
    current_account
  ) %>%
  drop_na(
    debt_growth,
    gdp_growth,
    inflation,
    fdi,
    exports,
    current_account
  )

multiple_model <- lm(
  debt_growth ~ gdp_growth + inflation + fdi + exports + current_account,
  data = multiple_reg_data
)

summary(multiple_model)

# Number of observations used in the model
nobs(multiple_model)

# Important: this model describes association, not causation. Because both
# variables are time-series data, residual autocorrelation and stationarity
# should be checked before drawing stronger econometric conclusions.

# Important: this model describes association, not causation. Because both
# variables are time-series data, residual autocorrelation and stationarity
