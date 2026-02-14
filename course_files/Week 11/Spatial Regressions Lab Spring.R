setwd("~/Downloads/")

###Census 
if (!require("tidycensus")) install.packages("tidycensus")
if (!require("dplyr")) install.packages("dplyr")
if (!require("tidyr")) install.packages("tidyr")
library(tidycensus)
library(dplyr)
library(tidyr)
library(spdep)

spatial_regression_data <- st_read("spatial_regression_data.shp")

# Set your Census API key (replace with your actual key)
census_api_key("e9e7aa87b072d10e33c2e34ad2ef62b7647e391a", install = TRUE, overwrite = TRUE)

acs_vars <- c(
  total_pop = "B01003_001",
  black = "B02001_003",
  hispanic = "B03003_003",
  white_non_hispanic = "B03002_003",
  median_income = "B19013_001",
  poverty_1 = "C17002_001",
  poverty_2 = "C17002_002",
  poverty_3= "C17002_003",
  public_assist = "B19057_002",
  female_headed = "B11003_016",
  under18_poverty = "C17002_002",
  foreign_born = "B05002_013", 
  male_18_19 = "B01001_007",
  male_20 = "B01001_008",
  male_21 = "B01001_009",
  male_22_24 = "B01001_010",
  male_25_29 = "B01001_011",
  male_30_34 = "B01001_012",
  female_18_19 = "B01001_031",
  female_20 = "B01001_032",
  female_21 = "B01001_033",
  female_22_24 = "B01001_034",
  female_25_29 = "B01001_035",
  female_30_34 = "B01001_036"
)

###ACS Census Tract Groups
nyc_acs_2010 <- get_acs(
  geography = "tract",
  variables = acs_vars,
  year = 2010,
  survey = "acs5",
  state = "NY",
  county = c("005", "047", "061", "081", "085"),  # Bronx, Brooklyn, Manhattan, Queens, Staten Island
  geometry = FALSE,
  output = "wide"
)

nyc_acs_2010 <- nyc_acs_2010 %>%
  mutate(
    percent_poverty = 100 * povertyE / total_popE,
    percent_public_assist = 100 * public_assistE / total_popE,
    percent_female_headed = 100 * female_headedE / total_popE,
    percent_under18_poverty = 100 * under18_povertyE / total_popE
  )

nyc_acs_2010 <- nyc_acs_2010 %>%
  mutate(
    z_poverty = scale(percent_poverty)[, 1],
    z_public_assist = scale(percent_public_assist)[, 1],
    z_female_headed = scale(percent_female_headed)[, 1],
    z_under18_poverty = scale(percent_under18_poverty)[, 1]
  ) %>%
  mutate(
    concentrated_disadvantage = rowMeans(
      select(., z_poverty, z_public_assist, z_female_headed, z_under18_poverty),
      na.rm = TRUE
    )
  )

