#### ETL ####

#### fact.destinations ----
fact.train <- fread(file.path(dir.data, "train_users_2.csv"))

# # Data type
# fact.train[, dataset_type := "TRAIN"]
# fact.test[, ":=" (country_destination = NA, dataset_type = "TEST")]
# 
# # Combine Train and Test
# fact.destinations <- rbind(fact.train, fact.test)

fact.destinations <- fact.train
# Extract date_first_active and hour_first_active from timesteamp_first_active
fact.destinations[, year_active := floor(timestamp_first_active / 10000000000)
                  ][, month_active := floor((timestamp_first_active - year_active * 10000000000) / 100000000)
                  ][, day_active := floor((timestamp_first_active - year_active * 10000000000 - month_active * 100000000) / 1000000)
                  ][, hour_first_active := floor((timestamp_first_active - year_active * 10000000000 - month_active * 100000000 - day_active * 1000000) / 10000)
                  ][, date_first_active := as.Date(paste(year_active, month_active, day_active, sep = "-"), format = "%Y-%m-%d")
                  ][, ":=" (year_active = NULL, month_active = NULL, day_active = NULL)]

# Convert date format for date_accounted_created and date_first_booking
fact.destinations <- 
  fact.destinations[, ":=" (
    date_account_created = convert_date_format(date_account_created),
    date_first_booking = convert_date_format(date_first_booking)
  )]
# fact.destinations[, .N, by = .(dataset_type, country_destination, date_first_booking)][is.na(date_first_booking)]

# Build new features - days between active, account, booking
fact.destinations[, ":=" (days_from_active_to_account = date_account_created - date_first_active,
                          days_from_account_to_booking = date_first_booking - date_account_created, # some people book it without an account
                          days_from_active_to_booking = date_first_booking - date_first_active
                          )]

# Adding year, month, year-month features
fact.destinations[, ":=" (
  date_first_booking_end_week = convert_date_format(date_first_booking + 7 - find_Weekday_Index(date_first_booking)),
  first_active_year_month =  format(as.Date(date_first_active), "%Y-%m"),
  first_account_year_month =  format(as.Date(date_account_created), "%Y-%m"),
  first_booking_year_month =  format(as.Date(date_first_booking), "%Y-%m"),
  first_booking_year = year(date_first_booking),
  first_booking_month = month(date_first_booking)
)]

fwrite(fact.destinations, paste0(dir.input, "/fact.destinations.csv"))

#### fact.sessions ----
fact.sessions <- fread(file.path(dir.data, "sessions.csv"))
fwrite(fact.sessions, paste0(dir.input, "/fact.sessions.csv"))
