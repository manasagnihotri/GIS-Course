

#Intro to Shiny apps with example of Leaflet Shiny App
#Code via Rstudio turorials, R guru Dean Attili's site, and Leaflet Package for R

#----Part 1:  Install shiny package and get familiar with UI and Server structure----#

#this is the outline of a basic app
#You need to open the shiny library and build a ui, a server
#This code can be saved in an R script to a unique folder on your computer.
#the R script must be called app.R in order to be recognized as a shiny app.

#(you can also save separate ui.R and server.R files to the same folder and shiny
#will recognize both files together as an app)

library(shiny)

ui <- fluidPage()

server <- function(input, output) {}

shinyApp(ui = ui, server = server)



#Build a basic User Interface

library(shiny)
bcl <- read.csv("bcl-data.csv", stringsAsFactors = FALSE)

ui <- fluidPage(
  titlePanel("BC Liquor Store prices"),
  sidebarLayout(
    sidebarPanel("our inputs will go here"),
    mainPanel("the results will go here")
  )
)

server <- function(input, output) {}

shinyApp(ui = ui, server = server)

#Select above text and run app to see what it looks like

#have a look at your ui object.  Notice it is building html code:
print(ui)


#-----Part 2:  Adding User Interface (UI)user input components-----

#Let's add some code to include widgets to the ui that allow for user inputs

#example of code for one of many user input widgets - slider
sliderInput("priceInput", "Price", min = 0, max = 100,
            value = c(25, 40), pre = "$")

#first to arguments for user inputs give input a name and a label


#more examples of user inputs https://shiny.rstudio.com/gallery/widget-gallery.html and
#https://deanattali.com/img/blog/shiny-tutorial/shiny-inputs.png

#add inputs to sidebar panel separated by a comma

library(shiny)
bcl <- read.csv("bcl-data.csv", stringsAsFactors = FALSE)

ui <- fluidPage(
  titlePanel("BC Liquor Store prices"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("priceInput", "Price", 0, 100, c(25, 40), pre = "$"),
      radioButtons("typeInput", "Product type",
                   choices = c("BEER", "REFRESHMENT", "SPIRITS", "WINE"),
                   selected = "WINE"),
      selectInput("countryInput", "Country",
                  choices = c("CANADA", "FRANCE", "ITALY"))
    ),
    mainPanel("the results will go here")
  )
)

server <- function(input, output) {}

shinyApp(ui = ui, server = server)



#output from our server file is shown in the main panel area


#-----Part 3:  Adding output placeholders to UI-----

#Different kinds of output can be called from server file using
#particular functions.  We will create a basic plot in our server file
#so we will use the plotOutput() function in the main panel.

#We will also add a table using the tableOutput() function

#add a placeholder for outputs called "coolplot" for plot and "results" for table
#in the main panel



library(shiny)
bcl <- read.csv("bcl-data.csv", stringsAsFactors = FALSE)

ui <- fluidPage(
  titlePanel("BC Liquor Store prices"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("priceInput", "Price", 0, 100, c(25, 40), pre = "$"),
      radioButtons("typeInput", "Product type",
                   choices = c("BEER", "REFRESHMENT", "SPIRITS", "WINE"),
                   selected = "WINE"),
      selectInput("countryInput", "Country",
                  choices = c("CANADA", "FRANCE", "ITALY"))
    ),
    mainPanel(plotOutput("coolplot"),
              #add a few html breaks for spacing using br()
              br(),  br(),
              
              tableOutput("results"))
  )
)

server <- function(input, output) {}

shinyApp(ui = ui, server = server)


#-----Part 4:  Server: assemble input into outputs-----


#Now we need to render some output in our server file to feed it back to the 
#main panel for the app to work

#Here is how we would create a plot plot using typical R code

plot(rnorm(100))

#in shiny we need to wrap this with a render function that is assigned to the "coolplot" object
#in our ui main panel

#Here is how we would create a plot in a server function that would show up in our main panel

output$coolplot <- renderPlot({
  plot(rnorm(100))
})


#Let's put this into the server file for our complete code to see it in 
#the main panel.


