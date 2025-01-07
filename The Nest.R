library(shiny)
library(shinydashboard)
library(leaflet)
library(DBI)
library(RMariaDB)
library(DT)
library(bslib)
library(dplyr)
library(lubridate)
library(tidyverse)
library(ggplot2)
library(reticulate)
library(shinythemes)

# Define color and font variables for customization
app_colors <- list(
  header_bg = "#8B4513",
  header_text = "#FFFFFF",
  sidebar_bg = "#D2B48C",
  sidebar_text = "#000000",
  tab_bg = "#FFF8DC",
  tab_text = "#4B0082",
  button_bg = "#862B0D",
  button_text = "#000000"
)

app_fonts <- list(
  main_font = "Arial, sans-serif",
  header_font = "Verdana, sans-serif",
  text_font = "Georgia, serif"
)

# Configure Python environment
Sys.setenv(RETICULATE_PYTHON = "C:/Users/amith/anaconda3/envs/sqlchat/python.exe")  # Adjust path if needed
py_config() # Verify Python configuration

# Load Python functions
tryCatch({
  py_run_string("
import os
from langchain_community.utilities import SQLDatabase
from langchain_openai import ChatOpenAI
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Set API key and initialize LLM
api_key = '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'  # Replace with your OpenAI API key
llm = ChatOpenAI(model='gpt-4o', api_key=api_key)

# Define the function to generate SQL and answer
def generate_sql_and_answer(question):
    try:
        # Database schema context
        schema = '''
        Table: Admins
        Columns: admin_id, admin_name, admin_email, admin_role

        Table: Community
        Columns: c_id, c_name, c_address, c_zip, c_city, c_description, c_units

        Table: Feedbacks
        Columns: f_message, u_email

        Table: Map
        Columns: m_id, m_name, latitude, longitude

        Table: Property
        Columns: p_id, p_type, p_rent, p_availability, p_furnish_status, p_description, c_id, admin_id

        Table: Rating
        Columns: r_id, the_nest_rating, google_rating, social_media_rating, c_id

        Table: Tenants
        Columns: u_phone, u_name, u_email
        '''

        # Construct the prompt
        template = f'''
        Using the following database schema:
        {schema}

        Question: {question}

        Generate an optimized SQL query to answer the question. Additionally, provide a sentence template to express the result in natural language. Include the SQL query and the sentence template.
        '''
        response = llm.invoke(template)
        raw_response = response.content.strip()

        # Log the raw response for debugging
        print(f'Raw LLM Response: {raw_response}')

        # Extract SQL query and sentence template from response
        sql_query = None
        sentence_template = None
        if 'sql' in raw_response:
            sql_query = raw_response.split('sql')[1].split('```')[0].strip()
        else:
            raise ValueError('SQL query not found in response.')

        if 'Template:' in raw_response:
            sentence_template = raw_response.split('Template:')[1].strip()
        else:
            sentence_template = 'The result is: {result}.'

        return sql_query, sentence_template
    except Exception as e:
        print(f'Error in generate_sql_and_answer: {e}')
        raise
")
  print("Python functions loaded successfully.")
}, error = function(e) {
  stop("Python initialization failed: ", e$message)
})

ui <- fluidPage(
  theme = bs_theme(bootswatch = "lux"),
  
  tags$style(HTML("
      body {
        background-color: #FAF3E0; /* Light beige background */
      }
      .tab-content {
        background-color: #FAF3E0; /* Ensures tab content matches the background */
      }
      .navbar {
        background-color: #8B4513; /* Header background color */
      }
    ")),
  
  titlePanel(
    div("THE NEST", style = paste0(
      "text-align: center; font-size: 90px; color:", app_colors$header_text, ";",
      "background-color:", app_colors$header_bg, "; font-family:", app_fonts$header_font, "; padding: 20px;"
    ))
  ),
  
  tags$head(
    tags$style(HTML("
      .navbar-default .navbar-nav > li > a {
        font-weight: bold !important; /* Make tab titles bold */
        color: black !important; /* Optional: Set tab text color to black */
      }
      .navbar-default .navbar-nav > li.active > a {
        font-weight: bold !important; /* Keep the active tab bold */
        color: black !important; /* Optional: Set active tab text color */
      }
      .navbar-default .navbar-nav > li > a:hover {
        font-weight: bold !important; /* Keep hover state bold */
        color: #862B0D !important; /* Optional: Change hover color */
      }
    "))
  ),
  navbarPage(
    "",
    tabPanel(
      "Home",
      fluidRow(
        column(8,
               h3("Find the best Apartment options in The Nest Community", style = paste0("font-family:", app_fonts$text_font, ";")),
               uiOutput("image1"),
               br()
        ),
        column(4,
               h4("REGISTER", style = "font-weight: bold; text-align: center;"),
               div(
                 style = "background-color: #E4D1B9; padding: 20px; border: 1px solid #D2B48C;",
                 h5("Input details for:", style = "font-weight: bold; text-align: center;"),
                 textInput("reg_name", tags$b("Name:"), placeholder = "Enter your name"),
                 textInput("reg_email", tags$b("Email:"), placeholder = "Enter your email"),
                 textInput("reg_phone", tags$b("Phone:"), placeholder = "Enter your phone number"),
                 actionButton("submit_register", "Submit", 
                              style = "background-color: #862B0D; color: #FFFFFF; margin-top: 10px;border-radius: 5px;")
               )
        )
      )
    ),
    
    tabPanel(
      "Community",
      fluidRow(
        column(12,
               div(
                 style = "text-align: center; margin-bottom: 20px;",
                 actionButton("btn_community_1", "The Nest Bend", style = "background-color: #862B0D; color: #FFFFFF; margin: 5px;border-radius: 5px;"),
                 actionButton("btn_community_2", "The Nest Park", style = "background-color: #862B0D; color: #FFFFFF; margin: 5px;border-radius: 5px;"),
                 actionButton("btn_community_3", "The Nest Gate", style = "background-color: #862B0D; color: #FFFFFF; margin: 5px;border-radius: 5px;"),
                 actionButton("btn_community_4", "The Nest Green", style = "background-color: #862B0D; color: #FFFFFF; margin: 5px;border-radius: 5px;"),
                 actionButton("btn_community_5", "The Nest Drey", style = "background-color: #862B0D; color: #FFFFFF; margin: 5px;border-radius: 5px;")
                 
               )
        )
      ),
      fluidRow(
        column(3,
               selectInput(inputId = 'property_type', label = 'Property Type:', choices = c("All", "1BHK", "2BHK", "3BHK"), selected = "All")
        ),
        column(3,
               selectInput(inputId = 'availability', label = 'Availability:', choices = c("All", "Available", "Occupied"), selected = "All")
        ),
        column(3,
               selectInput(inputId = 'furnish_status', label = 'Furnishing Status:', choices = c("All", "Furnished", "Unfurnished"), selected = "All")
        ),
        column(3,
               sliderInput(inputId = 'price_range', label = 'Price Range:', min = 0, max = 2500, value = c(0, 2500))
        )
      ),
      fluidRow(
        column(12, align = "center",
               actionButton("search_properties", "Search Properties", style = "background-color: #862B0D; color: #FFFFFF; margin-top: 25px;border-radius: 5px;")
        )
      ),
      fluidRow(
        column(12,
               h4("Available Properties"),
               DT::dataTableOutput("available_properties")
        )
      )
    ),
    tabPanel(
      "Map",
      h3("The Nest Community Map", style = paste0("font-family:", app_fonts$text_font, "; color: black;")),
      leafletOutput("interactive_map", width = "100%", height = "600px")
    ),
    tabPanel(
      "Ranking",
      h2("Community Ratings Comparison", style = paste0("font-family:", app_fonts$text_font, ";")),
      plotOutput("chart_out", width = "80%", height = "500px"),
      br(),
      h4("Rating Data Table"),
      DT::dataTableOutput("Rating_DT", width = "80%")
    ),
    # Feedback Panel
    tabPanel(
      "Feedback",
      
      # Heading with margin
      tags$div(
        style = "margin-bottom: 20px;",
        h3("We value your feedback!", style = paste0("font-family:", app_fonts$text_font, ";"))
      ),
      
      # Email input with margin
      tags$div(
        style = "margin-bottom: 20px;",
        textInput(inputId = "feedback_email", 
                  label = "Enter your registered email:", 
                  placeholder = "Your email address")
      ),
      
      # Community dropdown with margin
      tags$div(
        style = "margin-bottom: 20px;",
        selectInput(inputId = "feedback_cname", 
                    label = "Select Community:", 
                    choices = NULL, 
                    selected = NULL)
      ),
      
      # Feedback text area with margin
      tags$div(
        style = "margin-bottom: 20px;",
        textAreaInput(inputId = "feedback_input", 
                      label = "Your Feedback", 
                      placeholder = "Enter your feedback here...")
      ),
      
      # Submit button with margin
      tags$div(
        style = "margin-bottom: 20px;",
        actionButton("submit_feedback", 
                     "Submit Feedback", 
                     style = paste0("background-color:", app_colors$button_bg, 
                                    "; color: #FFFFFF;",  # White font color
                                    " font-weight: bold;",  # Optional for bold font
                                    " border: none;",  # Optional for cleaner button design
                                    " padding: 10px 20px;",  # Optional for better spacing
                                    " border-radius: 5px;"))  # Optional for rounded corners)
      ),
      
      
      # Submitted feedback heading with margin
      tags$div(
        style = "margin-top: 30px; margin-bottom: 10px;",
        h4("Submitted Feedback")
      ),
      
      # Feedback table
      DT::dataTableOutput("feedback_table")
    )
    
    ,
    
    tabPanel(
      "ASK AI",
      h2("AI-Powered SQL Query Generator", style = paste0("font-family:", app_fonts$text_font, ";")),
      titlePanel("AI-Powered SQL Query Generator"),
      sidebarLayout(
        sidebarPanel(
          div(
            textInput("question", "Enter your question:", placeholder = "e.g., How many properties are available?"),
            actionButton("generate_sql", "Generate SQL and Run", class = "btn-custom"),
            class = "sidebar-panel"
          )
        ),
        mainPanel(
          tags$h4("Generated SQL Query"),
          div(verbatimTextOutput("generated_sql"), class = "response-box"),
          tags$h4("Natural Language Explanation"),
          div(verbatimTextOutput("generated_answer"), class = "response-box"),
          tags$h4("Query Results in Sentence"),
          div(verbatimTextOutput("query_result_sentence"), class = "response-box"),
          tags$h4("Query Results (Table)"),
          DT::dataTableOutput("query_results")
        )
      )
    ),
    
    
    
    
    
    
    tabPanel(
      "Admin",
      
      tags$head(
        tags$style(HTML("
        .nav-tabs > li > a {
          background-color: #862B0D; /* Purple color for the tab */
          color: white; /* White text color */
          font-weight: bold; /* Bold text for better visibility */
          border-radius: 5px; /* Optional: rounded corners */
          margin: 2px; /* Optional: space between tabs */
        }
        .nav-tabs > li.active > a {
          background-color: #862B0D; /* Darker purple for active tab */
          color: white;
        }
        .nav-tabs > li > a:hover {
          background-color: #BA704F; /* Slightly lighter purple on hover */
          color: white;
        }
      "))
      ),
      
      tabsetPanel(
        tabPanel("Manage Communities",
                 fluidRow(
                   column(3, textInput("c_id", label = tags$span("Community ID", style = "font-weight: bold; color: black;"), placeholder = "Enter Community ID")),
                   column(3, textInput("c_name", label = tags$span("Community Name", style = "font-weight: bold; color: black;"), placeholder = "Enter Community Name")),
                   column(3, textInput("c_address", label = tags$span("Address", style = "font-weight: bold; color: black;"), placeholder = "Enter Community Address")),
                   column(3, textInput("c_zip", label = tags$span("Zip Code", style = "font-weight: bold; color: black;"), placeholder = "Enter Zip Code")),
                   column(3, textInput("c_city", label = tags$span("City", style = "font-weight: bold; color: black;"), placeholder = "Enter City")),
                   column(3, textInput("c_description", label = tags$span("Description", style = "font-weight: bold; color: black;"), placeholder = "Enter Description")),
                   column(3, numericInput("c_units", label = tags$span("Units", style = "font-weight: bold; color: black;"), value = 1, min = 1)),
                   column(12, style = "display: flex; justify-content: space-evenly;",
                          actionButton("add_community", "ADD COMMUNITY", style = "background-color: #862B0D; color: white; font-weight: bold; border: none; padding: 10px 20px;border-radius: 5px;"),
                          actionButton("update_community", "UPDATE COMMUNITY", style = "background-color: #862B0D; color: white; font-weight: bold; border: none; padding: 10px 20px;border-radius: 5px;"),
                          actionButton("delete_community", "DELETE COMMUNITY", style = "background-color: #862B0D; color: white; font-weight: bold; border: none; padding: 10px 20px;border-radius: 5px;")
                   )
                 ),
                 DT::dataTableOutput("community_table")
        ),
        
        tabPanel("Manage Properties",
                 fluidRow(
                   column(3, textInput("p_id", label = tags$span("Property ID", style = "font-weight: bold; color: black;"), placeholder = "Enter Property ID")),
                   column(3, textInput("p_type", label = tags$span("Type", style = "font-weight: bold; color: black;"), placeholder = "1BHK/2BHK/3BHK")),
                   column(3, numericInput("p_rent", label = tags$span("Rent", style = "font-weight: bold; color: black;"), value = 500, min = 0)),
                   column(3, textInput("p_availability", label = tags$span("Availability", style = "font-weight: bold; color: black;"), placeholder = "Occupied/Available")),
                   column(3, textInput("p_furnish_status", label = tags$span("Furnish Status", style = "font-weight: bold; color: black;"), placeholder = "Furnished/Unfurnished")),
                   column(3, textInput("p_description", label = tags$span("Description", style = "font-weight: bold; color: black;"), placeholder = "Enter Property Description")),
                   column(3, textInput("c_id_property", label = tags$span("Community ID", style = "font-weight: bold; color: black;"), placeholder = "Enter Community ID")),
                   column(3, textInput("admin_id", label = tags$span("Admin ID", style = "font-weight: bold; color: black;"), placeholder = "Enter Admin ID")),
                   column(12, style = "display: flex; justify-content: space-evenly;",
                          actionButton("add_property", "ADD PROPERTY", style = "background-color: #862B0D; color: white; font-weight: bold; border: none; padding: 10px 20px; border-radius: 5px;"),
                          actionButton("update_property", "UPDATE PROPERTY", style = "background-color: #862B0D; color: white; font-weight: bold; border: none; padding: 10px 20px; border-radius: 5px;"),
                          actionButton("delete_property", "DELETE PROPERTY", style = "background-color: #862B0D; color: white; font-weight: bold; border: none; padding: 10px 20px; border-radius: 5px;")
                   )
                 ),
                 DT::dataTableOutput("property_table")
        )
      )
    )
  )
)

server <- function(input, output, session) {
  # Database connection
  dbConnector1 <- DBI::dbConnect(RMariaDB::MariaDB(),
                                 host = "itom6265-db.c1e6oi6e06on.us-east-2.rds.amazonaws.com",
                                 port = 3306,
                                 dbname = "The_Nest",
                                 user = "root",
                                 password = "mysql_local_pass")
  
  session$onSessionEnded(function() {
    dbDisconnect(dbConnector1)
  })
  
  # Populate community dropdown
  observe({
    # Fetch community names from the database
    community_names <- dbGetQuery(dbConnector1, "SELECT c_name FROM Community")
    # Update the selectInput dropdown with community names
    updateSelectInput(session, "feedback_cname", choices = community_names$c_name)
  })
  
  
  # Image rendering
  output$image1 <- renderUI({
    imgurl2 <- "https://www.condocontrol.com/wp-content/uploads/2022/07/iStock-172208226-1.jpg.webp"
    tagList(
      tags$img(src = imgurl2, style = "width: 50%; height: auto; display: block; margin: 0 auto;"),
      br(),
      tags$div(
        style = "padding: 20px; font-family: Georgia, serif; text-align: justify; background-color: #FAF3E0;",
        tags$h3("MODERN LIVING SIMPLIFIED AT THE NEST", style = "font-weight: bold; text-align: center;"),
        tags$p(
          "The Nest redefines residential living by merging technology with lifestyle convenience. Serving a vibrant community of tenants, The Nest offers an innovative digital platform that simplifies the apartment search process while fostering a connected living experience. With over 1,200 properties ranging from 1BHK to 3BHK options, The Nest caters to singles, families, and groups seeking homes that suit their unique needs."
        ),
        tags$p(
          "But The Nest is more than just a place to live. It’s a lifestyle destination. Enjoy amenities like fully furnished units, gyms, swimming pools, eco-friendly features, and Wi-Fi, alongside a secure and hassle-free environment. Engage with the community through an intuitive app that offers advanced search tools, property comparisons, interactive maps, and seamless inquiry options."
        ),
        tags$p(
          "Whether you're browsing listings, exploring eco-conscious living, or indulging in thoughtfully curated spaces, The Nest elevates everyday living with ease and sophistication. Find your perfect home today—The Nest awaits!"
        )
      )
    )
  })
  
  
  # Community tab - Community button logic with modal pop-ups
  observeEvent(input$btn_community_1, {
    showModal(modalDialog(
      title = "The Nest Bend",
      tagList(
        tags$img(
          src = "https://media.istockphoto.com/id/144292803/photo/happy-neighbourhood.jpg?s=612x612&w=0&k=20&c=MmLyuETKuHasAlnyqZm0HDeV_qiLHl82T2vKItDi9dM=",  # Replace with the actual image URL
          style = "width:100%; height:auto; margin-bottom:15px;"  # Adjust styles as needed
        ),
        "This is a wonderful community that features great amenities and a friendly environment, suitable for families and individuals."
      ),
      easyClose = TRUE
    ))
  })

  observeEvent(input$btn_community_2, {
    showModal(modalDialog(
      title = "The Nest Park",
      tagList(
        tags$img(
          src = "https://res.cloudinary.com/nrpadev/image/upload/f_auto,q_70/2020-August-Finance-Park-Space-Housing-Prices-410-Final.jpg",  # Replace with the actual image URL
          style = "width:100%; height:auto; margin-bottom:15px;"  # Adjust styles as needed
        ),
        "Known for its modern infrastructure and close proximity to downtown, this community is perfect for young professionals."
      ),
      easyClose = TRUE
    ))
  })
  
  observeEvent(input$btn_community_3, {
    showModal(modalDialog(
      title = "The Nest Gate",
      tagList(
        tags$img(
          src = "https://assets.floridarentals.com/assets/properties/16425/tn1_135257644916759335450.jpg",  # Replace with the actual image URL
          style = "width:100%; height:auto; margin-bottom:15px;"  # Adjust styles as needed
        ),
        "A peaceful community surrounded by parks and nature, ideal for those who enjoy tranquility and outdoor activities."
      ),
      easyClose = TRUE
    ))
  })
  
  observeEvent(input$btn_community_4, {
    showModal(modalDialog(
      title = "The Nest Green",
      tagList(
        tags$img(
          src = "https://i0.wp.com/pixahive.com/wp-content/uploads/2021/01/A-house-around-greenery-266382-pixahive.jpg?fit=2560%2C1706&ssl=1",  # Replace with the actual image URL
          style = "width:100%; height:auto; margin-bottom:15px;"  # Adjust styles as needed
        ),
        "This vibrant community offers a rich cultural experience with numerous restaurants, shops, and entertainment options."
      ),
      easyClose = TRUE
    ))
  })
  
  observeEvent(input$btn_community_5, {
    showModal(modalDialog(
      title = "The Nest Drey",
      tagList(
        tags$img(
          src = "https://res.cloudinary.com/g5-assets-cld/image/upload/x_0,y_48,h_3611,w_6565,c_crop/q_auto,f_auto,fl_lossy,g_center,h_1100,w_2000/g5/g5-c-ilk08ojc-maplewood-senior-living-client/g5-cl-55zk892pn-maplewood-healthcare/uploads/Brewster_tpyldu.jpg",  # Replace with the actual image URL
          style = "width:100%; height:auto; margin-bottom:15px;"  # Adjust styles as needed
        ),
        "Offering affordable housing options, this community is ideal for students and young professionals looking for budget-friendly accommodations."
      ),
      easyClose = TRUE
    ))
  })
  
  # Community tab - Property search logic
  observeEvent(input$search_properties, {
    # Base query to select properties within the selected price range from the correct table "Property"
    query <- sprintf(
      "SELECT * FROM Property WHERE p_rent BETWEEN %d AND %d",
      input$price_range[1], input$price_range[2]
    )
    
    # Filtering by property type if specified
    if (input$property_type != "All") {
      query <- paste0(query, sprintf(" AND p_type = '%s'", input$property_type))
    }
    
    # Filtering by availability if specified
    if (input$availability != "All") {
      query <- paste0(query, sprintf(" AND p_availability = '%s'", input$availability))
    }
    
    # Filtering by furnishing status if specified
    if (input$furnish_status != "All") {
      query <- paste0(query, sprintf(" AND p_furnish_status = '%s'", input$furnish_status))
    }
    
    # Executing the query to fetch the data
    tryCatch({
      available_properties <- dbGetQuery(dbConnector1, query)
      
      # Render the available properties in a DataTable
      output$available_properties <- DT::renderDataTable({
        datatable(available_properties, options = list(pageLength = 10))
      })
    }, error = function(e) {
      showModal(modalDialog(
        title = "Error",
        paste("An error occurred while fetching property data:", e$message),
        easyClose = TRUE
      ))
    })
  })
  
  #ASK AI
  observeEvent(input$generate_sql, {
    tryCatch({
      # Fetch user question
      question <- input$question
      print(paste("User Question:", question))
      
      # Call the Python function to generate SQL and template
      py_run_string(paste0("query, template = generate_sql_and_answer('", question, "')"))
      
      # Retrieve the generated SQL and sentence template from Python
      generated_sql <- py$query
      sentence_template <- py$template
      print(paste("Generated SQL Query:", generated_sql))
      print(paste("Sentence Template:", sentence_template))
      
      # Execute the SQL query in the database
      data <- dbGetQuery(dbConnector1, generated_sql)
      print("Query Results Retrieved.")
      
      # Format the sentence response dynamically
      if (!is.null(data) && nrow(data) > 0) {
        # If multiple rows, concatenate values into a comma-separated list
        result_list <- paste(data[[1]], collapse = ", ")
        formatted_sentence <- gsub("\\{result\\}", result_list, sentence_template)
      } else {
        formatted_sentence <- "No data available for the query."
      }
      
      # Display SQL query, explanation, sentence response, and query results in the app
      output$generated_sql <- renderText({ generated_sql })
      output$generated_answer <- renderText({ "Generated SQL query and sentence response successfully." })
      output$query_result_sentence <- renderText({ formatted_sentence })
      output$query_results <- DT::renderDataTable(
        DT::datatable(data, options = list(pageLength = 5, scrollX = TRUE))
      )
    }, error = function(e) {
      # Handle errors gracefully
      print("Error occurred:")
      print(e$message)
      
      # Log Python traceback if available
      python_error <- reticulate::py_last_error()
      print(python_error)
      output$generated_sql <- renderText("Error generating SQL or fetching results.")
      output$generated_answer <- renderText("No explanation available.")
      output$query_result_sentence <- renderText("No sentence available.")
      output$query_results <- renderText("No data to display.")
    })
  })
  
  # Disconnect from the database when the session ends
    session$onSessionEnded(function() {
    DBI::dbDisconnect(dbConnector1)
   })
  
  # Map tab
  output$interactive_map <- renderLeaflet({
    query <- "SELECT * FROM Map"
    map_data <- dbGetQuery(dbConnector1, query)
    
    leaflet(data = map_data) %>%
      addTiles() %>%
      addMarkers(
        ~longitude, 
        ~latitude, 
        popup = ~paste0("<b>", m_name, "</b>")
      )
  })
  
  # Ranking tab
  output$chart_out <- renderPlot({
    query <- "SELECT * FROM Rating"
    rating_data <- dbGetQuery(dbConnector1, query)
    
    # Pivot longer and rename rating_source for better display
    rating_data_long <- rating_data %>%
      pivot_longer(
        cols = c("the_nest_rating", "google_rating", "social_media_rating"), 
        names_to = "rating_source", 
        values_to = "rating_value"
      ) %>%
      mutate(rating_source = case_when(
        rating_source == "the_nest_rating" ~ "The Nest Rating",
        rating_source == "google_rating" ~ "Google Rating",
        rating_source == "social_media_rating" ~ "Social Media Rating",
        TRUE ~ rating_source
      ))
    
    # Create the plot with custom colors
    ggplot(rating_data_long, aes(x = factor(c_id), y = rating_value, fill = rating_source)) +
      geom_bar(stat = "identity", position = "dodge") +
      scale_fill_manual(values = c(
        "The Nest Rating" = "#8E3200",  
        "Google Rating" = "#F5CCA0",     
        "Social Media Rating" = "#BE8C63"
      )) +
      labs(
        title = "Community Ratings by Source", 
        x = "Community ID", 
        y = "Rating (1-10)", 
        fill = "Rating Source"
      ) +
      theme_minimal() +
      theme(
        legend.text = element_text(face = "bold", size = 12),
        axis.title.x = element_text(face = "bold", size = 14),
        axis.title.y = element_text(face = "bold", size = 14),
        plot.title = element_text(face = "bold", size = 16, hjust = 0.5)
      )
  })
  
  output$Rating_DT <- renderDataTable({
    query <- "
        SELECT 
          r.r_id AS 'Rating ID',
          c.c_name AS 'Community Name',
          r.the_nest_rating AS 'The Nest Rating',
          r.google_rating AS 'Google Rating',
          r.social_media_rating AS 'Social Media Rating'
        FROM Rating r
        JOIN Community c ON r.c_id = c.c_id
      "
    rating_data <- dbGetQuery(dbConnector1, query)
    datatable(rating_data, options = list(pageLength = 5))
  })
  
  # Register section
  observeEvent(input$submit_register, {
    if (input$reg_name == "" || input$reg_email == "" || input$reg_phone == "") {
      showModal(modalDialog(
        title = "Error",
        "All fields are required. Please fill in the details.",
        easyClose = TRUE
      ))
    } else {
      tryCatch({
        query_check <- sprintf(
          "SELECT COUNT(*) AS count FROM Tenants WHERE u_phone = '%s'",
          input$reg_phone
        )
        result <- dbGetQuery(dbConnector1, query_check)
        
        if (result$count > 0) {
          showModal(modalDialog(
            title = "Error",
            "A tenant with this phone number already exists. Please use a different phone number.",
            easyClose = TRUE
          ))
        } else {
          query <- sprintf(
            "INSERT INTO Tenants (u_name, u_email, u_phone) VALUES ('%s', '%s', '%s')",
            input$reg_name, input$reg_email, input$reg_phone
          )
          dbExecute(dbConnector1, query)
          showModal(modalDialog(
            title = "Success",
            "Tenant details have been successfully registered!",
            easyClose = TRUE
          ))
          updateTextInput(session, "reg_name", value = "")
          updateTextInput(session, "reg_email", value = "")
          updateTextInput(session, "reg_phone", value = "")
        }
      }, error = function(err) {
        showModal(modalDialog(
          title = "Error",
          paste("An error occurred while saving the details:", err$message),
          easyClose = TRUE
        ))
      })
    }
  })
  
  # Feedback submission logic
  observeEvent(input$submit_feedback, {
    if (input$feedback_email == "" || input$feedback_input == "" || input$feedback_cname == "") {
      showModal(modalDialog(
        title = "Error",
        "All fields are required. Please fill in the details.",
        easyClose = TRUE
      ))
    } else {
      tryCatch({
        # Validate email against Tenants table
        query_check_email <- sprintf(
          "SELECT COUNT(*) AS count FROM Tenants WHERE u_email = '%s'",
          input$feedback_email
        )
        result <- dbGetQuery(dbConnector1, query_check_email)
        
        if (result$count == 0) {
          # Email not found in Tenants table
          showModal(modalDialog(
            title = "Error",
            "The email address you entered is not registered. Please use a registered email.",
            easyClose = TRUE
          ))
        } else {
          # Insert feedback into Feedbacks table
          query_insert_feedback <- sprintf(
            "INSERT INTO Feedbacks (f_message, u_email, c_name) VALUES ('%s', '%s', '%s')",
            input$feedback_input, input$feedback_email, input$feedback_cname
          )
          dbExecute(dbConnector1, query_insert_feedback)
          showModal(modalDialog(
            title = "Success",
            "Your feedback has been submitted successfully!",
            easyClose = TRUE
          ))
          
          # Clear inputs
          updateTextInput(session, "feedback_email", value = "")
          updateTextAreaInput(session, "feedback_input", value = "")
          updateSelectInput(session, "feedback_cname", selected = NULL)
          
          # Refresh feedback table
          output$feedback_table <- renderDataTable({
            data <- dbGetQuery(dbConnector1, "SELECT * FROM Feedbacks")
            colnames(data) <- c("Feedback", "Email", "Community")
            datatable(data, options = list(pageLength = 10))
          })
          
        }
      }, error = function(err) {
        showModal(modalDialog(
          title = "Error",
          paste("An error occurred while submitting your feedback:", err$message),
          easyClose = TRUE
        ))
      })
    }
  })
  
  # Display all feedback in the table
  output$feedback_table <- renderDataTable({
    dbGetQuery(dbConnector1, "SELECT f_message AS 'Feedback', u_email AS 'Email', c_name AS 'Community' FROM Feedbacks")
  })
  
  
  
  # Admin Panel CRUD Logic for Communities and Properties is directly integrated
  output$community_table <- renderDataTable({
    dbGetQuery(dbConnector1, "SELECT * FROM Community")
  })
  
  observeEvent(input$add_community, {
    query <- sprintf(
      "INSERT INTO Community (c_id, c_name, c_address, c_zip, c_city, c_description, c_units) VALUES ('%s', '%s', '%s', '%s', '%s', '%s', %d)",
      input$c_id, input$c_name, input$c_address, input$c_zip, input$c_city, input$c_description, input$c_units
    )
    dbExecute(dbConnector1, query)
    showModal(modalDialog(title = "Success", "Community added successfully!", easyClose = TRUE))
    output$community_table <- renderDataTable({
      dbGetQuery(dbConnector1, "SELECT * FROM Community")
    })
  })
  
  observeEvent(input$update_community, {
    query <- sprintf(
      "UPDATE Community SET c_name='%s', c_address='%s', c_zip='%s', c_city='%s', c_description='%s', c_units=%d WHERE c_id='%s'",
      input$c_name, input$c_address, input$c_zip, input$c_city, input$c_description, input$c_units, input$c_id
    )
    dbExecute(dbConnector1, query)
    showModal(modalDialog(title = "Success", "Community updated successfully!", easyClose = TRUE))
    output$community_table <- renderDataTable({
      dbGetQuery(dbConnector1, "SELECT * FROM Community")
    })
  })
  
  observeEvent(input$delete_community, {
    query <- sprintf("DELETE FROM Community WHERE c_id='%s'", input$c_id)
    dbExecute(dbConnector1, query)
    showModal(modalDialog(title = "Success", "Community deleted successfully!", easyClose = TRUE))
    output$community_table <- renderDataTable({
      dbGetQuery(dbConnector1, "SELECT * FROM Community")
    })
  })
  
  output$property_table <- renderDataTable({
    dbGetQuery(dbConnector1, "SELECT * FROM Property")
  })
  
  observeEvent(input$add_property, {
    query <- sprintf(
      "INSERT INTO Property (p_id, p_type, p_rent, p_availability, p_furnish_status, p_description, c_id, admin_id) VALUES ('%s', '%s', %f, '%s', '%s', '%s', '%s', '%s')",
      input$p_id, input$p_type, input$p_rent, input$p_availability, input$p_furnish_status, input$p_description, input$c_id_property, input$admin_id
    )
    dbExecute(dbConnector1, query)
    showModal(modalDialog(title = "Success", "Property added successfully!", easyClose = TRUE))
    output$property_table <- renderDataTable({
      dbGetQuery(dbConnector1, "SELECT * FROM Property")
    })
  })
  
  observeEvent(input$update_property, {
    query <- sprintf(
      "UPDATE Property SET p_type='%s', p_rent=%f, p_availability='%s', p_furnish_status='%s', p_description='%s', c_id='%s', admin_id='%s' WHERE p_id='%s'",
      input$p_type, input$p_rent, input$p_availability, input$p_furnish_status, input$p_description, input$c_id_property, input$admin_id, input$p_id
    )
    dbExecute(dbConnector1, query)
    showModal(modalDialog(title = "Success", "Property updated successfully!", easyClose = TRUE))
    output$property_table <- renderDataTable({
      dbGetQuery(dbConnector1, "SELECT * FROM Property")
    })
  })
  
  observeEvent(input$delete_property, {
    query <- sprintf("DELETE FROM Property WHERE p_id='%s'", input$p_id)
    dbExecute(dbConnector1, query)
    showModal(modalDialog(title = "Success", "Property deleted successfully!", easyClose = TRUE))
    output$property_table <- renderDataTable({
      dbGetQuery(dbConnector1, "SELECT * FROM Property")
    })
  })
}

shinyApp(ui = ui, server = server)