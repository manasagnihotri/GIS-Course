# Load necessary libraries
library(dplyr)
library(sf)
library(spdep)
library(spatialreg)

setwd("~/Downloads/Lab 8")

work_from_home <- st_read("Work_From_Home_Data.shp")  # Ensure this is in the correct projection

# 1. Linear Regressions ------------------------------------
lm_model <- lm(per_wrk ~ Pr_Blck + Pr_Hspn + Pr_Pvrt + Pr_200K + Per_40k + Pr_Unmp + Pr_Drpt + Pr_Bchl,
                          data =  work_from_home_clean
)
summary(lm_model)

# 4. Optional: Add a Spatial Lag Term in an OLS (naïve approach) -------------
sum(!is.finite(work_from_home$per_wrk))

# Option 1: Remove rows with non-finite values
work_from_home_clean <- work_from_home[is.finite(work_from_home$per_wrk), ]
tracts_listw_clean <- subset(tracts_listw, is.finite(work_from_home$per_wrk))

# Then run lag.listw() on the cleaned data
# Create spatial lag of dependent variable
work_from_home_clean$lag_work_rate <- lag.listw(
  tracts_listw_clean, work_from_home_clean$per_wrk, zero.policy = TRUE
)

# OLS with spatial lag (not recommended for inference, but for illustration)
lm_with_spatial_lag <- lm(per_wrk ~ lag_work_rate + Pr_Blck + Pr_Hspn + Pr_Pvrt + Pr_200K + Per_40k + Pr_Unmp + Pr_Drpt + Pr_Bchl,
                          data =  work_from_home_clean
)
summary(lm_with_spatial_lag)

# Create neighbors object
tracts_nb <- poly2nb(work_from_home, queen = TRUE, snap = 1e-6)

# Create spatial weights matrix
tracts_listw <- nb2listw(tracts_nb, style = "W", zero.policy = TRUE)

# 3. Spatial Regressions -----------------------------------

# Spatial Lag Model
spatial_lag_model <- lagsarlm(
  per_wrk ~ Pr_Blck + Pr_Hspn + Pr_Pvrt + Pr_200K + Per_40k + Pr_Unmp + Pr_Drpt + Pr_Bchl,
  data = work_from_home,
  listw = tracts_listw,
  zero.policy = TRUE
)

summary(spatial_lag_model)

spatial_erorr_model <- errorsarlm(
  per_wrk ~ Pr_Blck + Pr_Hspn + Pr_Pvrt + Pr_200K + Per_40k + Pr_Unmp + Pr_Drpt + Pr_Bchl,
  data = work_from_home,
  listw = tracts_listw,
  zero.policy = TRUE
)

summary(spatial_erorr_model)

spatial_durbin_model <- lagsarlm(
  per_wrk ~ Pr_Blck + Pr_Hspn + Pr_Pvrt + Pr_200K + Per_40k + Pr_Unmp + Pr_Drpt + Pr_Bchl,
  data = work_from_home,
  listw = tracts_listw,
  type = "mixed",  # this specifies Durbin model
  zero.policy =  TRUE
)

summary(spatial_durbin_model)





