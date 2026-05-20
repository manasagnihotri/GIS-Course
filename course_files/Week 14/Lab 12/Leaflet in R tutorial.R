#using leaflet to create publishable interactive maps

install.packages("leaflet")
# to install the development version from Github, run
# devtools::install_github("rstudio/leaflet")

#Create a basic map 
library(leaflet)

m <- leaflet() %>%
  addTiles() %>%  # Add default OpenStreetMap map tiles
  addMarkers(lng=174.768, lat=-36.852, popup="The birthplace of R")
m  # Print the map

#equivalent code without magrittr pipe operator code
m <- leaflet()
m <- addTiles(m)
m <- addMarkers(m, lng=174.768, lat=-36.852, popup="The birthplace of R")
m

#The leaflet() function creates an html map widget that you then
#build using more functions like addTiles(), addMarkers, and more.

# add some circles to a map

#make some Latitude and Longitude data
df = data.frame(Lat = 1:10, Long = rnorm(10))

#view data
df

#create leaflet widget and map circles
leaflet(df) %>% addCircles()

#note that columns for lat and long automatically used above, but
#you can also call specific columns in your data in the following manner...
leaflet(df) %>% addCircles(lng = ~Long, lat = ~Lat)


df = data.frame(
  lat = rnorm(100),
  lng = rnorm(100),
  size = runif(100, 5, 20),
  color = sample(colors(), 100)
)
m = leaflet(df) %>% addTiles()
#add a circle marker rather than a circle, radius = meters for circles
#and pixels for circle markers.  Pixels are constant with zoom level

m %>% addCircleMarkers(radius = ~size, color = ~color, fill = TRUE)
#squiggly lines (aka the tilde) are shortcuts to variables in 
#df dataset
m %>% addCircleMarkers(radius = runif(100, 4, 10), color = c('red'))
#randomly created size for radius.


#Adding Basemaps to your widget with setView and the addTiles() function
#addTiles defaults to open street map base map

m <- leaflet() %>% setView(lng = -71.0589, lat = 42.3601, zoom = 12)
m %>% addTiles()

#setView centers your map on longitude and latitude and sets the zoom extent

#Changing Basemaps...
m <- leaflet() %>% setView(lng = -71.0589, lat = 42.3601, zoom = 12)
m %>% addProviderTiles(providers$Stamen.Toner)


m <- leaflet() %>% setView(lng = -71.0589, lat = 42.3601, zoom = 12)
m %>% addProviderTiles(providers$CartoDB.Positron)

m <- leaflet() %>% setView(lng = -71.0589, lat = 42.3601, zoom = 12)
m %>% addProviderTiles(providers$Stamen.Watercolor)

#other basemaps to check out:
#http://leaflet-extras.github.io/leaflet-providers/preview/index.html


#Adding markers to map and changing icons

data(quakes)
head(quakes)

# Show first 20 rows from the `quakes` dataset
leaflet(data = quakes[1:20,]) %>% addTiles() %>%
  addMarkers(~long, ~lat, popup = ~as.character(mag), label = ~as.character(mag))


#customizing marker icons
greenLeafIcon <- makeIcon(
  iconUrl = "http://leafletjs.com/examples/custom-icons/leaf-green.png",
  iconWidth = 38, iconHeight = 95,
  iconAnchorX = 22, iconAnchorY = 94,
  shadowUrl = "http://leafletjs.com/examples/custom-icons/leaf-shadow.png",
  shadowWidth = 50, shadowHeight = 64,
  shadowAnchorX = 4, shadowAnchorY = 62
)

leaflet(data = quakes[1:4,]) %>% addTiles() %>%
  addMarkers(~long, ~lat, icon = greenLeafIcon)

#use the awesome icons repository of icons for markers
# first 20 quakes
df.20 <- quakes[1:20,]

#use r code to create function that assigns colors depending on magnitude
#of earthquake.  Creates a vector of colors to use with awesome icons

