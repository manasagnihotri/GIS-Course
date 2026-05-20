library(sf)
library(spdep)
library(spatialreg)
library(MASS)

NYCHA_paper_final_data <- readRDS("~/Downloads/NYCHA_paper_final_data.rds")

# data
df <- NYCHA_paper_final_data

#Subset to 2010 data only
df10 <- subset(NYCHA_paper_final_data, acs_year_tr == "2010")
df20 <- subset(NYCHA_paper_final_data, acs_year_tr == "2020")

# queen contiguity for all data
nb <- poly2nb(df)
lw <- nb2listw(nb, style = "W", zero.policy = TRUE)

#Moran's Test
moran.test(df$misdemeanor_rate_per_10k_rc, lw)

#  queen contiguity for 2010 data
nb10 <- poly2nb(df10)
lw10 <- nb2listw(nb10, style = "W", zero.policy = TRUE)

#  queen contiguity for 2010 data
nb20 <- poly2nb(df20)
lw20 <- nb2listw(nb20, style = "W", zero.policy = TRUE)

##OLS Regression First 

ols1 <- lm(
  log_misd_rate_10k_rc2 ~ 
    NYCHA +
    gentrify_status +
    pct_black +
    pct_hispanic +
    cd_index +
    log_violent_rate +
    log.311.rate+ factor(acs_year_tr),
  data = df
)
summary(ols1)

ols2010 <- lm(
  log_misd_rate_10k_rc2 ~ 
    NYCHA +
    gentrify_status +
    pct_black +
    pct_hispanic +
    cd_index +
    log_violent_rate +
    log.311.rate,
  data = df10
)
summary(ols2010)

ols2020 <- lm(
  log_misd_rate_10k_rc2 ~ 
    NYCHA +
    gentrify_status +
    pct_black +
    pct_hispanic +
    cd_index +
    log_violent_rate +
    log.311.rate,
  data = df20
)
summary(ols2020)

##Negative Binomial Model (no spatial lags)
nb20 <- glm.nb(
  misdemeanor_arrests_rc ~ 
    NYCHA +
    gentrify_status +
    pct_black +
    pct_hispanic +
    cd_index +
    log_violent_rate +
    log.311.rate +
    offset(log(total_pop)),
  data = df20$
)

summary(nb20)

# Spatial lag of the dependent variable - But LM Regression
df20$lag_log_misd <- lag.listw(
  lw20, 
  df20$log_misd_rate_10k_rc2,
  zero.policy = TRUE
)

lm_sl20 <- lm(
  log_misd_rate_10k_rc2 ~ 
    lag_log_misd +        # explicit spatial lag regressor
    NYCHA +
    gentrify_status +
    pct_black +
    pct_hispanic +
    cd_index +
    log_violent_rate +
    log.311.rate,
  data = df20
)

summary(lm_sl20)


slag10 <- lagsarlm(
  log_misd_rate_10k_rc2 ~ 
    NYCHA +
    gentrify_status +
    pct_black +
    pct_hispanic +
    cd_index +
    log_violent_rate +
    log.311.rate,
  data  = df10,
  listw = lw10,
  method = "Matrix"
)
summary(slag10)

ols_interact <- lm(
  log_misd_rate_10k_rc2 ~ 
    NYCHA * gentrify_status +
    pct_black +
    pct_hispanic +
    cd_index +
    log_violent_rate +
    log.311.rate,
  data = df
)
summary(ols_interact)

library(spatialreg)
#Spatial Lag Model (SAR)

slag1 <- lagsarlm(
  log_misd_rate_10k_rc2 ~ 
    NYCHA +
    gentrify_status +
    pct_black +
    pct_hispanic +
    cd_index +
    log_violent_rate +
    log.311.rate,
  data  = df,
  listw = lw,
  method = "Matrix"   # <- key speed-up
)
summary(slag1)

# variables you need
vars_needed <- c(
  "log_misd_rate_10k_rc2",
  "NYCHA",
  "gentrify_status",
  "pct_black",
  "pct_hispanic",
  "cd_index",
  "log_violent_rate",
  "log.311.rate"
)

# drop geometry to check missingness
attr_only <- st_drop_geometry(df10)[, vars_needed]

# rows with complete data
keep_rows <- complete.cases(attr_only)

# subset the sf object
df10c <- df10[keep_rows, ]

# rebuild neighbors + weights
nb10 <- poly2nb(df10c)
lw10 <- nb2listw(nb10, style = "W", zero.policy = TRUE)

attr_only <- st_drop_geometry(df10)[, vars_needed]
keep_rows <- complete.cases(attr_only)

df10c <- df10[keep_rows, ]

# 2. Rebuild neighbors and weights *on df10c*
nb10c  <- poly2nb(df10c)
lw10c  <- nb2listw(nb10c, style = "W", zero.policy = TRUE)

# spatial lag model
slag10 <- lagsarlm(
  log_misd_rate_10k_rc2 ~ 
    NYCHA +
    gentrify_status +
    pct_black +
    pct_hispanic +
    cd_index +
    log_violent_rate +
    log.311.rate,
  data        = df10c,
  listw       = lw10,
  method      = "Matrix",
  zero.policy = TRUE
)

summary(slag10)

