library(shiny)
library(shinyjs)
library(tidyverse)
library(plotly)
library(shinyWidgets)

library(shiny)
library(tidyverse)
library(plotly)


#### Import data and load functions####

normalize <- function(x, ...) {
  return((x - min(x, ...)) /(max(x, ...) - min(x, ...)))
}

assessment <- readRDS("data/assessment.rds")

#### Calculate coefficients ####

model <- assessment %>%
  mutate(total = mean(c(as.numeric(feeling), as.numeric(energy), as.numeric(stress)))) %>%
  group_by(monday, weekly_distance) %>%
  summarise(total = mean(total), sleep_score = mean(sleep_score)) %>%
  lm(total ~ weekly_distance + sleep_score, .)

intercept <- coef(model)[1]
coef_avg_prev_distance <- coef(model)[2]
coef_avg_prev_sleep <- coef(model)[3]

# Define a function to calculate happiness score based on average previous distance and sleep score
predict_happiness <- function(avg_prev_distance, avg_prev_sleep) {
  happiness_score <- intercept + (coef_avg_prev_distance * avg_prev_distance) + (coef_avg_prev_sleep * avg_prev_sleep)
  return(happiness_score)
}