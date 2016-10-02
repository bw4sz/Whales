library(shiny)
library(leaflet)

r_colors <- rgb(t(col2rgb(colors()) / 255))
names(r_colors) <- colors()
d<-read.csv("WhaleDat.csv")

ui <- fluidPage(
  titlePanel("Tracking Humpback Whales"),
  p("Since 2012, we haved tagged adult Humpback whales as they forage off the coast of the West Antarctic Penisula. This projects allows us a greater insight into their movemements, behaviors, and potential for conflict with anthropogenic sources."),
  
  #main panel
  mainPanel(leafletOutput("mymap",height=525),width=10),
#side bar
  sidebarPanel(width=2,selectInput("year","Year",c("All",unique(d$Year))),
  selectInput("month","Month",c("All",month.name[month.name %in% d$Month])),
  selectInput("ind","Individual",c("All",unique(d$Animal))),
  img(src = "stockimage.png", height = 225, width = 150)),
  p("Please note that the map may take a few seconds to load"),
  br(),
  h1("Why Study Whales?"),
  p("Humpback whales are the largest marine predator commonly found in Antarctic Waters. By studying their movement we gain insight into their recovery from near extinction due to historic harvest. Humpbacks feed primarily on Antarctic Krill, and are important bellweathers for the health and condition of the Antarctic Marine Ecosystem.In the Antarctic, the intersection between commercial fishing and marine mammals continues to grow as fishing pressure increases and vessels move into new, and in some cases, previously inaccessibly environments. The Antarctic Krill (Euphausia superba) fishery is the largest in the Southern Ocean (>300,000 metric tons annually) and operates in ice-free areas during the austral summer. Declining sea ice in local fishing areas has led to a southward expansion and increased the potential for negative impacts on fragile polar marine ecosystems. The expansion of fisheries can have negative consequences for marine mammal population persistence through direction competition for resources, ship-strikes, soundscape effects, and general avoidance of productive feeding areas"),
  h3("Contact Us"),
  h4("Ben Weinstein"),p("Ben is a quantitative ecologist and data sceintist at Marine Mammal Research Center, Oregon State University. Ben enjoys appying new technology to ecology and biodiversity conservation."),
  h4("Ari Friedlaender"),p("Ari is an Assistant Professor at Oregon State University, and has been studying whales for ten years. Ari can be found out to sea everyday that weather and grant applications allow.")
)