#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(jsonlite)
library(azuremlsdk)

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Accident Fatality Probability Estimator"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            sliderInput("age",
                        "Occupant Age:",
                        min = 16,
                        max = 95,
                        value = 16),
            selectInput("sex",
                        "Occupant gender:",
                        c("f","m")),
            selectInput("occRole",
                        "Occupant role:",
                        c("driver","pass")),
            sliderInput("yearVeh",
                        "Vehicle Year:",
                        min = 1955,
                        max = 2005,
                        value = 2002),
            selectInput("seatbelt",
                        "Seatbelt:",
                        c("none","belted")),
            selectInput("airbag",
                        "Airbag:",
                        c("none","airbag")),
            selectInput("dvcat",
                        "Impact speed:",
                        c("1-9km/h","10-24","25-39","40-54","55+")),
            selectInput("frontal",
                        "Collision type:",
                        c("notfrontal","frontal"))
        ),

        # Show a plot of the generated distribution
        mainPanel(
           plotOutput("barchart")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    
    newdata <- data.frame( # valid values shown below
        dvcat="10-24",        # "1-9km/h" "10-24"   "25-39"   "40-54"   "55+"  
        seatbelt="none",      # "none"   "belted"  
        frontal="frontal",    # "notfrontal" "frontal"
        sex="f",              # "f" "m"
        ageOFocc=16,          # age in years, 16-97
        yearVeh=2002,         # year of vehicle, 1955-2003
        airbag="none",        # "none"   "airbag"   
        occRole="pass"        # "driver" "pass"
    )
    
    
    pred <- reactive({
        ws <- load_workspace_from_config()
        aci_service <- get_webservice(ws, "accident-pred")    

        newdata$yearVeh <- input$yearVeh
        newdata$ageOFocc <- input$age
        newdata$dvcat <- input$dvcat
        newdata$seatbelt <- input$seatbelt
        newdata$frontal <- input$frontal
        newdata$sex <- input$sex
        newdata$airbag <- input$airbag
        newdata$occRole <- input$occRole
        
        invoke_webservice(aci_service, toJSON(newdata)) 
    })

    output$prediction <- renderText({pred()})

    output$barchart <- renderPlot({
        p <- pred()
        pp <- formatC(p, format="f", digits=2, width=5)
        barplot(p, ylim=c(0,100), ylab="Probability (%)", col="#0000AA", names.arg=pp, cex.names=2.5)
    })
}

# Run the application 
shinyApp(ui = ui, server = server)


