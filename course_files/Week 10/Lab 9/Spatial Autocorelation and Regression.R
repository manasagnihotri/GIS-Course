# --- 1. SETUP: Load Libraries ---
# install.packages(c("sf", "dplyr", "spdep")) # Run this only if needed
library(sf)
library(dplyr)
library(spdep)

# --- 2. DATA PREPARATION, MERGE, AND CLEANING ---

# Define file paths (ADJUST AS NEEDED)
shapefile_path <- "/Users/egrimsley/Downloads/tl_2020_17_tract/tl_2020_17_tract.shp"
csv_path <- "SVI_2022_US.csv"

# Load data
il_tracts_sf <- st_read(shapefile_path)
svi_data_df <- read.csv(csv_path)

# Prepare SVI data: Create GeoID key and select final variables
svi_data_prepared <- svi_data_df %>%
  mutate(GEOID = sprintf("%011s", FIPS)) %>%
  select(
    GEOID, 
    RPL_THEMES,   ## DV
    EP_POV150, EP_AFAM, EP_NOHSDP, # Primary Controls
    EP_HBURD,     # <-- Housing Burden Percent
    EPL_DISABL, EPL_MINRTY, EPL_NOVEH # Secondary Controls
  )

il_tracts_sf <- il_tracts_sf %>%
  mutate(GEOID = as.character(GEOID))

# Inner Join to match only IL tracts and clean negative SVI flags
final_data <- il_tracts_sf %>%
  inner_join(svi_data_prepared, by = "GEOID") %>%
  # Replace negative SVI flags (-999) with NA
  mutate(RPL_THEMES = if_else(RPL_THEMES < 0, NA_real_, RPL_THEMES)) %>%
  # Filter out any rows with missing data for the dependent variable
  filter(!is.na(RPL_THEMES))

print(paste("Final Merged Tracts (Cleaned):", nrow(final_data)))

# --- 3. SPATIAL WEIGHTS MATRIX (W) ---

# 1. Create neighbor list using Queen Contiguity
il_nb <- poly2nb(final_data, queen = TRUE)

# 2. Create row-standardized spatial weights list
il_listw <- nb2listw(il_nb, style = "W")

# --- 4. GLOBAL SPATIAL AUTOCORRELATION (Moran's I) ---

moran_test <- moran.test(final_data$RPL_THEMES, il_listw)

cat("\n--- Global Moran's I Test for RPL_THEMES ---\n")
print(moran_test)

# --- 5. LOCAL SPATIAL AUTOCORRELATION (LISA) ---

# Calculate Local Moran's I
# The output is a matrix with Local Ii, E(Ii), Var(Ii), Z-score, and p-value
local_moran_results <- localmoran(final_data$RPL_THEMES, il_listw)

# Add the Local I and Z-score (remains correct)
final_data$local_I <- local_moran_results[, "Ii"]
final_data$local_Z <- local_moran_results[, "Z.Ii"]

# CORRECTED p-value line using the verified column name
final_data$local_p <- local_moran_results[, "Pr(z != E(Ii))"]

# Verify the successful creation of the new column
print(head(final_data[, c("RPL_THEMES", "local_I", "local_p")]))

# Identify significantly clustered tracts (e.g., p < 0.05)
final_data <- final_data %>%
  mutate(
    # Get the spatially lagged variable (W*Y) for quadrant assignment
    lag_RPL_THEMES = lag.listw(il_listw, RPL_THEMES),
    
    # Assign Quadrant based on value (RPL_THEMES) and spatial lag (W*Y)
    quadrant = case_when(
      # High-High (HH): High vulnerability surrounded by high vulnerability
      RPL_THEMES >= mean(RPL_THEMES) & lag_RPL_THEMES >= mean(RPL_THEMES) & local_p <= 0.05 ~ "High-High Cluster",
      # Low-Low (LL): Low vulnerability surrounded by low vulnerability
      RPL_THEMES < mean(RPL_THEMES) & lag_RPL_THEMES < mean(RPL_THEMES) & local_p <= 0.05 ~ "Low-Low Cluster",
      # High-Low (HL): High vulnerability surrounded by low vulnerability (Outlier)
      RPL_THEMES >= mean(RPL_THEMES) & lag_RPL_THEMES < mean(RPL_THEMES) & local_p <= 0.05 ~ "High-Low Outlier",
      # Low-High (LH): Low vulnerability surrounded by high vulnerability (Outlier)
      RPL_THEMES < mean(RPL_THEMES) & lag_RPL_THEMES >= mean(RPL_THEMES) & local_p <= 0.05 ~ "Low-High Outlier",
      # Not Significant
      TRUE ~ "Not Significant"
    )
  )

# install.packages("tmap") # Run this if needed
library(tmap)

# --- 1. Define Colors (The only complex part, kept consistent) ---
lisa_colors <- c(
  "High-High Cluster" = "#FF0000",
  "Low-Low Cluster" = "#0000FF",
  "High-Low Outlier" = "#A020F0",
  "Low-High Outlier" = "#00FF00",
  "Not Significant" = "#D3D3D3"
)

