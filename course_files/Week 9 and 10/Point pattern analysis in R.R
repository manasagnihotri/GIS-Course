

#--------------Point Pattern Analysis in R----------

#==QUADRAT ANALYSIS==#

library(maptools)
library(rgdal)
library(spatstat) # lots of good functions for spatial stats in this package!

# Import kidnapping point data from lab folder
#Rows with no point information generate a warning.
##Will be dropped from data.

kidnappings <- readOGR(dsn = "nyc_kidnappings.shp")

# check projection
proj4string(kidnappings) # this is the full geographical detail.

# It's wgs 84. Lets project it to NAD83 / UTM zone 17N
kidnappings <- spTransform(kidnappings, CRS("+init=epsg:26917")) # reproject

##This isn't strictly necessary for our point pattern analysis,
##but it's always good practice to pay attention to your projection!!


# recheck projection
proj4string(kidnappings) # this is the full geographical detail.

#Overview of shapefile
summary(kidnappings)

#Look at data using plot()

plot(kidnappings)


#Begin quadrat analysis

#Need to convert point object to a point pattern object (i.e.-ppp object)
#Point pattern objects help the spatial stats package make calculations

kidnappings.pp = as(kidnappings, 'ppp')

#Specificies type of point coordinates for pattern analysis
# (typically planar point patterns, which  locates features on a plane based 
#on their distance from an origin (0,0) along two perpendicular axes.

#count points that fall in each cell of a grid
q = quadratcount(kidnappings.pp, 4, 8)
plot(kidnappings, col="gray")
plot(q,add=TRUE)

#test if the point pattern is random using quadrat test function:

quadrat.test(kidnappings.pp, 4, 8) 


# By this test there is clearly a spatial pattern in the data
#quadrat.test basically runs a chi squared tests on observed minus expected
#values in cells using the number of quadrats minus one as degrees of freedom

# Test is influenced by number of quadrats, so retest with different grids

quadrat.test(kidnappings.pp, 10, 10) 

quadrat.test(kidnappings.pp, 6, 3) 

#significant by this test across multiple types of grids

#What if we test a map generated to represent complete spatial randomness?

# create a random map in a 10 by 10 window
ranMap <- rpoispp(lambda = 10, win = owin(c(0, 10), c(0, 10)))

plot(ranMap)

# divide the window into six quadrants calculate chi-square
qTest <- quadrat.test(ranMap, nx = 3, ny = 3)

qTest # It works!  The p-value indicates no spatial pattern


##======Nearest Neighbor Analysis===##

#computes the Euclidean distance from each point in a point pattern to its
# nearest neighbour
options(scipen=999) #disable scientific notation

nndist(kidnappings$Longitude,kidnappings$Latitude,k=1) #args= X, Y, k=1 signifies
#first, second, third...furthest neighbor

#find average distance of nearest neighbor
mean(nndist(kidnappings$Longitude,kidnappings$Latitude,k=1))

#return nearest neighbor for each point in data
nnwhich(kidnappings$Longitude,kidnappings$Latitude) #row number in data


#hypothesis testing for spatial pattern using nearest neighbor analysis
#is done manually in R.  Let's use QGIS to automate the process.

#In QGIS:
#Import the nyc_kidnappings.csv file and then map points using latitude and longitude to get clean point data
#We use this csv because all data without lat/long information is deleted.

#Click on the Vector Analysis Tools >Mean coordinate(s) menu item.
#In the dialog that appears, specify random_samples as the input layer,
# but leave the optional choices unchanged.

#Z score above about 2 indicates statistically significant spatial pattern
#i.e.- pattern is different from what we would expect from randomly generated
#points within same area.

library(MASS)

x<-kidnappings@data$Longitude
y<-kidnappings@data$Latitude

# Radius automatically adjusted using this formula: https://stat.ethz.ch/R-manual/R-devel/library/MASS/html/bandwidth.nrd.html
# adjust manually using h argument.

k <- kde2d(x,y)
filled.contour(k)


df<-as.data.frame(cbind(x,y))

library(ggplot2)
base_plot <- ggplot(df, aes(x = x, y = y)) + 
  geom_point()

base_plot

# Kernel density plot with point overlay

base_plot +
  stat_density2d(aes(fill = ..density..), geom = "raster", contour = FALSE) +
  geom_point(color='lightgray',alpha = 1/10) # alpha changins point opacity

#changing radius of calculation

base_plot +
  stat_density2d(aes(fill = ..density..), geom = "raster", contour = FALSE,
                 h = .01)

#change fill colors
base_plot +
  stat_density2d(aes(fill = ..density..), geom = "raster", contour = FALSE)+
  scale_fill_gradient(low="white", high="orange")



# other density plots of interest: Hexagon binning
# need to install hexbin library first
# https://ggplot2.tidyverse.org/reference/geom_hex.html to change number of hexagon bins/size.

d <- ggplot(df, aes(x, y))
d + geom_hex()+
  scale_fill_gradient(low="white", high="orange") 


# Challenge:  John Snow Cholera data

library(cholera)

# datasets
# pumps includes pump locations
# fatalities includes death locations

# Can you create meaningful visualizations from this data? 

# Snow used a Voronoi diagram
# It creates polygons around points to visualize the areas that capture the any points that
# are nearest neighbors with the original points.


x<-pumps$x
y<-pumps$y

df<-as.data.frame(cbind(x,y))


library(dplyr)
df2<-distinct(df)

ggplot(df2,aes(x,y)) +
  stat_voronoi(geom="path") +
  geom_point()