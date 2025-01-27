library(tidymodels)
data(attrition)

set.seed(123)
att_split <- attrition |>
  mutate(JobSatisfaction = factor(JobSatisfaction, ordered = FALSE)) |>
  initial_split(attrition, prop = 0.5, strata = Attrition)
att_train <- training(att_split)
att_test <- testing(att_split)
nanoparquet::write_parquet(att_test, "attrition-eval.parquet")

final_fit <-
  workflow(
    Attrition ~ JobSatisfaction + MonthlyIncome + OverTime + Department,
    rand_forest(mode = "classification")
  ) %>%
    last_fit(att_split)

library(vetiver)
library(pins)
b <- board_connect()
rf_fit <- extract_workflow(final_fit)
v <- vetiver_model(rf_fit, "julia.silge/attrition-rf")
b |> vetiver_pin_write(v)
