library(shiny)
library(leaflet)

r_colors <- rgb(t(col2rgb(colors()) / 255))
names(r_colors) <- colors()

ui <- fluidPage(
  titlePanel("Antarctic Humpback Whales"),
  p("Since 2012, we tagged adult Humpback whales as they forage off the coast of the West Antarctic Penisula. This projects allows us a greater insight into their movemements, behaviors, and potential for conflict with anthropogenic sources."),
  mainPanel(leafletOutput("mymap")),
  img(src = "stockimage.png", height = 150, width = 150),
  sidebarPanel("Color",actionButton("year", "Year"),actionButton("month", "Month")),
  p("Text describing the project"))