nyc_acs_2010$concentrated_disadvantage_scaled <- scales::rescale(
  nyc_acs_2010$concentrated_disadvantage,
  to = c(0, 1)
  
##Merge to your census tract data
model_data_2022 <- acs_2010 %>%
  left_join(arrest_2022, by = "GEOID") 
  
###Start Spatila Regression Lab Here
# Only keep complete cases used in your regression
spatial_regression_data <- spatial_regression_data %>%
  rename(
    prop_within_50ft = prp_wth,                       # or prp_w_1?
    percent_black = prcnt_b,
    percent_hispanic = prcnt_h,
    concentrated_disadvantage_scaled = cncntrt,       # if already scaled
    total_arrests = totl_rr,
    complaint_rate_std = cmpl__2,                     # standardized complaint rate
    disorder_rate_std = dsrd__1,                      # standardized disorder rate
    violent_arrest_rate_std = vlnt__2,                # standardized violent arrest rate
    marijuana_arrest_rate = marijn_               # your dependent variable
  )

spatial_regression_data_clean <- spatial_regression_data %>%
    filter(
      !is.na(marijuana_arrest_rate_log),
      !is.na(prop_within_50ft),
      !is.na(percent_black),
      !is.na(percent_hispanic),
      !is.na(concentrated_disadvantage_scaled),
      !is.na(total_arrests),
      !is.na(complaint_rate_std),
      !is.na(disorder_rate_std),
      !is.na(violent_arrest_rate_std)
    )

#Spatial Regression Weighting
neighbors <- poly2nb(spatial_regression_data_clean, queen = TRUE)
weights <- nb2listw(neighbors, style = "W", zero.policy = TRUE)

spatial_regression_data_clean$marijuana_arrest_rate_log <- log(spatial_regression_data_clean$marijuana_arrest_rate + 1)

##Spatial Lag Model
lag_model <- lagsarlm(
  marijuana_arrest_rate_log ~ prop_within_50ft + percent_black + percent_hispanic +
    concentrated_disadvantage_scaled + total_arrests + complaint_rate_std + 
    disorder_rate_std + violent_arrest_rate_std,
  data = spatial_regression_data_clean,
  listw = weights,
  method = "eigen",  # or method = "Matrix" for large datasets
  zero.policy = TRUE
)

summary(lag_model)

lag_model.2 <- lagsarlm(
  marijuana_arrest_rate_log ~ prop_within_50ft + percent_black + percent_hispanic +
    concentrated_disadvantage_scaled + total_arrests + complaint_rate_std + 
    disorder_rate_std + violent_arrest_rate_std + prop_within_50ft*percent_black,
  data = spatial_regression_data_clean,
  listw = weights,
  method = "eigen",  # or method = "Matrix" for large datasets
  zero.policy = TRUE
)

summary(lag_model.2)

##Spatial Error Model
error_model <- errorsarlm(
  marijuana_arrest_rate_log ~ prop_within_50ft + percent_black + percent_hispanic +
    concentrated_disadvantage_scaled + total_arrests + complaint_rate_std + 
    disorder_rate_std + violent_arrest_rate_std,
  data = spatial_regression_data_clean,
  listw = weights,
  method = "eigen",
  zero.policy = TRUE
)
summary(error_model)

##Linear Regression Model
linear_regression_1 <- lm(
  marijuana_arrest_rate_log ~ prop_within_50ft + percent_black + percent_hispanic +
    concentrated_disadvantage_scaled + total_arrests + complaint_rate_std + disorder_rate_std + violent_arrest_rate_std,
  data = spatial_regression_data_clean
)
summary(linear_regression_1)

linear_regression_2 <- lm(
  marijuana_arrest_rate_log ~ prop_within_50ft + percent_black + percent_hispanic +
    concentrated_disadvantage_scaled + total_arrests + complaint_rate_std + disorder_rate_std + violent_arrest_rate_std + 
    prop_within_50ft * percent_black,
  data = spatial_regression_data_clean
)
summary(linear_regression_2)

linear_regression_3 <- lm(
  marijuana_arrest_rate_log ~ prop_within_50ft + percent_black + percent_hispanic +
    concentrated_disadvantage_scaled + total_arrests + complaint_rate_std + disorder_rate_std + violent_arrest_rate_std + 
    prop_within_50ft * percent_black,
  data = spatial_regression_data_clean
)
summary(linear_regression_3)


# Compare AIC
AIC(linear_regression_1, lag_model, error_model)

##Spatial Durbin Model
durbin_model <- lagsarlm(
  marijuana_arrest_rate_log ~ prop_within_50ft + percent_black + percent_hispanic +
    concentrated_disadvantage_scaled + total_arrests + complaint_rate_std +
    disorder_rate_std + violent_arrest_rate_std + 
    prop_within_50ft * percent_black,
  data = spatial_regression_data_clean,
  listw = weights,
  type = "mixed",  # This makes it a Durbin model
  zero.policy = TRUE
)

impacts_result <- impacts(
  durbin_model,
  listw = weights,
  R = 1000  # Number of Monte Carlo simulations for standard errors
)

summary(impacts_result, zstats = TRUE, short = TRUE)

install.packages("tibble")
library(dplyr)
library(ggplot2)
library(tibble)

# Extract point estimates and standard errors
lag_coef <- summary(lag_model)$Coef
lag_ci <- confint(lag_model)

# Combine into tidy dataframe
lag_coef <- summary(lag_model)$Coef
lag_ci <- confint(lag_model)

# Align both to only common terms (intersecting rownames)
common_terms <- intersect(rownames(lag_coef), rownames(lag_ci))

# Create tidy data frame for coefficients
lag_tidy <- as.data.frame(lag_coef[common_terms, ]) %>%
  rownames_to_column("term") %>%
  rename(
    estimate = Estimate,
    std.error = `Std. Error`,
    statistic = `z value`,
    p.value = `Pr(>|z|)`
  )

# Create tidy data frame for confidence intervals
lag_ci_tidy <- as.data.frame(lag_ci[common_terms, ]) %>%
  rownames_to_column("term") %>%
  rename(conf.low = `2.5 %`, conf.high = `97.5 %`)

# Merge and filter
lag_tidy <- left_join(lag_tidy, lag_ci_tidy, by = "term") %>%
  filter(term != "(Intercept)" & term != "rho")

lag_tidy <- lag_tidy %>%
  mutate(
    significance = case_when(
      p.value < 0.001 ~ "***",
      p.value < 0.01  ~ "**",
      p.value < 0.05  ~ "*",
      p.value < 0.1   ~ ".",
      TRUE            ~ ""
    ),
    significance_label = ifelse(p.value < 0.05, "Significant", "Not Significant")
  )


ggplot(lag_tidy, aes(x = estimate, y = paste0(term, " ", significance))) +
  geom_point(size = 3, color = "darkred") +
  geom_errorbarh(aes(xmin = conf.low, xmax = conf.high), height = 0.2, color = "darkred") +
  geom_vline(xintercept = 0, linetype = "dashed", color = "gray50") +
  theme_minimal(base_size = 14) +
  labs(
    title = "Spatial Lag Model Coefficients (with Significance)",
    x = "Estimate",
    y = ""
  )

##Residuals
# OLS
spatial_regression_data_clean$ols_fitted <- fitted(linear_regression_2)
spatial_regression_data_clean$ols_resid <- residuals(linear_regression_2)

# Spatial Lag
spatial_regression_data_clean$lag_fitted <- fitted(lag_model)
spatial_regression_data_clean$lag_resid <- residuals(lag_model)

# Spatial Error
spatial_regression_data_clean$error_fitted <- fitted(error_model)
spatial_regression_data_clean$error_resid <- residuals(error_model)

install.packages("patchwork")
library(patchwork) 
p1 <- ggplot(spatial_regression_data_clean) +
  geom_sf(aes(fill = ols_resid)) +
  scale_fill_gradient2(low = "blue", mid = "white", high = "red", midpoint = 0) +
  labs(title = "OLS Residuals")

p2 <- ggplot(spatial_regression_data_clean) +
  geom_sf(aes(fill = lag_resid)) +
  scale_fill_gradient2(low = "blue", mid = "white", high = "red", midpoint = 0) +
  labs(title = "Spatial Lag Residuals")

p3 <- ggplot(spatial_regression_data_clean) +
  geom_sf(aes(fill = error_resid)) +
  scale_fill_gradient2(low = "blue", mid = "white", high = "red", midpoint = 0) +
  labs(title = "Spatial Error Residuals")

print(p1)
print(p2)
print(p3)