library(shiny)
bcl <- read.csv("bcl-data.csv", stringsAsFactors = FALSE)

ui <- fluidPage(
  titlePanel("BC Liquor Store prices"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("priceInput", "Price", 0, 100, c(25, 40), pre = "$"),
      radioButtons("typeInput", "Product type",
                   choices = c("BEER", "REFRESHMENT", "SPIRITS", "WINE"),
                   selected = "WINE"),
      selectInput("countryInput", "Country",
                  choices = c("CANADA", "FRANCE", "ITALY"))
    ),
    mainPanel(plotOutput("coolplot"),
              #add a few html breaks for spacing using br()
              br(),  br(),
              
              tableOutput("results"))
  )
)

server <- function(input, output) {
  output$coolplot <- renderPlot({
  plot(rnorm(100))  ##plotting random data, 
			  ##still need to make data interactive
})}

shinyApp(ui = ui, server = server)


#-----Part 4b:  Server: feed input data into plot to make it interactive-----


#the next step is to make this plot interactive to input from the user

#user selection objects are read into the server file using 
#  input$objectname

#Our object names for the slider input is "priceInput".  

#slider inputs give a high value and a low value in a vector
#In server language we could call element 1 of the vector using:
input$priceInput[1]

#element two (i.e.-the higher value of the slider input)
input$priceInput[2]

#example of plot in server reacting to lower input value
output$coolplot <- renderPlot({
  plot(rnorm(input$priceInput[1]))
})


#let's make a decent looking histogram that reshapes our data using user input
#here's the code that will go into our server file
output$coolplot <- renderPlot({
  filtered <-
    bcl %>%
    filter(Price >= input$priceInput[1],
           Price <= input$priceInput[2],
           Type == input$typeInput,
           Country == input$countryInput
    )
  ggplot(filtered, aes(Alcohol_Content)) +
    geom_histogram()
})


#The full app thus far...

library(shiny)
library(ggplot2)
library(dplyr)

bcl <- read.csv("bcl-data.csv", stringsAsFactors = FALSE)

ui <- fluidPage(
  titlePanel("BC Liquor Store prices"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("priceInput", "Price", 0, 100, c(25, 40), pre = "$"),
      radioButtons("typeInput", "Product type",
                   choices = c("BEER", "REFRESHMENT", "SPIRITS", "WINE"),
                   selected = "WINE"),
      selectInput("countryInput", "Country",
                  choices = c("CANADA", "FRANCE", "ITALY"))
    ),
    mainPanel(
      plotOutput("coolplot"),
      br(), br(),
      tableOutput("results")
    )
  )
)

server <- function(input, output) {
  output$coolplot <- renderPlot({
    filtered <-
      bcl %>%
      filter(Price >= input$priceInput[1],
             Price <= input$priceInput[2],
             Type == input$typeInput,
             Country == input$countryInput
      )
    ggplot(filtered, aes(Alcohol_Content)) +
      geom_histogram()
  })
}

shinyApp(ui = ui, server = server)


#-----Part 5:  Using reactive() function to streamline code that interacts
#               (or changes) with user input-----



#New concept to streamline code: reactive functions
#wrap data operations so you don't need to redo it in each render function
#Note: to call results from reactive function in render functions add 
#parentheses to new object!

#our new data would be assigned to the filtered() object.  Notice the parentheses on this
#object in the render functions!

#example in server file:

server <- function(input, output) {
  filtered <- reactive({
    bcl %>%
      filter(Price >= input$priceInput[1],
             Price <= input$priceInput[2],
             Type == input$typeInput,
             Country == input$countryInput
      )
  })
  
  output$coolplot <- renderPlot({
    ggplot(filtered(), aes(Alcohol_Content)) +
      geom_histogram()
  })
  
  output$results <- renderTable({
    filtered()
  })
}

#We'll keep it simple in our final app by leaving reactive functions out for now.


#------Part 6:  See a full App in action:

#The full app thus far...

library(shiny)
library(ggplot2)
library(dplyr)

bcl <- read.csv("bcl-data.csv", stringsAsFactors = FALSE)