getColor <- function(quakes) {
  sapply(quakes$mag, function(mag) {
    if(mag <= 4) {
      "green"
    } else if(mag <= 5) {
      "orange"
    } else {
      "red"
    } })
}

#getColor(df.20)

icons <- awesomeIcons(
  icon = 'globe',
  iconColor = 'black',
  #spin=TRUE, #only works with fa (i.e. font awesome)
  library = 'fa',
  markerColor = getColor(df.20)
)
#library argument has to be one of the following: ion, fa, or glyphicon
#corresponding icon libraries are ion,font awesome, and glyphicon.

leaflet(df.20) %>% addTiles() %>%
  addAwesomeMarkers(~long, ~lat, icon=icons, label=~as.character(mag))

#more on circle markers
df.25<-df[1:25,]
leaflet(df.25) %>% addTiles() %>% addCircleMarkers()

#Customize their color, radius, stroke, opacity, etc.
# Create a palette that maps factor levels to colors

leaflet(df) %>% addTiles() %>%
  addCircleMarkers(
    radius = ~size,
    color = rep("red",100),
    stroke = FALSE, fillOpacity = 0.25
  )

#Pop up text and labels
#use addPopups function to add standalone popup to a map
content <- paste(sep = "<br/>",
                 "<b><a href='http://www.samurainoodle.com'>Samurai Noodle</a></b>",
                 "606 5th Ave. S",
                 "Seattle, WA 98138"
)

leaflet() %>% addTiles() %>%
  addPopups(-122.327298, 47.597131, content,
            options = popupOptions(closeButton = FALSE)
  )

#more commonly we add popups to markers...
library(htmltools)

#create data using comma separated lines
df <- read.csv(textConnection(
  "Name,Lat,Long
  Samurai Noodle,47.597131,-122.327298
  Kukai Ramen,47.6154,-122.327157
  Tsukushinbo,47.59987,-122.326726"
))

#build map widget that shows restaurant name when user clicks marker
leaflet(df) %>% addTiles() %>%
  addMarkers(~Long, ~Lat, popup = ~htmlEscape(Name))

#htmltools::htmlEscape was used to sanitize any characters 
#in the name that might be interpreted as HTML

#add labels (displayed when user hovers over marker)
library(htmltools)

