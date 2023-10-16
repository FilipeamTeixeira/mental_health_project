
function(input, output, session) {
  


  
#### Plot - Distance ran per week ####
  output$week_dist <- renderPlotly(
    assessment %>%
      group_by(monday) %>%
      filter(row_number()==1) %>%
      ungroup() %>% #plotly bug doesn't plot grouped data
      plot_ly(x = ~monday, y = ~weekly_distance, type = 'scatter') %>%
      layout(title = "Weekly Distance",
             xaxis = list(title = "Week"), yaxis = list(title = "Km")))

  
  
#### Render choices for week selection ####
  
  output$week_select <- renderUI({
    # Get unique categories from your data frame
    categories <- unique(date(assessment$monday))
    # Create the selectInput widget with dynamic choices
    selectInput("week_select", "Select a Category", choices = categories)
  })
  
  
#### Plot - Sleep Score per day ####
  
output$sleep_score <- renderPlotly(
  assessment %>%
    plot_ly(x = ~date, y = ~sleep_score, type = 'scatter',
            marker = list(color = '#EDCB64')) %>%
    layout(title = "Sleep time",
           xaxis = list(title = "Day"), yaxis = list(title = "Minutes")))


#### Plot - Stress ####

output$stress_plot <- renderPlotly(
  
assessment %>%
  group_by(month_start, stress) %>%
  summarize(count = n()) %>%
  left_join(
    assessment %>%
      group_by(month_start) %>%
      summarise(distance = sum(distance)), by = "month_start"
  ) %>%
  group_by(month_start) %>%
  mutate(count_percent = count / sum(count) * 100) %>%
  plot_ly() %>%
  add_trace(x = ~month_start, y = ~count_percent, color = ~stress, type = 'bar',
            yaxis = "y1", alpha = .7) %>%
  add_trace(x = ~month_start, y = ~round(distance), type = "scatter",
            marker = list(color = "#F24D29"),
            mode = "markers", yaxis = "y2", name = "Distance Ran") %>%
  layout(barmode = 'stack',
         yaxis2 = list(overlaying = "y", side = "right",
                       tickfont = list(size = 10)),
         title = "Stress / Distance Ran",
         xaxis = list(title = "Month",
                      tickfont = list(size = 10)),
         yaxis = list(title = "", tickvals = list(0, 25, 50, 75, 100),
                      tickfont = list(size = 10)),
         legend = list(bgcolor = 'rgba(0,0,0,0)', x = 1.05, y = 1,
                       font = list(size = 10)),
         margin = list(l = 50, r = 50, b = 50, t = 50, pad = 4))
)


#### Plot - Energy ####

output$energy_plot <- renderPlotly(
assessment %>%
  group_by(month_start, energy) %>%
  summarize(count = n()) %>%
  left_join(
    assessment %>%
      group_by(month_start) %>%
      summarise(distance = sum(distance)), by = "month_start"
  ) %>%
  group_by(month_start) %>%
  mutate(count_percent = count / sum(count) * 100) %>%
  plot_ly() %>%
  add_trace(x = ~month_start, y = ~count_percent, color = ~energy, type = 'bar',
            yaxis = "y1", alpha = .7) %>%
  add_trace(x = ~month_start, y = ~round(distance), type = "scatter",
            marker = list(color = "#F24D29"),
            mode = "markers", yaxis = "y2", name = "Distance Ran") %>%
  layout(barmode = 'stack',
         yaxis2 = list(overlaying = "y", side = "right",
                       tickfont = list(size = 10)),
         title = "Energy / Distance Ran",
         xaxis = list(title = "Month",
                      tickfont = list(size = 10)),
         yaxis = list(title = "", tickvals = list(0, 25, 50, 75, 100),
                      tickfont = list(size = 10)),
         legend = list(bgcolor = 'rgba(0,0,0,0)', x = 1.05, y = 1,
                       font = list(size = 10)),
         margin = list(l = 50, r = 50, b = 50, t = 50, pad = 4))
)

#### Plot - Feeling ####

output$feeling_plot <- renderPlotly(

  assessment %>%
  group_by(month_start, feeling) %>%
  summarize(count = n()) %>%
  left_join(
    assessment %>%
      group_by(month_start) %>%
      summarise(distance = sum(distance)), by = "month_start"
  ) %>%
  group_by(month_start) %>%
  mutate(count_percent = count / sum(count) * 100) %>%
  plot_ly() %>%
  add_trace(x = ~month_start, y = ~count_percent, color = ~feeling, type = 'bar',
            yaxis = "y1", alpha = .7) %>%
  add_trace(x = ~month_start, y = ~round(distance), type = "scatter",
            marker = list(color = "#F24D29"),
            mode = "markers", yaxis = "y2", name = "Distance Ran") %>%
  layout(barmode = 'stack',
         yaxis2 = list(overlaying = "y", side = "right",
                       tickfont = list(size = 10)),
         title = "Feeling / Distance Ran",
         xaxis = list(title = "Month",
                      tickfont = list(size = 10)),
         yaxis = list(title = "", tickvals = list(0, 25, 50, 75, 100),
                      tickfont = list(size = 10)),
         legend = list(bgcolor = 'rgba(0,0,0,0)', x = 1.05, y = 1,
                       font = list(size = 10)),
         margin = list(l = 50, r = 50, b = 50, t = 50, pad = 4))
)






#### Rose Plot - Combination of all factors ####

output$group_score <- renderPlotly(
  
  assessment %>%
    group_by(monday) %>%
    summarise(distance = weekly_distance[1],
              speed = weekly_speed[1],
              energy = sum(as.numeric(energy))/n(),
              feeling = sum(as.numeric(feeling))/n(),
              stress = sum(as.numeric(stress))/n(),
              interruptions = sum(interruptions)/n(),
              sleep_time =  sum(sleep_time)/n(),
              sleep_score = sum(sleep_score)/n()) %>%
    ungroup() %>%
    mutate_at(2:9, normalize, na.rm = TRUE) %>%
    mutate(monday = date(monday)) %>%
    filter(monday == input$week_select) %>%
    select(2:9) %>%
    t() %>%
    data.frame() %>%
    rownames_to_column(., var = "type") %>%
    rename(value = '.') %>%
    mutate(color = case_when(
      type == "interruptions" |
        type == "sleep_time" |
        type == "sleep_score" ~ "#1DACE8",
      type == "distance" |
        type == "speed" ~ "#F24D29",
      type == "energy" |
        type == "feeling" |
        type == "stress" ~ "#EDCB64",
    )) %>%
    plot_ly(type = 'barpolar',
            r = ~value, theta = ~type,
            marker = list(color = ~color,
                          line = list(color = "black", width = .5))) %>%
    layout(
      polar = list(
        radialaxis = list(
          ticks = "",
          showline = FALSE,
          showticklabels = FALSE
        ),
        bargap = 0,   # Set bargap to 0 to remove space between bars
        bargroupgap = 0,  # Set bargroupgap to 0 to remove space between bar groups
        radialaxis = list(
          range = c(0, 1)  # Set the range for the radial axis to 0 and 1
        )
      ),
      margin = list(l = 40, r = 60)
    )
)


#### Return overall stats ####
# Total Km
output$km_year <- renderText({
assessment %>%
  ungroup() %>%
  summarise(distance = sum(distance),
            speed = sum(average_speed)/n(),
            energy = names(which.max(table(energy))),
            feeling = names(which.max(table(feeling))),
            stress = names(which.max(table(stress))),
            interruptions = sum(interruptions)/n(),
            sleep_time =  sum(sleep_time)/n(),
            sleep_score = sum(sleep_score)/n()) %>%
    mutate_if(is.numeric, round) %>%
    select(distance) %>%
    paste("km")
})

output$stress <- renderText({
  assessment %>%
    ungroup() %>%
    summarise(distance = sum(distance),
              speed = sum(average_speed)/n(),
              energy = names(which.max(table(energy))),
              feeling = names(which.max(table(feeling))),
              stress = names(which.max(table(stress))),
              interruptions = sum(interruptions)/n(),
              sleep_time =  sum(sleep_time)/n(),
              sleep_score = sum(sleep_score)/n()) %>%
    mutate_if(is.numeric, round) %>%
    select(stress) %>%
    paste()
})

output$energy <- renderText({
  assessment %>%
    ungroup() %>%
    summarise(distance = sum(distance),
              speed = sum(average_speed)/n(),
              energy = names(which.max(table(energy))),
              feeling = names(which.max(table(feeling))),
              stress = names(which.max(table(stress))),
              interruptions = sum(interruptions)/n(),
              sleep_time =  sum(sleep_time)/n(),
              sleep_score = sum(sleep_score)/n()) %>%
    mutate_if(is.numeric, round) %>%
    select(energy) %>%
    paste()
})

output$feeling <- renderText({
  assessment %>%
    ungroup() %>%
    summarise(distance = sum(distance),
              speed = sum(average_speed)/n(),
              energy = names(which.max(table(energy))),
              feeling = names(which.max(table(feeling))),
              stress = names(which.max(table(stress))),
              interruptions = sum(interruptions)/n(),
              sleep_time =  sum(sleep_time)/n(),
              sleep_score = sum(sleep_score)/n()) %>%
    mutate_if(is.numeric, round) %>%
    select(feeling) %>%
    paste()
})


#### Calculate How am I ####

# Listen to multiple events
toListen <- reactive({
  list(input$distance_input,input$sleep_input)
})

observeEvent(toListen(), {
  
  avg_prev_distance <- input$distance_input  
  avg_prev_sleep <- input$sleep_input   
  
  predicted_happiness <- predict_happiness(avg_prev_distance, avg_prev_sleep)
  
  if(predicted_happiness >= 0 & predicted_happiness < 2){
    output$howamI <- renderUI(HTML(as.character(div(style="color: #F24d29; font-size:40px;",
                                                    paste("Terrible")))))
    
  }
  if(predicted_happiness >= 2 & predicted_happiness < 3){
    output$howamI <- renderUI(HTML(as.character(div(style="color: #EDCB64; font-size:40px;",
                                                    paste("Ok")))))  }
  
  if(predicted_happiness >= 3 & predicted_happiness < 4){
    output$howamI <- renderUI(HTML(as.character(div(style="color: #1DACE8; font-size:40px;",
                                                    paste("Good")))))
  }
  
  if(predicted_happiness >= 4 & predicted_happiness < 5){
    output$howamI <- renderUI(HTML(as.character(div(style="color: green; font-size:40px;",
                                                    paste("Excellent")))))
  }
  
})


}