library(plotly)

Technology <- c("RNA-seq", "RNA-seq (Survival)", "Microarray", "Microarray (Survival)")
Counts <- c(247-51, 51, 1963-394, 394)

data <- data.frame(

data <- data.frame("Technology" = Technology, "Counts" = Counts)


colors <- c('rgb(171,104,87)', 'rgb(128,133,133)', 'rgb(114,147,203)', 'rgb(144,103,167)')

p <- plot_ly(data, labels = ~Technology, values = ~Counts, type = 'pie',
        textposition = 'inside',
        textinfo = 'label+percent',
        insidetextfont = list(color = '#FFFFFF'),
        hoverinfo = 'text',
        text = ~paste(Counts, " samples"),
        marker = list(colors = colors,
                      line = list(color = '#FFFFFF', width = 1)),
                      #The 'pull' attribute can also be used to create space between the sectors
        showlegend = FALSE) %>%
  layout(title = 'Sample distribution by data type',
         xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
         yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))

##### Save the pie chart as html (PLOTLY)
htmlwidgets::saveWidget(as_widget(p), "DataStats_pie.html")
