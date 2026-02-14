#code to deploy app to shiny.io 
#need information you get from signing up with shiny i.o
#note:be sure to set your r directory to the folder where
#your app code and data are stored.

library(rsconnect)
  
setAccountInfo(name="<ACCOUNT>", token="<TOKEN>", secret="<SECRET>")
  
deployApp()
  
