

library(shiny)
library(shinydashboard)
shinyUI(
  dashboardPage(
    dashboardHeader(),
    dashboardSidebar(
      sidebarMenu(
        menuItem("Upload Dataset", tabName = "upload", icon = icon("dashboard")),
        menuItem("Visualization", tabName = "vis", icon = icon("dashboard")),
        menuItem("Visualization (ACF-PACF) ", tabName = "vis_acf", icon = icon("dashboard")),
        menuItem("Comparison ", tabName = "comp", icon = icon("dashboard")),
        menuItem("Accuracy", tabName = "accuracy", icon = icon("dashboard"))
        
        
      )
    ),
    #-----------------------------------------
    dashboardBody(
      
      tabItems(
        #-------------------first page-------------------------
        # First tab content
        tabItem(
          tabName = "upload",
          fluidRow(
            box(
              width = 12,
              title = "Upload your data set",
              status= "info",
              solidHaider = TRUE,
              collapsible = TRUE,
              
              # Copy the line below to make a set of radio buttons
              radioButtons("radio", label = h4("Select Company"),
                           choices = list("Apple" = 1 , "Google" = 2, "Microsoft" = 3, "Spyder Market" = 4), selected = 1),
              
              actionButton("upload","upload",class="btn btn-info")
            ),
            
            box(
              width = 12,
              title = "Your data set",
              status= "success",
              solidHaider = TRUE,
              collapsible = TRUE,
              dataTableOutput("my_data")
            )
          )
        ),
        #------------------------------------------------------------------------------------------------------------
        #----------------------second page -------------------------------------------
        # Second tab content
        tabItem(tabName = "vis",
                fluidRow(
                      
                      box(
                        width = 12,
                        title = "ploting data of close attrubute",
                        status= "info",
                        solidHaider = TRUE,
                        collapsible = TRUE,
                        plotOutput("plot_close", click = "plot_close")
                       
                       ),
                      box(
                        width = 12,
                        title = "ploting of stationary data of close attrubute",
                        status= "info",
                        solidHaider = TRUE,
                        collapsible = TRUE,
                        plotOutput("plot_stationary", click = "plot_stationary")
                      )
                      
                  )
                
                
        ),
        #---------------------------------third page---------------------------------------------------------------------------
        # Third tab content
        tabItem(tabName = "vis_acf",
                fluidRow(
                  
                  box(
                    width = 12,
                    title = "ploting ACF",
                    status= "info",
                    solidHaider = TRUE,
                    collapsible = TRUE,
                    plotOutput("plot_acf", click = "plot_acf")
                    
                  ),
                  box(
                    width = 12,
                    title = "ploting PACF",
                    status= "info",
                    solidHaider = TRUE,
                    collapsible = TRUE,
                    plotOutput("plot_pacf", click = "plot_pacf")
                  )
                  
                )
                
                
        ),
        #---------------------------------------fourth-----------------------
        # Fourth tab content
        
        tabItem(tabName = "comp",
                fluidRow(
                  box(
                    width = 12,
                    title = "Actual and Forecasted plot (Black is Actual) (Red is Forecasted)",
                    status= "info",
                    solidHaider = TRUE,
                    collapsible = TRUE,
                    plotOutput("plot_afp", click = "plot_afp")
                    
                  ),
                  
                  box(
                    width = 12,
                    title = "View Comparison",
                    status= "info",
                    solidHaider = TRUE,
                    collapsible = TRUE,
                    dataTableOutput("my_comparison")
                
                    
                  )
                  
                )
                
                
        ),
        
        #---------------------------------------fifth-----------------------
        # Fifth tab content
        
        tabItem(tabName = "accuracy",
                fluidRow(
                  box(
                    width = 12,
                    title = "View Accuracy",
                    status= "info",
                    solidHaider = TRUE,
                    collapsible = TRUE,
                    valueBoxOutput("Accuracy_Box")
                    
                    
                  )
          
                )
        )
        #-----------------------------------------------------------------------

      )
      
    )
  )
)
