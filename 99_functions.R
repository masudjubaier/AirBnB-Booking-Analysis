#### functions #####

#### Change Date Format ####
convert_date_format<- function(x){
  as.Date(x, format = "%Y-%m-%d")
}

#### Get mode ####
getmode <- function(v) {
  uniqv <- unique(v)
  uniqv[which.max(tabulate(match(v, uniqv)))]
}

# https://stackoverflow.com/questions/22439540/how-to-get-week-numbers-from-dates
find_Weekday_Index <- function(myDate){
  # Find out the start day of week 1; that is the date of first Mon in the year
  myDate <- convert_date_format(myDate)
  weekDay <- weekdays(myDate)
  
  weekDay_index <- 
    ifelse(
      weekDay == "Monday",
      1,
      ifelse(
        weekDay == "Tuesday",
        2,
        ifelse(
          weekDay == "Wednesday",
          3,
          ifelse(
            weekDay == "Thursday",
            4,
            ifelse(
              weekDay == "Friday",
              5,
              ifelse(
                weekDay == "Saturday",
                6,
                ifelse(
                  weekDay == "Sunday",
                  7,
                  0
                )
              )
            )
          )
        )
      )
    )

  return(weekDay_index)
}
