##Geocoding

# -------------------------------
# Step 1: Install & Load Packages
# -------------------------------
# Run these lines once if not already installed
install.packages("tidyverse")
install.packages("tidygeocoder")
install.packages("sf")

library(tidyverse)
library(tidygeocoder)
library(sf)
##Install Packages
install.packages("spdep")
install.packages("spatstat")
install.packages("ggplot2")
install.packages("dplyr")
install.packages("sp")
install.packages("data.table")
install.packages("tmap")
install.packages("leaflet")

# -------------------------------
# Step 2: Read the CSV file
# -------------------------------
polling <- read_csv("~/Downloads/Week_6_export (1)/Atlanta Polling Places - Sheet1(1).csv")

# Look at the column names
colnames(polling)

# -------------------------------
# Step 3: Create a full address column
# -------------------------------
# Adjust these column names to match your file.
# For example, if your columns are named "Address", "City", and "Zip"
polling <- polling %>%
  mutate(full_address = paste(Street, City, State, `Zip Code`, sep = ", "))

# -------------------------------
#Step 4: Geocode addresses
# -------------------------------
# This uses the U.S. Census free geocoder
polling_geo <- polling %>%
  geocode(address = full_address, method = "census", full_results = FALSE)

# -------------------------------
# Step 5: Convert to spatial points
# -------------------------------
polling_sf <- polling_geo %>%
  st_as_sf(coords = c("long", "lat"), crs = 4326, remove = FALSE)

polling_sf <- polling_geo %>%
  filter(!is.na(lat) & !is.na(long)) %>%    # keep only rows with coordinates
  st_as_sf(coords = c("long", "lat"), crs = 4326, remove = FALSE)

# -------------------------------
# Step 6: Save your results
# -------------------------------
# Save as a regular CSV
write_csv(polling_geo, "polling_geocoded.csv")

# Save as a spatial file for mapping (QGIS or ArcGIS)
st_write(polling_sf, "polling_geocoded.gpkg", delete_dsn = TRUE)

# -------------------------------
# tep 7: Check the results
# -------------------------------
print(polling_geo)

# -------------------------------
# Set your Google API key
#   (Enable “Geocoding API” in Google Cloud; billing must be on)
# -------------------------------
Sys.setenv(GOOGLE_GEOCODE_KEY = "YOUR_GOOGLE_API_KEY_HERE")

# -------------------------------
# 🧾 Read your file
# -------------------------------
polling <- read_csv("Atlanta Polling Places - Sheet1(1).csv")

# Peek at columns to confirm names:
colnames(polling)

# -------------------------------
# Make a single-line address
#   (Edit column names below to match your file)
# -------------------------------
# Example assumes columns named Address, City, State, Zip
polling <- polling %>%
  mutate(full_address = paste(Address, City, State, Zip, sep = ", "))

# -------------------------------
# Geocode with Google
# -------------------------------
polling_google <- polling %>%
  geocode(address    = full_address,
          method     = "google",
          api_key    = Sys.getenv("GOOGLE_GEOCODE_KEY"),
          full_results = FALSE)

# -------------------------------
#  Convert to sf points (skip NAs)
# -------------------------------
polling_google_sf <- polling_google %>%
  filter(!is.na(lat) & !is.na(long)) %>%
  st_as_sf(coords = c("long", "lat"), crs = 4326, remove = FALSE)

# -------------------------------
# Save outputs
# -------------------------------
write_csv(polling_google, "polling_geocoded_google.csv")
st_write(polling_google_sf, "polling_geocoded_google.gpkg", delete_dsn = TRUE)

# Optional quick checks
sum(is.na(polling_google$lat))        # how many unmatched?
head(polling_google_sf)

##Building Interactive Maps

install.packages("data.table")
library(data.table)
#insert your working directory (change based on your working directory)
setwd("~/Downloads/Lab_7_export")


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

# Count arrests per Census Tracts code
arrest_counts <- arrests_by_tract %>%
  group_by(GEOID) %>%
  summarise(arrests = n())

arrest_counts_df <- st_drop_geometry(arrest_counts)

# Perform regular data join
nyc_tracts_sf <- left_join(nyc_tracts, arrest_counts_df, by = "GEOID")

nyc_tracts_sf$arrests <- as.numeric(as.character(nyc_tracts_sf$arrests))

# Reproject to WGS84 (lat-long)
nyc_tracts_sf <- st_transform(nyc_tracts_sf, crs = 4326)

pal <- colorNumeric(
  palette = c("lightblue", "yellow", "red"),  # Improved readable palette
  domain = nyc_tracts_sf$arrests)

tm_shape(nyc_tracts_sf) +
  tm_polygons(
    col = "arrests",
    palette = "YlOrRd",      # or any color palette
    style = "quantile",      # or "pretty", "jenks", etc.
    n = 5,                   # number of bins
    title = "Arrest Counts"
  ) +
  tm_borders(col = "black") +
  tm_layout(
    title = "Marijuana Arrest Counts by Census Tract",
    legend.outside = TRUE,
    frame = FALSE
  )

leaflet(nyc_tracts_sf) %>%
  addProviderTiles("CartoDB.Positron") %>%  # Clean map style
  addPolygons(
    fillColor = ~pal(arrests),
    fillOpacity = 0.6,  # Reduced opacity for readability
    color = "black",    # Dark border for visibility
    weight = 1,
    popup = ~paste("Census Tract: ", GEOID, "<br>Arrests: ", arrests)
  ) %>%
  addLegend(
    pal = pal,
    values = ~arrests,
    title = "Arrest Counts",
    position = "bottomright",
    bins = 5  # Adjust bins for clarity
  )