df <- read.csv(textConnection(
  "Name,Lat,Long
  Samurai Noodle,47.597131,-122.327298
  Kukai Ramen,47.6154,-122.327157
  Tsukushinbo,47.59987,-122.326726"))

leaflet(df) %>% addTiles() %>%
  addMarkers(~Long, ~Lat, label = ~htmlEscape(Name))

#Customizing Marker Labels using addMarker labelOptions

# Change Text Size and text Only and also a custom CSS style
#notice the noHIde option.

leaflet() %>% addTiles() %>% setView(-118.456554, 34.09, 13) %>%
  addMarkers(
    lng = -118.456554, lat = 34.105,
    label = "Default Label",
    labelOptions = labelOptions(noHide = T)) %>%
  addMarkers(
    lng = -118.456554, lat = 34.095,
    label = "Label w/o surrounding box",
    labelOptions = labelOptions(noHide = T, textOnly = TRUE)) %>%
  addMarkers(
    lng = -118.456554, lat = 34.085,
    label = "label w/ textsize 15px",
    labelOptions = labelOptions(noHide = T, textsize = "15px")) %>%
  addMarkers(
    lng = -118.456554, lat = 34.075,
    label = "Label w/ custom CSS style",
    labelOptions = labelOptions(noHide = T, direction = "bottom",
                                style = list(
                                  "color" = "red",
                                  "font-family" = "serif",
                                  "font-style" = "italic",
                                  "box-shadow" = "3px 3px rgba(0,0,0,0.25)",
                                  "font-size" = "12px",
                                  "border-color" = "rgba(0,0,0,0.5)"
                                )))


#leaflet with shp files
library(rgdal)

tmp <- tempdir()

url <- "http://www2.census.gov/geo/tiger/GENZ2016/shp/cb_2016_us_state_20m.zip"

file <- basename(url)

download.file(url, file)

unzip(file, exdir = tmp)

# From https://www.census.gov/geo/maps-data/data/cbf/cbf_state.html
states <- readOGR(dsn=tmp,
layer = "cb_2016_us_state_20m", GDAL1_integer64_policy = TRUE)

neStates <- subset(states, states$STUSPS %in% c(
  "CT","ME","MA","NH","RI","VT","NY","NJ","PA"
))

m<-leaflet(neStates) %>% addTiles() %>% 
  addPolygons(color = "#444444", weight = 1, smoothFactor = 0.5,
              opacity = 1.0, fillOpacity = 0.5,
              fillColor = ~colorQuantile("YlOrRd", ALAND)(ALAND),
              highlightOptions = highlightOptions(color = "white", weight = 2,
                                                  bringToFront = TRUE))
m

#ADD LEGENDS TO MAP WIDGET

leaflet(neStates) %>% addTiles() %>% 
  addPolygons(color = "#444444", weight = 1, smoothFactor = 0.5,
              opacity = 1.0, fillOpacity = 0.5,
              fillColor = ~colorQuantile("YlOrRd", ALAND)(ALAND),
              highlightOptions = highlightOptions(color = "white", weight = 2,
                                                  bringToFront = TRUE))%>% 
  addLegend("bottomright", colors= "Orange", labels="Test label", title="North Eastern States")

#chorepleth legend
qpal <- colorQuantile("RdYlBu", neStates@data$ALAND, n = 5,reverse=TRUE)


leaflet(neStates) %>% addTiles() %>% 
  addPolygons(color = "#444444", weight = 1, smoothFactor = 0.5,
              opacity = 1.0, fillOpacity = 0.5,
              fillColor = ~qpal(ALAND),
              highlightOptions = highlightOptions(color = "white", weight = 2,
                                                  bringToFront = TRUE))%>% 
  addLegend("bottomright", pal= qpal,  values = ~ALAND, opacity=1)


#Advanced interactivity #1: layer manipulation within widget

#KEEP POINTS THAT DEFINE OUTLINE OF QUAKE POINTS
outline <- quakes[chull(quakes$long, quakes$lat),]


#two layer options
map <- leaflet(quakes) %>%addTiles()%>%
  
  # Overlay groups
  addCircles(~long, ~lat, ~10^mag/5, stroke = F, group = "Quakes") %>%
  #Add a single polygon that outlines points to map
  addPolygons(data = outline, lng = ~long, lat = ~lat,
              fill = T, weight = 2, color = "#FFFFCC", group = "Outline") %>%
  # Layers control
  addLayersControl(
    overlayGroups = c("Quakes", "Outline"),
    options = layersControlOptions(collapsed = FALSE)
  )
map

#three basemap options and two layer options

map <- leaflet(quakes) %>%
  # Base groups
  addTiles(group = "OSM (default)") %>%
  addProviderTiles(providers$Stamen.Toner, group = "Toner") %>%
  addProviderTiles(providers$Stamen.TonerLite, group = "Toner Lite") %>%
  # Overlay groups
  addCircles(~long, ~lat, ~10^mag/5, stroke = F, group = "Quakes") %>%
  addPolygons(data = outline, lng = ~long, lat = ~lat,
              fill = F, weight = 2, color = "#FFFFCC", group = "Outline") %>%
  # Layers control
  addLayersControl(
    baseGroups = c("OSM (default)", "Toner", "Toner Lite"),
    overlayGroups = c("Quakes", "Outline"),
    options = layersControlOptions(collapsed = FALSE)
  )
map



#Example of web application using leaflet with Shiny here:
#http://shiny.rstudio.com/gallery/superzip-example.html
#This is an example of what you will learn in the data visualization 
#course next semester