# --- 2. Create the Map using tmap syntax ---
# tmap works by layering: tm_shape() -> tm_fill() -> tm_borders() -> tm_layout()

lisa_map_simple <- tm_shape(final_data) +
  # Fill the tracts based on the 'quadrant' column, using the custom colors
  tm_fill(
    col = "quadrant",
    palette = lisa_colors,
    title = "LISA Cluster Type",
    # Define the order of the legend items
    popup.vars = c("RPL_THEMES", "quadrant")
  ) +
  # Add thin white borders for visual separation
  tm_borders(col = "white", lwd = 0.5) +
  # Set a simple layout and title
  tm_layout(
    title = "LISA Map of Overall Social Vulnerability in Illinois",
    title.size = 1.1,
    legend.outside = TRUE,
    frame = FALSE # Removes the map frame
  )
cat("\n--- Local Moran's I: Clustered Tract Counts ---\n")

lisa_map_simple

final_data %>% st_drop_geometry() %>% count(quadrant)

# --- Best Practice for Labs: Save to File ---

# Save the map directly to a file (recommended for reports/submissions)
# Set a high DPI (dots per inch) for good quality
tmap_save(
  tm = lisa_map_simple, 
  filename = "IL_LISA_Cluster_Map.png", 
  width = 8, 
  height = 10, 
  units = "in", 
  dpi = 300
)

cat("Map saved successfully to IL_LISA_Cluster_Map.png. Check your working directory.")

# --- 6. REGRESSION ANALYSIS ---

# Define the final model formula
svi_formula <- RPL_THEMES ~ EP_POV150 + EP_AFAM + EP_NOHSDP + EPL_DISABL + EPL_MINRTY + EPL_NOVEH + EP_HBURD

# 1. OLS Regression & LM Tests
ols_model <- lm(svi_formula, data = final_data)

cat("\n--- OLS Regression Summary ---\n")
summary(ols_model)

# Test OLS residuals for spatial autocorrelation (LM tests to choose model)
lm_test <- lm.RStests(ols_model, il_listw)

cat("\n--- Lagrange Multiplier Tests for Spatial Dependence ---\n")
print(lm_test)

# --- 1. OLS Regression (Foundation) ---
# Assuming 'final_data', 'svi_formula', and 'il_listw' are already defined.
ols_model <- lm(svi_formula, data = final_data)

cat("====================================================\n")
cat("          1. OLS (Non-Spatial) MODEL SUMMARY        \n")
cat("====================================================\n")
print(summary(ols_model))

# Run LM Tests (Used for theoretical comparison)
lm_test <- lm.RStests(ols_model, il_listw)

# --- 2. Spatial Lag Model (SLM) ---
# Models substantive dependence (spatial spillover: Y in neighbor affects Y here)
slm_model <- lagsarlm(svi_formula, data = final_data, listw = il_listw, method = "Matrix")

cat("\n====================================================\n")
cat("          2. SPATIAL LAG MODEL (SLM) SUMMARY        \n")
cat("====================================================\n")
print(summary(slm_model))

# --- 3. Spatial Error Model (SEM) ---
# Models nuisance dependence (omitted but spatially correlated variables)
#sem_model <- errorsarlm(svi_formula, data = final_data, listw = il_listw)
sem_model <- errorsarlm(svi_formula, data = final_data, listw = il_listw, method = "Matrix")

cat("\n====================================================\n")
cat("          3. SPATIAL ERROR MODEL (SEM) SUMMARY      \n")
cat("====================================================\n")
print(summary(sem_model))


output_file_path <- "IL_SVI_Final_Analysis.shp"

# --- 1. Rename Columns to Meet 10-Character Limit ---
# The final_data object is converted to a simple data frame for renaming, 
# then saved back to the spatial object before writing.

final_data_shp <- final_data %>%
  # Select and rename columns to 10 characters or less
  select(
    GEOID,
    RPL_THEMES, # Overall SVI Rank
    POV150 = EP_POV150,   # % Poverty
    AFAM = EP_AFAM,       # % Black/African American
    NOHSDP = EP_NOHSDP,   # % No High School Diploma
    Hous_Bur = EP_HBURD,
    DISABL_R = EPL_DISABL, # Disability Rank
    MINRTY_R = EPL_MINRTY, # Minority Rank
    NOVEH_R = EPL_NOVEH,   # No Vehicle Rank
    local_I,              # Local Moran's I stat
    quadrant              # LISA Cluster Type
  )

# --- 2. Write the Shapefile ---
st_write(
  obj = final_data_shp,
  dsn = output_file_path,
  driver = "ESRI Shapefile", # Explicitly set the driver
  delete_dsn = TRUE           # Overwrite if file exists
)

cat(paste("Successfully saved the analyzed data as a Shapefile to:", output_file_path, "\n"))