slag20 <- lagsarlm(
  log_misd_rate_10k_rc2 ~ 
    NYCHA +
    gentrify_status +
    pct_black +
    pct_hispanic +
    cd_index +
    log_violent_rate +
    log.311.rate,
  data        = df20,
  listw       = lw20,
  method      = "Matrix",
  zero.policy = TRUE
)

summary(slag20)

##Diagnose NAN problems of spatial autocorrelation
moran.test(df20$pct_black, lw20)
moran.test(df20$pct_hispanic, lw20)
moran.test(df20$cd_index, lw20)
moran.test(as.numeric(df20$gentrify_status), lw20)

sem20 <- errorsarlm(
  log_misd_rate_10k_rc2 ~ 
    NYCHA +
    gentrify_status +
    pct_black +
    pct_hispanic +
    cd_index +
    log_violent_rate +
    log.311.rate,
  data  = df20,
  listw = lw20,
  method = "Matrix",
  zero.policy = TRUE
)
summary(sem20)

##Spatial Durbin Models Run DF10 and DF20 first
##sdm1 <- lagsarlm(
  log_misd_rate_10k_rc2 ~ 
    NYCHA +
    gentrify_status +
    pct_black +
    pct_hispanic +
    cd_index +
    log_violent_rate +
    log.311.rate,
  data = df,
  listw = lw,
  type = "mixed"
)
summary(sdm1)

sdm10 <- lagsarlm(
  log_misd_rate_10k_rc2 ~ 
    NYCHA +
    gentrify_status +
    pct_black +
    pct_hispanic +
    cd_index +
    log_violent_rate +
    log.311.rate,
  data        = df10c,
  listw       = lw10c,
  type        = "mixed",
  method      = "Matrix",
  zero.policy = TRUE
)

summary(sdm10)

imp_sdm10 <- impacts(
  sdm10,
  listw       = lw10c,
  R           = 500,        # number of simulations (200 for speed, 500 for class-quality)
  zero.policy = TRUE
)

summary(imp_sdm10)

sdm10 <- lagsarlm(
  log_misd_rate_10k_rc2 ~ 
    NYCHA +
    gentrify_status +
    pct_black +
    pct_hispanic +
    cd_index +
    log_violent_rate +
    log.311.rate,
  data = df10c,
  listw = lw10,
  type = "mixed"
)
summary(sdm10)

sdm20 <- lagsarlm(
  log_misd_rate_10k_rc2 ~ 
    NYCHA +
    gentrify_status +
    pct_black +
    pct_hispanic +
    cd_index +
    log_violent_rate +
    log.311.rate,
  data = df20,
  listw = lw20,
  type = "mixed"
)
summary(sdm20)



# Indirect, direct, total effects
impacts_sdm1 <- impacts(sdm1, listw = lw, R = 1000)
summary(impacts_sdm1)

library(sf)
library(plm)

##Fixed Effects Models
panel_df <- st_drop_geometry(NYCHA_paper_final_data)

# make sure ordering is sensible
panel_df <- panel_df[order(panel_df$GEOID, panel_df$acs_year_tr), ]

##Normal Fixed Effects Model
fe_panel <- plm(
  log_misd_rate_10k_rc2 ~ 
    NYCHA +
    gentrify_status +
    pct_black +
    pct_hispanic +
    cd_index +
    log_violent_rate +
    log.311.rate,
  data  = panel_df,
  index = c("GEOID", "acs_year_tr"),
  model = "within"   # GEOID fixed effects
)

##Spatial Fixed Effects Model
spfe_panel <- spml(
  log_misd_rate_10k_rc2 ~ 
    NYCHA +
    gentrify_status +
    pct_black +
    pct_hispanic +
    cd_index +
    log_violent_rate +
    log.311.rate,
  data         = panel_df,
  index        = c("GEOID", "acs_year_tr"),
  listw        = lw,       # built on a reference year ordering of GEOIDs
  model        = "within",   # tract fixed effects
  lag          = TRUE,       # spatial lag of Y
  spatial.error = "none",    # or "b" / "kk" for spatial error if you want
  method       = "ml"
)

summary(spfe_panel)


summary(fe_panel)

##OTher tools
library(dplyr)
library(sf)

df20s <- df20 %>%
  mutate(
    pct_black_s = scale(pct_black),
    pct_hispanic_s = scale(pct_hispanic),
    cd_index_s = scale(cd_index)
  )

df20 <- df20 %>%
  mutate(
    z_female_headed = as.numeric(scale(pct_female_headed)),
    z_public_assist = as.numeric(scale(pct_public_assist)),
    z_black         = as.numeric(scale(pct_black)),
    z_renter_share  = as.numeric(scale(renter_share))
  )

##Gentrification as a Binary Tool
df20$gent_binary <- ifelse(df20$gentrify_status == "Gentrified", 1, 0)

slag20_bin <- lagsarlm(
  log_misd_rate_10k_rc2 ~ 
    NYCHA +
    gent_binary +
    pct_black +
    pct_hispanic +
    cd_index +
    log_violent_rate +
    log.311.rate,
  data  = df20,
  listw = lw20,
  method = "Matrix",
  zero.policy = TRUE
)
summary(slag20_bin)



