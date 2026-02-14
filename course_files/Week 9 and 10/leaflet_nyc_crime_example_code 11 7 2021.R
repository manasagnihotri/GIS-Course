

#Practice Leaflet With NYC Crime Data

library(leaflet)

#import nyc crime subset csv

crime <- read.csv(file.choose(), header=TRUE, stringsAsFactors=FALSE)

#Create basemap

leaflet(crime) %>%
  setView(lng = -73.98928, lat = 40.75042, zoom = 10) %>%
  addProviderTiles("CartoDB.Positron", options = providerTileOptions(noWrap = TRUE))

#Map with crimes per latitude longitude location

leaflet(crime) %>%
  setView(lng = -73.98928, lat = 40.75042, zoom = 10) %>%
  addProviderTiles("CartoDB.Positron", options = providerTileOptions(noWrap = TRUE)) %>%
  addCircleMarkers(
    lng=~Longitude, # Longitude coordinates
    lat=~Latitude, # Latitude coordinates
    stroke=FALSE, # Circle stroke
    fillOpacity=0.5, # Circle Fill Opacity
    # Popup content
    popup=~paste(
        "<b>", OFNS_DESC, "</b><br/>",
        "Location: ", as.character(PREM_TYP_D), "<br/>",
        "Desc.: ", as.character(PD_DESC), "<br/>"
      ))


library(RColorBrewer)
#Use colorFactor function to create color palette not tied to numeric values
color <- colorFactor(topo.colors(5), crime$BORO_NM)

#Example using brewer.pal color palette:
#color <- colorFactor(brewer.pal(7, "Spectral"), crime$CR)


map <- leaflet(crime) %>%
  setView(lng = -73.98928, lat = 40.75042, zoom = 10) %>%
  addProviderTiles("CartoDB.Positron", options = providerTileOptions(noWrap = TRUE)) %>%
  addCircleMarkers(
    lng=~Longitude,
    lat=~Latitude,
    stroke=FALSE,
    fillOpacity=.8,
    color=~color(BORO_NM), # color circle by NYC Boroughs
    popup=~paste(
      "<b>", OFNS_DESC, "</b><br/>",
      "Location: ", as.character(PREM_TYP_D), "<br/>",
      "Desc.: ", as.character(PD_DESC), "<br/>"
    ))
  

map




#Add legend to bottom left part of map
map <- leaflet(crime) %>%
  setView(lng = -73.98928, lat = 40.75042, zoom = 10) %>%
  addProviderTiles("CartoDB.Positron", options = providerTileOptions(noWrap = TRUE)) %>%
  addCircleMarkers(
    lng=~Longitude,
    lat=~Latitude,
    radius=2,
    stroke=FALSE,
    fillOpacity=.8,
    color=~color(BORO_NM), # color circle by NYC Boroughs
    popup=~paste(
      "<b>", OFNS_DESC, "</b><br/>",
      "Location: ", as.character(PREM_TYP_D), "<br/>",
      "Desc.: ", as.character(PD_DESC), "<br/>"
    )
  )%>%
  addLegend(
    "bottomleft", # Legend position
    pal=color, # color palette
    values=~BORO_NM, # legend values
    opacity = 1,
    title="Borough Where Crime Committed"
  )

map


#Add group by reference to data column
map <- leaflet(crime) %>%
  setView(lng = -73.98928, lat = 40.75042, zoom = 10) %>%
  addProviderTiles("CartoDB.Positron", options = providerTileOptions(noWrap = TRUE)) %>%
  addCircleMarkers(
    lng=~Longitude,
    lat=~Latitude,
    radius=5,
    stroke=FALSE,
    fillOpacity=0.5,
    color=~color(BORO_NM), # color circle by crime type
    popup=~paste(
      "<b>", OFNS_DESC, "</b><br/>",
      "Location: ", as.character(PREM_TYP_D), "<br/>",
      "Desc.: ", as.character(PD_DESC), "<br/>"
    ), group=crime$BORO_NM)%>%
  addLayersControl(
    overlayGroups = crime$BORO_NM,
    options = layersControlOptions(position="bottomleft",collapsed = FALSE)
  )

map

#One extra option is to use markerClusters.  Here is a quick example:

leaflet(crime) %>% addTiles() %>% addMarkers(
  clusterOptions = markerClusterOptions()
)