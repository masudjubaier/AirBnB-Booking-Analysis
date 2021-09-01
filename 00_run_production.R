#### 00_run_production ####

n <- Sys.time() 

user <- Sys.info()[["user"]]
sysname <- Sys.info()[["sysname"]]
eda <- FALSE

#### working directory ----
if (user == "scgst"){
  dir.home <- paste0("C:/Users/scgst/Documents/Git/STAT5003_Assignment")
} else if (user == "rcha8"){
  dir.home <- paste0("C:/Users/rcha8/OneDrive/Documents/GitHub/STAT5003_Assignment")
} else if (user == "nalla"){
  dir.home <- paste0("C:/Users/nalla/Documents/GitHub/STAT5003_Assignment")
} else if (user == "honey"){
  dir.home <- paste0("C:/Users/honey/Dropbox (Sydney Uni)/GIT/STAT5003_Assignment")
} else if (user == "Masud"){
  dir.home <- paste0("D:/Document/Sydney Uni/STAT5003 Computational Statistical Methods/My Course/Assignment/Team Work/STAT5003_Assignment")
}
setwd(dir.home)


#### Load Packages ----
packages <- c(
  "data.table", # Data Manipulation
  "bit64",      # To load datatype integer64 
  "plotly",     # Visualisations
  "GGally",     # Visualisations - heat map
  "dplyr",      # Data Manipulation
  "ggplot2",    # Visualisations
  "wordcloud",  # Visualisations
  "scales",
  "forcats",
  "e1071",      # skewness function
  "rmarkdown",  # rmarkdown::render
  "caret"       # Modelling
)

load_packages <- function(packages){
  new.packages <- packages[!(packages %in% installed.packages()[, "Package"])]
  if (length(new.packages)){
    install.packages(new.packages)
  } 
  sapply(packages, require, character.only = TRUE)
}

load_packages(packages)


#### parameters ----
source(file.path(dir.home, "98_parameters.R"))

#### functions ----
source(file.path(dir.home, "99_functions.R"))

#### etl ---
path_fact.destinations <- file.path(dir.input, "fact.destinations.csv")
path_fact.sessions <- file.path(dir.input, "fact.sessions.csv")
if (!file.exists(path_fact.destinations) | !file.exists(path_fact.sessions)){
  source(file.path(dir.home, "1.1_etl.R"))
}

#### Read in data
fact.destinations <- fread(path_fact.destinations)
fact.sessions <- fread(path_fact.sessions)

fact.destinations[, ":=" (
  date_account_created = convert_date_format(date_account_created),
  date_first_booking = convert_date_format(date_first_booking),
  date_first_active = convert_date_format(date_first_active)
)]

# Remove NDF users
fact.destinations <- fact.destinations[country_destination != ""]
fact.destinations <- fact.destinations[country_destination != "NDF"]

#### eda ----
if (eda == TRUE){
  rmarkdown::render(file.path(dir.home, "2.1_eda.Rmd"), "html_document")
  rmarkdown::render(file.path(dir.home, "2.2_eda.Rmd"), "html_document")
  rmarkdown::render(file.path(dir.home, "2.3_eda.Rmd"), "html_document")
}

#### Clean the columns got by joining to other csv files ----
suppressWarnings({
  fact.destinations[, ":=" (
    age_bucket = NULL,
    population_in_thousands = NULL,
    lat_destination = NULL,
    lng_destination = NULL,
    distance_km = NULL,
    destination_km2 = NULL,
    destination_language = NULL,
    language_levenshtein_distance = NULL
  )]
})

#### Features Enginnering ----
model_file <- copy(fact.destinations)[, ":=" (
  id = NULL,
  date_account_created = NULL,
  timestamp_first_active = NULL,
  date_first_booking = NULL,
  date_first_active = NULL,
  date_first_booking_end_week = NULL,
  first_active_year_month = NULL,
  first_account_year_month = NULL,
  first_booking_year_month = NULL,
  first_booking_year = NULL
)]

model_file <- model_file[, ":=" (
  gender = as.integer(as.factor(gender)),
  age = as.numeric(age),
  signup_method = as.integer(as.factor(signup_method)),
  signup_flow = as.numeric(signup_flow),
  language = as.integer(as.factor(language)),
  affiliate_channel = as.integer(as.factor(affiliate_channel)),
  affiliate_provider = as.integer(as.factor(affiliate_provider)),
  first_affiliate_tracked = as.integer(as.factor(first_affiliate_tracked)),
  signup_app = as.integer(as.factor(signup_app)),
  first_device_type = as.integer(as.factor(first_device_type)),
  first_browser = as.integer(as.factor(first_browser)),
  country_destination = as.factor(country_destination),
  days_from_active_to_account = as.numeric(days_from_active_to_account),
  days_from_account_to_booking = as.numeric(days_from_account_to_booking),
  days_from_active_to_booking = as.numeric(days_from_active_to_booking)
)]


#### NAs ----
# Check NAs
row.has.na <- apply(model_file, 1, function(x){any(is.na(x))})
sum(row.has.na)

# Remove NAs
model_file <- model_file[complete.cases(model_file),]
which(is.na(model_file))


#### Modelling ####
if (user == "scgst"){
  source(file.path(dir.home, "3.1_model_stefan.R"))
} else if (user == "rcha8"){
  source(file.path(dir.home, "3.1_model_bec.R"))
} else if (user == "nalla"){
  source(file.path(dir.home, "3.1_model_nalla.R"))
} else if (user == "honey"){
  source(file.path(dir.home, "3.1_model_hexian.R"))
} else if (user == "Masud"){
  source(file.path(dir.home, "3.1_model_masud.R"))
}

#### Evaluation #### 



Sys.time() - n
