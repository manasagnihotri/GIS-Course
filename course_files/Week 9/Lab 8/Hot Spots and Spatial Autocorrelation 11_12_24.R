install.packages(c("sf", "spdep", "spatstat", "ggplot2"))

# Load libraries
##Install Packages
install.packages("sf")
install.packages("spdep")
install.packages("spatstat")
install.packages("ggplot2")
install.packages("dplyr")
install.packages("sp")
install.packages("data.table")
install.packages("tmap")
install.packages("leaflet")

library(sf)        # For handling spatial data
library(spdep)     # For spatial autocorrelation (Moran's I, LISA)
library(spatstat)  # For hotspot analysis (Getis-Ord Gi*)
library(ggplot2)   # For mapping
library(dplyr)     # Data manipulation
library(tmap)    # Visualizing maps
library(data.table)
library(sp)
library(tmap)
library(leaflet)

#insert your working directory (change based on your working directory)
setwd("~/Downloads/Lab 7")

# Load arrest data (e.g., csv file with lat/lon or zip codes)
arrests<- fread("july_week_arrest_data.csv", stringsAsFactors = F, data.table = F)

# Load NYC ZIP code shapefile
nyc_tracts <- st_read("nyct2020.shp")  # Ensure this is in the correct projection

# Inspect the data (optional)
print(nyc_tracts)

# Basic map using tmap
tm_shape(nyc_tracts) +
  tm_borders() 

invalid_geometries <- st_is_valid(nyc_tracts)
if (any(!invalid_geometries)) {
  # Attempt to fix invalid geometries
  nyc_tracts <- st_make_valid(nyc_tracts)
}

# Convert arrest data into an sf object
arrests_sf <- st_as_sf(arrests, coords = c("Longitude", "Latitude"), crs = 4326)

# Ensure both datasets are in the same CRS (Coordinate Reference System)
arrests_sf <- st_transform(arrests_sf, st_crs(nyc_tracts))

# Spatial join: join arrests to tract
arrests_by_tract <- st_join(nyc_tracts, arrests_sf, join = st_intersects)

# Count arrests per ZIP code
arrest_counts <- arrests_by_tract %>%
  group_by(GEOID) %>%
  summarise(arrests = n())

nyc_tracts_sf <- st_join(nyc_tracts, arrest_counts)

nyc_tracts_sf$arrests <- as.numeric(as.character(nyc_tracts_sf$arrests))

# Reproject to WGS84 (lat-long)
nyc_tracts_sf <- st_transform(nyc_tracts_sf, crs = 4326)

pal <- colorNumeric(
  palette = c("lightblue", "yellow", "red"),  # Improved readable palette
  domain = nyc_tracts_sf$arrests)

leaflet(nyc_tracts_sf) %>%
  addProviderTiles("CartoDB.Positron") %>%  # Clean map style
  addPolygons(
    fillColor = ~pal(arrests),
    fillOpacity = 0.6,  # Reduced opacity for readability
    color = "black",    # Dark border for visibility
    weight = 1,
    popup = ~paste("Census Tract: ", GEOID.x, "<br>Arrests: ", arrests)
  ) %>%
  addLegend(
    pal = pal,
    values = ~arrests,
    title = "Arrest Counts",
    position = "bottomright",
    bins = 5  # Adjust bins for clarity
  )

nyc_tracts_sf <- st_as_sf(nyc_tracts)

# Remove empty geometries
nyc_tracts_sf <- nyc_tracts_sf[!st_is_empty(nyc_tracts_sf), ]

# Build neighborhood list (sf works directly)
neighbors <- poly2nb(nyc_tracts_sf, queen = TRUE)

# Identify isolated tracts (no neighbors)
no_neighbors <- which(card(neighbors) == 0)

if (length(no_neighbors) > 0) {
  cat("Isolated units found:\n")
  print(no_neighbors)
  
  # Remove them directly from sf object
  nyc_tracts_sf_clean <- nyc_tracts_sf[-no_neighbors, ]
  
  # Clean arrest data
  arrest_counts_clean <- arrest_counts %>% 
    filter(GEOID %in% nyc_tracts_sf_clean$GEOID)
  
  # Rebuild neighbors and weights
  neighbors_clean <- poly2nb(nyc_tracts_sf_clean, queen = TRUE)
  weights_clean <- nb2listw(neighbors_clean, style = "W", zero.policy = TRUE)
  
} else {
  cat("No isolated units.\n")
  
  nyc_tracts_sf_clean <- nyc_tracts_sf
  arrest_counts_clean <- arrest_counts
  weights_clean <- nb2listw(neighbors, style = "W", zero.policy = TRUE)
}

