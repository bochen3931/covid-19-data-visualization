#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#




## load packages

# library(rsconnect)
# rsconnect::deployApp('D:\Bo\2021\Covid 19 Research Project\Covid 19 Research Project\app')

# Increase workflow by reducing time recalling obscurely named functions
library(pacman)
# Load and install one or more packages simultaneously 
p_load(COVID19,tidyverse, ggplot2,lubridate,usmap,dplyr,skimr,statebins,reshape,leaflet,leafpop,flexdashboard,plotly,ggmap,RgoogleMaps)


# Extract the most recent data
if_df <- covid19(country = "US", level = 2, start = Sys.Date(), end = Sys.Date()) 

length_date <- nchar(if_df[1,] %>% ungroup() %>% select(date))
length_confirmed <- nchar(if_df[1,] %>% ungroup() %>% select(confirmed))

# Using the conditional if...else statement.
if (length_date>2 & length_confirmed>2) {
    us_states <- covid19(country = "US", level = 2, start = Sys.Date(), end = Sys.Date()) 
} else { us_states <- covid19(country = "US", level = 2, start = str_sub(as.POSIXct(Sys.Date()),1,10), end = str_sub(as.POSIXct(Sys.Date()),1,10))
}

# Select multiple columns and rename column 'administrative_area_level_2' as 'state' for better interpretation
us_states <- us_states %>% rename(state=administrative_area_level_2) %>%
    select(id, date, state, population, confirmed, vaccines, deaths, latitude, longitude) 

# Extract column values as a vector, 56 locations (50+1+2+3=56)
# 50 states plus DC, 2 commonwealths (Northern Mariana Islands and Puerto Rico), and 3 territories (Guam, American Samoa, and Virgin Islands)
us_states %>% pull(state)

# Subset 50 states plus DC, filter rows
us_states <- us_states %>%
    filter(!(state %in% c('Northern Mariana Islands', 'Puerto Rico', 'Guam', 'American Samoa', 'Virgin Islands')))
# equivalent code
# '%ni%'<- Negate('%in%'); target=c('Northern Mariana Islands', 'Puerto Rico', 'Guam', 'American Samoa', 'Virgin Islands')
# us_states <- us_states %>% filter(state %ni% target)

# id is a grouping variable, drop after unproup
us_states <- us_states %>%  ungroup() %>%
    select(-id)


# Define UI for application 
ui <- fluidPage(
    # Application title
    titlePanel("US COVID-19 cases, vaccine, and deaths by state"),
    dataTableOutput("dynamic")
   )

# Define server logic required to draw a histogram
server <- function(input, output, session) {
    output$dynamic <- renderDataTable(us_states, options = list(pageLength = 5))
}

# Run the application 
shinyApp(ui = ui, server = server)