ui <- fluidPage(
  titlePanel("BC Liquor Store prices"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("priceInput", "Price", 0, 100, c(25, 40), pre = "$"),
      radioButtons("typeInput", "Product type",
                   choices = c("BEER", "REFRESHMENT", "SPIRITS", "WINE"),
                   selected = "WINE"),
      selectInput("countryInput", "Country",
                  choices = c("CANADA", "FRANCE", "ITALY"))
    ),
    mainPanel(
      plotOutput("coolplot"),
      br(), br(),
      tableOutput("results")
    )
  )
)

server <- function(input, output) {
  output$coolplot <- renderPlot({
    filtered <-
      bcl %>%
      filter(Price >= input$priceInput[1],
             Price <= input$priceInput[2],
             Type == input$typeInput,
             Country == input$countryInput
      )
    ggplot(filtered, aes(Alcohol_Content)) +
      geom_histogram()
  })
  
  output$results <- renderTable({
   
  filtered <-
    bcl %>%
    filter(Price >= input$priceInput[1],
           Price <= input$priceInput[2],
           Type == input$typeInput,
           Country == input$countryInput)
  })
}

shinyApp(ui = ui, server = server)


#------Part 7: Adding Leaflet mapping functionality in Shiny apps---------


#Now let's consider Leaflet mapping functionality in Shiny apps:

#we can add a leaflet map to a ui using the leafletOutput function and the renderLeaflet
#server side function.  Here is one example:

library(shiny)
library(leaflet)

ui <- fluidPage(
  leafletOutput("mymap"),
  p(),
  actionButton("recalc", "New points")
)

server <- function(input, output, session) {
  
  points <- eventReactive(input$recalc, {
    cbind(rnorm(40) * 2 + 13, rnorm(40) + 48)
  }, ignoreNULL = FALSE)
  
  output$mymap <- renderLeaflet({
    leaflet() %>%
      addProviderTiles(providers$Stamen.TonerLite,
                       options = providerTileOptions(noWrap = TRUE)
      ) %>%
      addCircles(data = points())
  })
}


shinyApp(ui = ui, server = server)

#Now try to create your own app that imports a map and displays different data
#with data filtered by user selection input

#Use our leaflet in R script from tutorial 8 to help you build the code


#------Part 8: Using Leaflet Proxy function updates map w/o reloading it---------

#the function can make the app update in a smoother way

#Example using quakes data:

library(shiny)
library(leaflet)

ui <- fluidPage(
leafletOutput("map"),
  p(),
sliderInput("range", "Magnitudes", min(quakes$mag), max(quakes$mag),
      value = range(quakes$mag), step = 0.1
    )
)


server <- function(input, output, session) {


  # Reactive expression for the data subsetted to what the user selected
  filteredData <- reactive({
    quakes[quakes$mag >= input$range[1] & quakes$mag <= input$range[2],]
  })

  output$map <- renderLeaflet({
    # Use leaflet() here, and only include aspects of the map that
    # won't need to change dynamically (at least, not unless the
    # entire map is being torn down and recreated).
    leaflet(  quakes) %>% addTiles() %>% addCircles()%>% 
      fitBounds(~min(long), ~min(lat), ~max(long), ~max(lat))
  })

  # Incremental changes to the map should be performed in
  # an observer. Each independent set of things that can change
  # should be managed in its own observer.

#note that you are passing reactive data into the function to update

  observe({
    leafletProxy("map", data = filteredData()) %>%
      clearShapes() %>% #clear previous shapes, then add new shapes
      addCircles()
  })

 
}

shinyApp(ui, server)


#second example that deletes markers after they are clicked:

library(shiny)

ui <- fluidPage(
  leafletOutput("map")
)

server <- function(input, output, session) {
  output$map1 <- renderLeaflet({
    leaflet() %>% addCircleMarkers(
      lng = runif(10),
      lat = runif(10),
      layerId = paste0("marker", 1:10))
  })

  observeEvent(input$map1_marker_click, {
    leafletProxy("map1", session) %>%
      removeMarker(input$map1_marker_click$id)
  })
}

shinyApp(ui, server)