nyc_tracts_sp_clean <- st_as_sf(nyc_tracts_sf_clean)

# Run Getis-Ord Gi* hotspot analysis on the cleaned data
gi_star <- localG(arrest_counts_clean$arrests, weights_clean, zero.policy = TRUE)

# Add Gi* results to the cleaned shapefile and classify as hotspots/coldspots
nyc_tracts_sp_clean$gi_star <- as.numeric(gi_star)

# Inspect results
summary(nyc_tracts_sp_clean$gi_star)

# (Optional) Categorize the Gi* scores into hotspots and coldspots based on z-scores
nyc_tracts_sp_clean$hotspot <- cut(nyc_tracts_sp_clean$gi_star, 
                                   breaks = c(-Inf, -1.96, 1.96, Inf), 
                                   labels = c("Coldspot", "Not significant", "Hotspot"))

tmap_mode("plot")

tm_shape(nyc_tracts_sp_clean) +
  tm_borders() +
  tm_polygons(
    fill = "gi_star",
    fill.scale = tm_scale(values = "rd_bu"),  # updated palette syntax
    fill.legend = tm_legend(title = "Hotspot Analysis (Gi*)")
  ) +
  tm_title("Census Tracts: Arrest Hotspots (Getis-Ord Gi*)") +
  tm_layout(legend.position = c("left", "bottom"))

### Step 1: Global Moran's I Calculation ###

# Calculate Global Moran's I
moran_global <- moran.test(arrest_counts_clean$arrests, weights_clean, zero.policy = TRUE)

# Display the Moran's I results
cat("Global Moran's I:\n")
print(moran_global)

### Step 2: Local Moran's I (LISA) Calculation ###

# Calculate Local Moran's I (LISA)
local_moran <- localmoran(arrest_counts_clean$arrests, weights_clean, zero.policy = TRUE)

# Extract the relevant results from the Local Moran's I output
nyc_tracts_sp_clean$local_moran_I <- local_moran[, 1]  # Moran's I value
nyc_tracts_sp_clean$local_moran_p <- local_moran[, 5]  # p-value

# Classify LISA results based on significance and type of association
# High-High (HH): High values surrounded by high values (positive autocorrelation)
# Low-Low (LL): Low values surrounded by low values (positive autocorrelation)
# High-Low (HL): High values surrounded by low values (negative autocorrelation, spatial outlier)
# Low-High (LH): Low values surrounded by high values (negative autocorrelation, spatial outlier)
nyc_tracts_sp_clean$lisa_cluster <- NA
nyc_tracts_sp_clean$lisa_cluster[nyc_tracts_sp_clean$local_moran_I > 0 & nyc_tracts_sp_clean$local_moran_p < 0.05] <- "High-High"
nyc_tracts_sp_clean$lisa_cluster[nyc_tracts_sp_clean$local_moran_I < 0 & nyc_tracts_sp_clean$local_moran_p < 0.05] <- "Low-Low"
nyc_tracts_sp_clean$lisa_cluster[nyc_tracts_sp_clean$local_moran_I > 0 & nyc_tracts_sp_clean$local_moran_p >= 0.05] <- "High-Low"
nyc_tracts_sp_clean$lisa_cluster[nyc_tracts_sp_clean$local_moran_I < 0 & nyc_tracts_sp_clean$local_moran_p >= 0.05] <- "Low-High"

### Step 3: Moran's I Scatter Plot ###

# Create a Moran scatter plot
moran_plot <- moran.plot(arrest_counts_clean$arrests, weights_clean, zero.policy = TRUE)

### Step 4: Map Visualization using tmap ###

# Set tmap mode for interactive maps
tmap_mode("view")

# Global Moran's I Map (Arrests with Gi* hotspots/coldspots)

tm_shape(nyc_tracts_sp_clean) +
  tm_polygons(
    fill = "gi_star",
    fill.scale = tm_scale_intervals(values = "brewer.rd_yl_bu", n = 5, style = "pretty", midpoint = NA),
    fill.legend = tm_legend(title = "Gi* Scores")
  ) +
  tm_borders() +
  tm_title("Gi* Hotspot Analysis of Arrests")


# Local Moran's I (LISA) Map
tm_shape(nyc_tracts_sp_clean) +
  tm_polygons(
    fill = "lisa_cluster",
    fill.scale = tm_scale(values = c("red", "blue", "orange", "green")),
    fill.legend = tm_legend(title = "LISA Cluster Type"),
    labels = c("High-High", "Low-Low", "High-Low", "Low-High")
  ) +
  tm_borders() +
  tm_title("Local Moran's I (LISA) of Arrests")

