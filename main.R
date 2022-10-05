library(Robyn)

robyn_object <- "/root/MyRobyn.RDS"

InputCollect <- robyn_inputs(
  dt_input = dt_simulated_weekly
  ,dt_holidays = dt_prophet_holidays
  ,date_var = "DATE" # date format must be "2020-01-01"
  ,dep_var = "revenue" # there should be only one dependent variable
  ,dep_var_type = "revenue" # "revenue" or "conversion"
  ,context_vars = c("competitor_sales_B", "events")
  ,paid_media_spends = c("tv_S","ooh_S","print_S","facebook_S", "search_S")
  ,paid_media_vars = c("tv_S", "ooh_S", "print_S","facebook_I","search_clicks_P") 
  ,organic_vars = c("newsletter")
  ,factor_vars = c("events")
  ,window_start = "2016-11-23"
  ,window_end = "2018-08-22"
  ,prophet_vars = c("trend", "season", "holiday")
  ,prophet_country = "US"
  ,adstock = "geometric"
)

## ハイパーパラメータの設定
hyper_names(adstock = InputCollect$adstock, all_media = InputCollect$all_media)
 
hyperparameters <- list(
  facebook_S_alphas = c(0.5, 3)
  ,facebook_S_gammas = c(0.3, 1)
  ,facebook_S_thetas = c(0, 0.3)
  
  ,print_S_alphas = c(0.5, 3)
  ,print_S_gammas = c(0.3, 1)
  ,print_S_thetas = c(0.1, 0.4)
  
  ,tv_S_alphas = c(0.5, 3)
  ,tv_S_gammas = c(0.3, 1)
  ,tv_S_thetas = c(0.3, 0.8)
  
  ,search_S_alphas = c(0.5, 3)
  ,search_S_gammas = c(0.3, 1)
  ,search_S_thetas = c(0, 0.3)
  
  ,ooh_S_alphas = c(0.5, 3)
  ,ooh_S_gammas = c(0.3, 1)
  ,ooh_S_thetas = c(0.1, 0.4)
  
  ,newsletter_alphas = c(0.5, 3)
  ,newsletter_gammas = c(0.3, 1)
  ,newsletter_thetas = c(0.1, 0.4)
)

InputCollect <- robyn_inputs(InputCollect = InputCollect, hyperparameters = hyperparameters)

OutputModels <- robyn_run(
  InputCollect = InputCollect, # feed in all model specification
  # cores = NULL, # default to max available
  # add_penalty_factor = FALSE, # Untested feature. Use with caution.
  iterations = 20, # recommended for the dummy dataset
  trials = 2, # recommended for the dummy dataset
  outputs = FALSE # outputs = FALSE disables direct model output - robyn_outputs()
)

OutputCollect <- robyn_outputs(
InputCollect, OutputModels
, pareto_fronts = 1
# , calibration_constraint = 0.1 # range c(0.01, 0.1) &amp; default at 0.1
, csv_out = "all" # "pareto" or "all"
, clusters = TRUE # Set to TRUE to cluster similar models by ROAS. See ?robyn_clusters
, plot_pareto = TRUE # Set to FALSE to deactivate plotting and saving model one-pagers
, plot_folder = robyn_object # path for plots export
, plot_folder_sub = "exports"
)

cat("Select model: ")
select_model <- readLines("stdin", n=1)

AllocatorCollect <- robyn_allocator(
InputCollect = InputCollect
, OutputCollect = OutputCollect
, select_model = select_model
, scenario = "max_historical_response"
, channel_constr_low = c(0.01, 0.01, 0.01, 0.01, 0.01) #メディア数と同じ長さが必要。元の投下量に対して何%まで変化を許容するかの下限
, channel_constr_up = c(10, 10, 10, 10, 10) #メディア数と同じ長さが必要。元の投下量に対して何%まで変化を許容するかの上限
 
)

AllocatorCollect$dt_optimOut
