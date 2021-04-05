### IMPORTANT ###
# BEFORE GOING THROUGH THE CODE, READ THE LAST COMMENT
# AT THE BOTTOM OF THIS SCRIPT.

# Load and install packages if required
if (!require("pacman"))
  install.packages("pacman")
pacman::p_load(
  shiny,
  shinydashboard,
  dplyr,
  wordcloud,
  quanteda,
  memoise,
  tm,
  RColorBrewer,
  shinycssloaders,
  plotly
)

#setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Load data
got <<- read.csv("got_scripts_breakdown.csv",
                 stringsAsFactors = F,
                 sep = ";")

# Data cleaning
got <<- got %>% select("Sentence", "Name")
got <<- got[complete.cases(got),]
got <<- got %>% filter(Sentence != "")
got <<- got %>% filter(Name != "")
got <<- got %>% distinct(.keep_all = TRUE)
got <<- got %>% distinct(Sentence, .keep_all = TRUE)

# Filter only the 20 most frequent characters
# Used to reduce memory usage
mostFrequent <<-
  got %>% group_by(Name) %>% tally() %>% arrange(desc(n)) %>% head(20)
got <<- got %>% filter(Name %in% mostFrequent$Name)

# Get names of the characters
characters <<- sort((got %>% distinct(Name))$Name)

# Function that transforms sentences into a Term-Document Matrix
# using the package tm. Of course, it performs classic text
# cleaning procedures
getTermMatrix <- memoise(function(charact) {
  df <- got %>% filter(Name == charact)
  df$Sentence <- gsub("’", "'", df$Sentence)
  df$Sentence <- gsub("'s", "", df$Sentence)
  df$Sentence <- gsub("'", "", df$Sentence)
  
  text <- Corpus(VectorSource(df))
  text <- tm_map(text, content_transformer(tolower))
  text <- tm_map(text, removePunctuation)
  text <- tm_map(text, removeNumbers)
  text <- tm_map(text, removeWords, stopwords("en"))
  
  myDTM <-
    TermDocumentMatrix(text, control = list(minWordLength = 1))
  
  tdm <- as.matrix(myDTM)
  
  sort(rowSums(tdm), decreasing = TRUE)
})

## SERVER ##
server <- function(input, output) {
  # Reactive component to get the
  # TermDocumentMatrix
  words <- reactive({
    input$update
    
    # Progress spinner (bottom right)
    isolate({
      withProgress({
        setProgress(message = "Loading...")
        getTermMatrix(input$charact)
      })
    })
  })
  
  # Sentences per character plotly plot
  output$mfp <- renderPlotly({
    plot_ly(
      mostFrequent,
      x = mostFrequent$Name,
      y = mostFrequent$n,
      type = 'bar',
      name = "Most frequent"
    )
  })
  
  # Wordcloud
  output$wc <- renderPlot({
    w <- words()
    wordcloud(
      names(w),
      w,
      min.freq = input$freq,
      max.words = input$max,
      scale = c(3, 1),
      colors = brewer.pal(5, "Dark2")
    )
  })
  
  # Interactive data table
  output$got_table <- renderDataTable(got)
}

## UI ##
ui <- dashboardPage(
  skin = "black",
  # Header
  dashboardHeader(title = "Game of Thrones Scripts", titleWidth = 350),
  
  # Sidebar
  dashboardSidebar(sidebarMenu(
    # Menu Item 1
    menuItem(
      "Wordcloud",
      tabName = "wc",
      icon = icon("dashboard")
    ),
    
    # Menu Item 2
    menuItem("Raw data",
             tabName = "rd",
             icon = icon("th"))
  )),
  
  # Body
  dashboardBody(tabItems(
    tabItem(# First tab. Contains wc, plotly plot and options box
      tabName = "wc",
      fluidRow(
        # Wc box
        box(title = "Wordcloud",
            plotOutput("wc")),
        
        # Options
        box(
          selectInput("charact", "Choose a character:",
                      choices = characters),
          actionButton("update", "Generate"),
          hr(),
          sliderInput(
            "freq",
            "Minimum Frequency:",
            min = 1,
            max = 50,
            value = 1
          ),
          sliderInput(
            "max",
            "Maximum Number of Words:",
            min = 1,
            max = 300,
            value = 100
          )
        )
      ),

      # Second Row, plotly plot
      fluidRow(
        box(
          width = 12,
          title = "Sentences per character",
          withSpinner(plotlyOutput("mfp"))
        )
      )),
    
    # Second tab
    tabItem(tabName = "rd",
            fluidRow(
              box(
                title = "Raw data table",
                dataTableOutput("got_table"),
                width = 12
              )
            ))
  ))
)

# Run the app.
####### IMPORTANT #######
# ONCE UPLOADED TO GITHUB, THIS LINE MUST BE
# REMOVED. IN ORDER TO RUN THE APP,
# ONE WILL SIMPLY RUN THE FOLLOWING COMMANDS FROM
# THE CONSOLE (WITHOUT WRITING THEM IN THIS SCRIPT):
#
# library(shiny)
# runGitHub("github_username", "github_reponame", ref = "main")
#
# EDIT THE 'REF' PARAMETER VALUE WITH THE GITHUB
# BRANCH NAME.
#########################
shinyApp(ui, server)
