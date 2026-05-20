

#Practice Leaflet With NYC Crime Data

library(leaflet)

#import data

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
    lng=~longitude, # Longitude coordinates
    lat=~latitude, # Latitude coordinates
    radius=~TOT, # Total count
    stroke=FALSE, # Circle stroke
    fillOpacity=0.5, # Circle Fill Opacity
    # Popup content
    popup=~paste(
      "<b>", CR, "</b><br/>",
      "count: ", as.character(TOT), "<br/>",
      "date: ", as.character(MO), "/", as.character(YR)
    ))


library(RColorBrewer)
#Use colorFactor function to create color palette not tied to numeric values
color <- colorFactor(topo.colors(7), crime$CR)

#Example using brewer.pal color palette:
#color <- colorFactor(brewer.pal(7, "Spectral"), crime$CR)


map <- leaflet(crime) %>%
  setView(lng = -73.98928, lat = 40.75042, zoom = 10) %>%
  addProviderTiles("CartoDB.Positron", options = providerTileOptions(noWrap = TRUE)) %>%
  addCircleMarkers(
    lng=~longitude,
    lat=~latitude,
    radius=~TOT,
    stroke=FALSE,
    fillOpacity=0.5,
    color=~color(CR), # color circle by crime type
    popup=~paste(
      "<b>", CR, "</b><br/>",
      "count: ", as.character(TOT), "<br/>",
      "date: ", as.character(MO), "/", as.character(YR)
    )
  )

map




#Add legend to bottom left part of map
map <- leaflet(crime) %>%
  setView(lng = -73.98928, lat = 40.75042, zoom = 10) %>%
  addProviderTiles("CartoDB.Positron", options = providerTileOptions(noWrap = TRUE)) %>%
  addCircleMarkers(
    lng=~longitude,
    lat=~latitude,
    radius=~TOT,
    stroke=FALSE,
    fillOpacity=0.5,
    color=~color(CR), # color circle by crime type
    popup=~paste(
      "<b>", CR, "</b><br/>",
      "count: ", as.character(TOT), "<br/>",
      "date: ", as.character(MO), "/", as.character(YR)
  )
  )%>%
  addLegend(
    "bottomleft", # Legend position
    pal=color, # color palette
    values=~CR, # legend values
    opacity = 1,
    title="Type of Crime Committed"
  )


#Add group by reference to data column
map <- leaflet(crime) %>%
  setView(lng = -73.98928, lat = 40.75042, zoom = 10) %>%
  addProviderTiles("CartoDB.Positron", options = providerTileOptions(noWrap = TRUE)) %>%
  addCircleMarkers(
    lng=~longitude,
    lat=~latitude,
    radius=~TOT,
    stroke=FALSE,
    fillOpacity=0.5,
    color=~color(CR), # color circle by crime type
    popup=~paste(
      "<b>", CR, "</b><br/>",
      "count: ", as.character(TOT), "<br/>",
      "date: ", as.character(MO), "/", as.character(YR)
    ), group=crime$CR)%>%
   addLayersControl(
    overlayGroups = crime$CR,
    options = layersControlOptions(position="bottomleft",collapsed = FALSE)
  )


#One extra option is to use markerClusters.  Here is a quick example:

leaflet(crime) %>% addTiles() %>% addMarkers(
  clusterOptions = markerClusterOptions()
)
