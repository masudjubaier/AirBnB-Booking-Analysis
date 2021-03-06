Airbnb New User Bookings
================

``` r
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
```

    ## Loading required package: data.table

    ## Warning: package 'data.table' was built under R version 3.6.3

    ## Loading required package: bit64

    ## Warning: package 'bit64' was built under R version 3.6.3

    ## Loading required package: bit

    ## 
    ## Attaching package: 'bit'

    ## The following object is masked from 'package:data.table':
    ## 
    ##     setattr

    ## The following object is masked from 'package:base':
    ## 
    ##     xor

    ## Attaching package bit64

    ## package:bit64 (c) 2011-2017 Jens Oehlschlaegel

    ## creators: integer64 runif64 seq :

    ## coercion: as.integer64 as.vector as.logical as.integer as.double as.character as.bitstring

    ## logical operator: ! & | xor != == < <= >= >

    ## arithmetic operator: + - * / %/% %% ^

    ## math: sign abs sqrt log log2 log10

    ## math: floor ceiling trunc round

    ## querying: is.integer64 is.vector [is.atomic} [length] format print str

    ## values: is.na is.nan is.finite is.infinite

    ## aggregation: any all min max range sum prod

    ## cumulation: diff cummin cummax cumsum cumprod

    ## access: length<- [ [<- [[ [[<-

    ## combine: c rep cbind rbind as.data.frame

    ## WARNING don't use as subscripts

    ## WARNING semantics differ from integer

    ## for more help type ?bit64

    ## 
    ## Attaching package: 'bit64'

    ## The following objects are masked from 'package:base':
    ## 
    ##     %in%, :, is.double, match, order, rank

    ## Loading required package: plotly

    ## Loading required package: ggplot2

    ## 
    ## Attaching package: 'plotly'

    ## The following object is masked from 'package:ggplot2':
    ## 
    ##     last_plot

    ## The following object is masked from 'package:stats':
    ## 
    ##     filter

    ## The following object is masked from 'package:graphics':
    ## 
    ##     layout

    ## Loading required package: GGally

    ## Registered S3 method overwritten by 'GGally':
    ##   method from   
    ##   +.gg   ggplot2

    ## Loading required package: dplyr

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:data.table':
    ## 
    ##     between, first, last

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

    ## Loading required package: wordcloud

    ## Loading required package: RColorBrewer

    ## Loading required package: scales

    ## Warning: package 'scales' was built under R version 3.6.3

    ## Loading required package: forcats

    ## Warning: package 'forcats' was built under R version 3.6.3

    ## Loading required package: e1071

    ## Loading required package: rmarkdown

    ## Loading required package: caret

    ## Loading required package: lattice

    ## data.table      bit64     plotly     GGally      dplyr    ggplot2  wordcloud 
    ##       TRUE       TRUE       TRUE       TRUE       TRUE       TRUE       TRUE 
    ##     scales    forcats      e1071  rmarkdown      caret 
    ##       TRUE       TRUE       TRUE       TRUE       TRUE

``` r
dir.home <- getwd ()

source( "98_parameters.R")

#### functions ----
source( "99_functions.R")
```

``` r
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
```

``` r
#### eda ----

#### parameters ----
# source(file.path(dir.home, "98_parameters.R"))
dir.data <- file.path(dir.home, "airbnb-recruiting-new-user-bookings")
dir.input <- file.path(dir.home, "input")

#### Markdown captions
library(captioner)
table_captions <- captioner::captioner(prefix = "Tab.")
figure_captions <- captioner::captioner(prefix = "Fig.")

t.ref <- function(label){
  stringr::str_extract(table_captions(label), "[^:]*")
}

f.ref <- function(label){
  stringr::str_extract(figure_captions(label), "[^:]*")
}
```

**FUNCTIONS**

``` r
#### functions ----
# source(file.path(dir.home, "99_functions.R"))
#### Change Date Format ####
convert_date_format <- function(x){
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
```

**ETL**

``` r
#### etl ---
# source(file.path(dir.home, "01_etl.R"))
fact.train <- fread(file.path(dir.data, "train_users_2.csv"))
fact.test <- fread(file.path(dir.data, "test_users.csv"))

# Data type
fact.train[, dataset_type := "TRAIN"]
fact.test[, ":=" (country_destination = NA, dataset_type = "TEST")]


fact.train$date_first_booking<-as.character(fact.train$date_first_booking)
fact.test$date_first_booking<-as.character(fact.test$date_first_booking)

# Combine Train and Test
fact.destinations <- rbind(fact.train, fact.test)

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
```

**JOIN DIM TABLES TO MAIN TABLE**

``` r
#### Joining to other csv's ####
dim.age_gender <- fread(file.path(dir.data, "age_gender_bkts.csv"))
dim.country <- fread(file.path(dir.data, "countries.csv"))

### 1.0 Join to age_gender_bkts to get population_in_thousands
dim.age_gender[, ":=" (gender2 = ifelse(gender == "male", "MALE", "FEMALE"))][, gender := gender2][, gender2 := NULL]

fact.destinations[, age_bucket_key := floor(age / 5) + 1][, age_bucket_key := ifelse(age_bucket_key >= 21, 21, age_bucket_key)]
age_bucket <- unique(dim.age_gender[, .(age_bucket)])
n_age_bucket <- nrow(age_bucket)
age_bucket <- age_bucket[, age_bucket_key := n_age_bucket - 1:n_age_bucket + 1]
fact.destinations <- 
  merge(
    fact.destinations,
    age_bucket,
    by = "age_bucket_key",
    all.x = TRUE
  )[, age_bucket_key := NULL]

fact.destinations <-
  merge(
    fact.destinations,
    dim.age_gender[, year := NULL],
    by = c("age_bucket", "country_destination", "gender"),
    all.x = TRUE
  )

### 2.0 Join with countries.csv
fact.destinations <-
  merge(
    fact.destinations,
    dim.country,
    by = "country_destination",
    all.x = TRUE
  )
```

**REMOVE NDF**

``` r
# Remove NDF users
fact.destinations <- fact.destinations[country_destination != ""]
fact.destinations <- fact.destinations[country_destination != "NDF"]
```

# Data Visualisation

This section will explore visualisation of various variables in the
dataset. For many of these visualisations, we will look particuarly
closely at the relationship between our response variable, the country
destination, and the various predictors.

## Response Variable: First Destination Country

First, we explore the response variable; the first destination country.
Our classification problem aims to predict the first country that users
will book after signing up to the Airbnb site. After removing the NDF
category, the response variable consists of 11 categories; 10 countries
and the category `Other`.

``` r
### The Distribution of the Response Variable - Country Destinations
country_destination_dt <- fact.destinations[!(country_destination %in% c("", "NDF") ), .N, by = country_destination][order(-N)]
p <- plot_ly(
  x = country_destination_dt[, country_destination],
  y = country_destination_dt[, N],
  type = "bar") %>% 
  layout(
    title = "Numbers of Booking by Country Destination",
    xaxis = list(
      title = "Country Destinations",
      categoryorder = "array",
      categoryarray = country_destination_dt[, country_destination]
    ),
    yaxis = list(
      title = "Numbers of Booking"
    )
  )
p
```

![Fig. 1: Number of user bookings per country
destination](Airbnb-New-User-Bookings_files/figure-gfm/fig1-1.png)

As discussed earlier, the largest class of first destination is `US`. In
fact, after removing NDF observations, the US comprises approximately
70.2% of the remaining observations. As observed in Fig. 1, this class
dominates all other classes significantly. Since all users in the
dataset originate from the United States, this is a reflection of the
fact that the majority of Airbnb travel is for domestic travel - hardly
a surprising result. Of the remaining 29.8%, the largest category is
`other`, which represents all destinations not individually listed.
Finally, the remaining categories include Australia, Canada, and various
Western European countries (including France, Italy, Spain, Great
Britain, The Netherlands and Portugal).

# Missing Data Issues

We now explore several variables with notable missing data issues. In
particular, we discuss the variable `gender`.

## Gender

One important consideration for later data cleaning is the breakdown of
the `Gender` variable. Fig. 2 below shows that 32.6% of the observations
report a gender ???unknown???. Importantly, this is different to ???OTHER???,
which we might suppose belongs to a small proportion of users (&lt;0.2%)
who do not identify with either gender. In the case of ???unknown???, it
seems reasonable that while a small proportion might also belong to the
???OTHER??? category, the majority will be users who have chosen not to
record a gender upon signup.

In the data cleaning stage, this may cause issues since this we cannot
remove 33% of observations, nor would it be reasonable to consider
???Unknown??? to be a category of its own. We therefore consider imputing
the missing data before further analysis.

``` r
### Gender
gender_summary <- fact.destinations[, .N, by = gender][, proportion := N/sum(N)]
p <- plot_ly(
  data = gender_summary,
  labels = ~gender, 
  values = ~proportion, 
  type = 'pie',
  textposition = 'inside',
  textinfo = 'label+percent',
  insidetextfont = list(color = '#FFFFFF'),
  marker = list(colors = c('rgb(128,133,133)', 'rgb(211,94,96)', 'rgb(114, 147, 203)', 'rgb(144,103,167)'), # unknown, female, male, other
                line = list(color = '#FFFFFF', width = 1)),
  showlegend = TRUE,
  hoverinfo = 'text',
  text = ~paste0("Count: ", N)
) %>%
  layout(
    title = "Proportion of Gender"
  )
p
```

![Fig. 2: Proportion of user
gender](Airbnb-New-User-Bookings_files/figure-gfm/fig4-1.png)

# Interesting Explanatory Variables

## Age:

We explore the variable age as a potentially important predictor of
destination. Fig. 3 shows the distribution of the age brackets from
which users originate. Although Airbnb provides methods of verification
online, new users are generally not required to submit proof of age. As
such, there are inevitably some age readings which we expect to be
false. In particular, we observe in the plot below that there are a
disproportionately large number of users (1330 in total) who report ages
of over 100, and 5 users who report ages of between 0 and 4 years. Since
Airbnb requires users to be at least 18 years old to create an account,
we can expect that although some may be in fact over 100 years of age,
many of these will be false inputs, or users who have registered
illegally. In further data cleaning, we propose to remove all
observations who report ages of &lt;18 and &gt;100.

Moreover, we can observe from Fig. 3 that the majority of users are
between the ages of 25-30, with the number of users monotonically
decreasing from `30-34` until `95-99`.

``` r
### Age Band
age_bucket_dt <- fact.destinations[!(is.na(age)), .N, by = .(age, age_bucket)
                                   ][order(age)
                                   ][, .(N = sum(N)), by = .(age_bucket)]

age_bucket_dt<- age_bucket_dt %>% mutate(id = seq(1, 20))

ggplot(
  data = age_bucket_dt, 
  aes(x = reorder(age_bucket, id), y = N)
) + 
geom_bar(stat="identity", fill = "plum") +
theme_bw() + 
theme(axis.text.x = element_text(angle = 90, hjust = 1)) + 
labs(x = "age group", title = "Age group distribution", y = "Number of bookings")
```

![Fig. 3: Number of user bookings by user age
group](Airbnb-New-User-Bookings_files/figure-gfm/fig2-1.png)

``` r
### Age Boxplot
fact.destinations %>%
  filter(age < 110) %>%
  ggplot(.) +
  geom_boxplot(mapping = aes(x = reorder(country_destination, age, FUN = mean), y = age), fill = "plum") +
  coord_flip()+
  labs(x = "country", title = "Age Distribution By Country")+
  theme_bw() + #lot ggplot2 version
  theme(plot.title = element_text(hjust = 0.5))
```

![Fig. 4: Distribution of user ages by
country](Airbnb-New-User-Bookings_files/figure-gfm/fig3-1.png)

``` r
median <- aggregate(x = fact.destinations$age, by = list(fact.destinations$country_destination), FUN = "median", na.rm = TRUE)
skewness <- aggregate(x = fact.destinations$age, by = list(fact.destinations$country_destination), FUN = "skewness", na.rm = TRUE)
df <- data.frame(Country = median[,1], Median = median[,2], Skewness = skewness[,2] )
df
```

    ##    Country Median Skewness
    ## 1       AU     35 20.09460
    ## 2       CA     34 13.09453
    ## 3       DE     34 10.77254
    ## 4       ES     32 13.46625
    ## 5       FR     34 13.66926
    ## 6       GB     35 12.99158
    ## 7       IT     34 12.21596
    ## 8       NL     33 10.70861
    ## 9    other     34 12.83276
    ## 10      PT     32 12.20826
    ## 11      US     33 13.41153

From the boxplot (Fig. 4) and data summary above, we observe that the
for all countries, the median of the users age at first booking occurs
between 32 and 35. The country with the youngest median age at first
booking is Spain (at 32 years), while Great Britain and Australia have
the highest median ages at 35. We also observe that all countries return
high skewness, indicating a longer upper tail. In particular, we note
that Australia has a very high skewness statistic of 20.09 suggesting
perhaps, that Australia is more popular amongst older travellers than
younger travellers. The positive skewness for all countries is likely
due to the asymmetry of user ages, since users are unable to make
bookings until they are at least 18 years old but may continue to do so
until death.

``` r
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
```

# Interesting Explanatory Variables Continued ???

## Date of Bookings

The dataset includes observations from 2009 up to 2015. Fig. 5 shows an
overall positive trend in the number of data counts over time. The
number of user signups, starts low in 2009 (just one year after Airbnb
was founded), and increases dramatically throughout the years. There is
however, a significant drop in the number of observations after June
2014. This can largely be explained by the fact that the test set
requires prediction of data from July 2014. Furthermore, the Kaggle
competition initially commenced around July 2014. Later, the competition
was re-started in December 2015, and all datasets updated, explaining
the presence of a small number of observations in early 2015.

Strong seasonality effects are also evident, showing peaks around each
summer period (mid-year), as well as a significant drop around late
December/early January, which is consistent with users either avoiding
travel to spend the festive season with family, or staying with family
and therefore making fewer bookings through Airbnb.

``` r
### First Active / Account Created / First Booking Counts by Year Month
year_month_all <- data.table(
  year_month = sort(unique(c(
    fact.destinations[, first_active_year_month],
    fact.destinations[, first_account_year_month],
    fact.destinations[, first_booking_year_month]
  )))
)[year_month != ""]
 
year_month_full <-
  merge(
    merge(
      merge(
        year_month_all,
        fact.destinations[, .(active.N = .N), by = .(first_active_year_month)],
        by.x = "year_month",
        by.y = "first_active_year_month",
        all.x = TRUE
      ),
      fact.destinations[, .(account.N = .N), by = .(first_account_year_month)],
      by.x = "year_month",
      by.y = "first_account_year_month",
      all.x = TRUE
    ),
    fact.destinations[, .(booking.N = .N), by = .(first_booking_year_month)],
    by.x = "year_month",
    by.y = "first_booking_year_month",
    all.x = TRUE
  )

p <- plot_ly(x = year_month_full[, year_month], 
              y = year_month_full[, active.N], 
              name = 'Active',
              type = 'scatter', 
              mode = 'lines') %>%
  add_trace(y = year_month_full[, account.N], name = 'Account', mode = 'lines') %>%
  add_trace(y = year_month_full[, booking.N], name = 'Booking', mode = 'lines') %>%
  layout(
    title = "Number of bookings by month",
    xaxis = list(title = "Month"),
    yaxis = list(title = 'Booking Counts'), 
    barmode = 'stack'
  )

p
```

![Fig. 5: Number of user bookings per
month](Airbnb-New-User-Bookings_files/figure-gfm/fig5-1.png)

Fig. 6below presents a breakdown of the aggregated monthly bookings per
destination. This plot shows a the seasonality pattern in greater
detail; we are able to observe that while almost all countries display a
peak around the 5th-7th month of the year, Australia (`AU`) is the only
destination which does not follow this pattern. The bookings for
Australia are instead higher in December and January (during the
Australian summer), with a dip in the middle of the year and thus
follows a pattern of peak/off-season according to the weather seasons.

**Note:** due to the size of the class `US`, the inclusion of `US` in
Fig. 6 somewhat obscures the seasonality patterns for the remaining
countries. Using the interactive features of `plotly`, we recommend
hiding the `US` line in order to better observe the patterns in other
countries, such as Australia.

``` r
### Country Destinations by First Booking Month
destination_by_month <- fact.destinations[, .N, by = .(first_booking_month, country_destination)]
destination_by_month_wide <- dcast(
  destination_by_month,
  first_booking_month ~ country_destination,
  value.var = "N"
)
p <- plot_ly(x = destination_by_month_wide$first_booking_month,
               y = destination_by_month_wide$US,
              type = 'scatter',
              mode = 'lines',
               name = 'US') %>%
  add_trace(y = destination_by_month_wide$other, name = 'OTHER') %>%
  add_trace(y = destination_by_month_wide$FR, name = 'FR') %>%
  add_trace(y = destination_by_month_wide$IT, name = 'IT') %>%
  add_trace(y = destination_by_month_wide$GB, name = 'GB') %>%
  add_trace(y = destination_by_month_wide$ES, name = 'ES') %>%
  add_trace(y = destination_by_month_wide$CA, name = 'CA') %>%
  add_trace(y = destination_by_month_wide$DE, name = 'DE') %>%
  add_trace(y = destination_by_month_wide$NL, name = 'NL') %>%
  add_trace(y = destination_by_month_wide$AU, name = 'AU') %>%
  add_trace(y = destination_by_month_wide$PT, name = 'PT') %>%
  layout(
    title = "Number of bookings each month by country destination",
    xaxis = list(title = "Month"),
    yaxis = list(title = 'Booking Counts')#,
    # barmode = 'stack'
  )
p
```

![Fig. 6: Number of user bookings per month by country
destination](Airbnb-New-User-Bookings_files/figure-gfm/fig6-1.png)

## User Language Preferences

``` r
### Language Preferences by Each Country Destination
fact.destinations %>% 
  filter(language!= "en") %>% 
  group_by(country_destination, language) %>% 
  summarise(n = n()) %>% 
  group_by(country_destination) %>% 
  mutate(nn = n/sum(n)) %>% 
  ggplot(., aes(x = country_destination, y = n)) +
  geom_col(aes(fill=language), width = 0.5, position = "fill") + 
  theme(axis.text.x = element_text(angle=65, vjust=0.6)) + 
  labs(title="Proportion of non-English language preference") +
  theme_classic()
```

    ## `summarise()` has grouped output by 'country_destination'. You can override using the `.groups` argument.

![Fig. 7: Proportion of non-English language preference in each country
destination](Airbnb-New-User-Bookings_files/figure-gfm/fig7-1.png)

``` r
### Language Preferences by Each Country Destination
english_summary <- fact.destinations[, .(language_eng = ifelse(language == "en", "English", "Non-English"))
                                     ][, .N, by = language_eng
                                     ][, proportion := N/sum(N)]

p <- plot_ly(
  data = english_summary,
  labels = ~language_eng,
  values = ~proportion,
  type = 'pie',
  textinfo = 'label+percent',
  insidetextfont = list(color = '#FFFFFF'),
  marker = list(colors = c('rgb(114, 147, 203)', 'rgb(211,94,96)'),
                line = list(color = '#FFFFFF', width = 1)),
  showlegend = TRUE,
  hoverinfo = 'text',
  text = ~paste0("Count: ", N)
) %>%
  layout(
    title = "Proportion of English Speaking v.s. Non-English Speaking"
  )
p
```

![Fig. 8: Proportion of English Speaking Users v.s. Non-English Speaking
users](Airbnb-New-User-Bookings_files/figure-gfm/fig18-1.png)

Fig. 7 shows the international language preference (user setting) for
non-English accounts against the first booking destination. The pie
chart Fig. 8 shows the proportion of languages for users overall. We can
observe that 97.5% of all users from the dataset have English set as
their profile language preference; hardly a surprising result since all
users originate from the US. However, it is interesting to note that the
non-English proportion for each country differs significantly.
Unsurprisingly, country destinations tend to have a larger percentage of
travellers with their language preference set to be a native language
spoken in that country. For example, Germany
(`country_destination = DE`) has the highest proportion of users with a
language setting of Deutsche (`language code = DE`). Similar patterns
hold for Spain (`country_destination = ES`) and Espanol
(`language = ES`).

Moreover, some countries have large variations of language for users
(for example `Other`, since it encapsulates all other countries, has the
widest variation of language, as does `France` and `US`), while
countries like Australia (`country_destination = AU`) and Portugal
(`country_destination = PT`) tend to consist of users from only a few
language preferences.

``` r
### First Browser Word Cloud
cloud <-fact.destinations %>% 
  group_by(first_browser) %>% 
  summarize(freq = n())

set.seed(100)
wordcloud(words = cloud$first_browser, freq = cloud$freq, min.freq = 1,scale = c(4,0.5),
          max.words=100, random.order=FALSE, rot.per=0.25, 
          colors=brewer.pal(8, "Dark2"))
```

![Fig. 9: Word cloud of first browser
type](Airbnb-New-User-Bookings_files/figure-gfm/fig8-1.png) The most
popular browser for user bookings was Google Chrome (33.6%), as
evidenced by the word cloud (Fig. 9). Chrome is followed in popularity
by Safari (22.2%) and Firefox (17.7%). Almost all users sign up using
one of the 5 most common browsers or report `unknown` browser type. The
remaining 34 browsers make up less than 2% of all observations. We note
that observations which are unknown may require some imputation, or we
can simply remove these observations for further analysis.

## Days from First Active to First Booking

``` r
### Distributions: days groups from active to first booking
days_from_active_to_booking_dist2 <- 
  fact.destinations[, .N, by = .(days_from_active_to_booking)
                    ][order(days_from_active_to_booking)
                      ][, ":=" (
                        days_group = ifelse(
                          days_from_active_to_booking == 0,
                          "< 1 day",
                          ifelse(
                            days_from_active_to_booking <= 2,
                            "1 ~ 2 days",
                            ifelse(
                              days_from_active_to_booking <= 7,
                              "3 ~ 7 days",
                              ifelse(
                                days_from_active_to_booking <= 30,
                                "8 ~ 30 days",
                                ifelse(
                                  days_from_active_to_booking <= 90,
                                  "31 ~ 90 days",
                                  ifelse(
                                    days_from_active_to_booking <= 180,
                                    "91 ~ 180 days",
                                    ifelse(
                                      days_from_active_to_booking <= 240,
                                      "181 ~ 240 days",
                                      ifelse(
                                        days_from_active_to_booking <= 300,
                                        "241 ~ 300 days",
                                        "> 300 days"
                                      )
                                    )
                                  )
                                )
                              )
                            )
                          )
                        )
                      )]
days_from_active_to_booking_dist2 <- 
  days_from_active_to_booking_dist2[, .(N = sum(N)), by = .(days_group)
                                    ][, proportion := N / sum(N)
                                    ][, cum_proportion := cumsum(proportion)]
p <- plot_ly() %>% 
  add_trace(
    x = days_from_active_to_booking_dist2$days_group,
    y = days_from_active_to_booking_dist2$proportion,
    type = "bar",
    name = "User %"
  ) %>% 
  add_trace(
    x = days_from_active_to_booking_dist2$days_group,
    y = days_from_active_to_booking_dist2$cum_proportion,
    type = 'scatter',
    mode = 'lines+markers',
    name = "User Cum%"
  ) %>% 
  layout(
    title = "User Proportion in Days from First Active to First Booking",
    xaxis = list(
      title = "Number of Days from First Active to First Booking",
      categoryorder = "array",
      categoryarray = days_from_active_to_booking_dist2$days_group
    ),
    yaxis = list(
      title = "Proportion"
    ),
    legend = list(orientation = 'r')
  )
p
```

![Fig. 10: Number of days between first activity and first booking by
proportion](Airbnb-New-User-Bookings_files/figure-gfm/fig9-1.png)

The majority of users make their first booking within a week of being
first active as evidenced by Fig. 10, suggesting that many users in this
dataset first sign up to Airbnb with the intention of making a booking.
Moreover, this suggests that for the majority of users who make a first
booking, they often sign up to Airbnb once they have decided to travel.

There are however, users for which there is an extremely long period
between first activation to first booking. Due to the time frame of the
data, it is reasonable to assume that there are many users currently
with the first destination as `NDF` who have made a booking since the
end-date of the dataset provided here, and who would therefore also find
themselves in the categories with a longer time frame between activation
and booking. For these users who record a longer time between activation
and booking, it would be reasonable to assume that some initially sign
up without intention of making a booking, while others may have intended
on booking upon sign up but later chose to book elsewhere.

# Correlation Analysis

``` r
### Heat Map for All Continuous Variables
dt <- dcast(fact.destinations[, .(id, country_destination)][, key := 1], id ~ country_destination, value.var = "key")
dt[is.na(dt)] <- 0
dt <- merge(
  fact.destinations,
  dt,
  by = "id",
  all.x = TRUE
)

ggcorr(dt,
       nbreaks = 6,
       label = TRUE,
       label_size = 3,
       color = "black",
       hjust = 0.9, 
       size = 3,
       layout.exp = 6)
```

    ## Warning in ggcorr(dt, nbreaks = 6, label = TRUE, label_size = 3,
    ## color = "black", : data in column(s) 'id', 'country_destination',
    ## 'age_bucket', 'gender', 'date_account_created', 'date_first_booking',
    ## 'signup_method', 'language', 'affiliate_channel', 'affiliate_provider',
    ## 'first_affiliate_tracked', 'signup_app', 'first_device_type', 'first_browser',
    ## 'dataset_type', 'date_first_active', 'days_from_active_to_account',
    ## 'days_from_account_to_booking', 'days_from_active_to_booking',
    ## 'date_first_booking_end_week', 'first_active_year_month',
    ## 'first_account_year_month', 'first_booking_year_month', 'destination_language'
    ## are not numeric and were ignored

    ## Warning in cor(data, use = method[1], method = method[2]): the standard
    ## deviation is zero

![Fig. 11: Correlation matrix for all continuous
variables](Airbnb-New-User-Bookings_files/figure-gfm/fig10-1.png)

First, we note that the interpretation of these correlations must be
done with care, since correlations between some of these variables do
not necessarily make sense (for example, the latitude and longitude of
destinations, though only weakly correlated here, does not make sense).

Strong correlations exist between several of the variables. In
particular, we note 3 instances where variables are perfectly (or near
perfectly) correlated; namely, the longitude of the destination and the
distance (in km) to the destination, the `timestamp_first_active` and
`first_booking_year`, and finally, `days_from_account_to_booking` and
`days_from_active_to_booking`.

Unfortunately, the majority of strong correlations exist between
variables in the countries dataset (ie. the first six variables, from
top to bottom) . Since these variables are descriptors of the response
variable in question, it is not surprising that there are many high
correlations, since the observations from these variables all relate to
the same country. This however may present difficulties when training
classification models since these variables cannot be used to predict
the country destination.

# Appendix

We include here several plots of variables whose interpretations may be
of interest. A common interpretation across all charts is that when
plotted against country, the proportion of each variable category does
not appear to be significantly different. As such, we include and
discuss these plots here, noting however that the lack of variation in
these variables across country may indicate difficulty in using these
variables in building our classification model.

## Signup Method

``` r
### 5.4
fact.destinations %>% 
  ggplot(. ,aes(
    reorder(
      country_destination,
      signup_method,
      function(x) - length(x)
    ), 
    fill = signup_method)
  ) +
  geom_bar(position = "fill") + 
  theme_bw() + 
  labs(title = "Signup Method Proportion Across Country Destinations", x = "Country", y = "Proportion") +
  theme(plot.title = element_text(hjust = 0.5))
```

![Fig. 12: Signup Method Across Country
Destinations](Airbnb-New-User-Bookings_files/figure-gfm/fig11-1.png) The
plot above (Fig. 12) shows a breakdown of the number of the number of
users who sign up using ???basic??? methods, facebook and google. Clearly
most people sign up using the basic method (approximately 73.1%), with
only 26.7% of users signing up using facebook, and 0.1% using google to
sign up.

## Affiliate Channel

``` r
### 8.2
fact.destinations %>% 
  ggplot(., aes(
    reorder(
      country_destination, 
      affiliate_channel, 
      function(x) -length(x)
    ), 
    fill = affiliate_channel)
  ) +
  geom_bar(position = "fill") + 
  theme_bw() + 
  labs(title = "Affiliate Channel Proportion Across Country Destinations", x = "Country", y = "Proportion")+
  theme(plot.title = element_text(hjust = 0.5))
```

![Fig. 13: Affiliate Channel Proportion Across Country
Destinations](Airbnb-New-User-Bookings_files/figure-gfm/fig12-1.png)
Fig. 13 shows the breakdown of affiliate channel proportion across
country destination. Similarly to other plots in this appendix, the
proportion across country does not appear to change significantly. The
majority of users apply directly through Airbnb.

## Affiliate Provider

``` r
### 9
fact.destinations %>% 
  ggplot(., aes(
    reorder(
      country_destination, 
      affiliate_provider, 
      function(x) -length(x)
    ), 
    fill = affiliate_provider)
  ) +
  geom_bar(position = "fill") + 
  theme_bw() + 
  labs(title = "Affiliate Provider Proportion Across Country Destinations", x = "Country", y = "Proportion") + 
  theme(plot.title = element_text(hjust = 0.5))
```

![Fig. 14: Affiliate Provider Across
Country](Airbnb-New-User-Bookings_files/figure-gfm/fig13-1.png) Fig. 14
shows the breakdown of affiliate provider proportion across country
destination. Similarly to other plots in this appendix, the proportion
across country does not appear to change significantly. The majority of
users apply directly through Airbnb.

## First Affiliate Tracked

``` r
### 10.2
fact.destinations %>% 
  ggplot(., aes(
    reorder(
      country_destination,
      first_affiliate_tracked,
      function(x) -length(x)
    ), 
    fill = first_affiliate_tracked)
  ) +
  geom_bar(position = "fill") + 
  theme_bw() + 
  labs(title = "First Affiliate Tracked Across Country Destinations", x = "Country", y = "Proportion") +
  theme(plot.title = element_text(hjust = 0.5))
```

![Fig. 15: First Affiliate Tracked Across Country
Destinations](Airbnb-New-User-Bookings_files/figure-gfm/fig14-1.png)

Approximately 90% of the users who made a booking used the website. This
is considerably larger than the next largest category, iOS. Due to
limited documentation of this variable, we might guess that this refers
to the iOS app. Similarly, we can guess that Android refers to users who
use the Android app to sign up (approximately 1.4%) and finally, Moweb
might refer to users who use a mobile browser to sign up.

## Signup App

``` r
### 11.3
fact.destinations %>% 
  ggplot(., aes(
    country_destination, 
    fill = signup_app)
  ) +
  geom_bar(position = "fill") + 
  theme_bw() + 
  labs(title = "Signup App Proportion Across Country Destinations", x = "Country", y = "Proportion") +
  theme(plot.title = element_text(hjust = 0.5))
```

![Fig. 16: Signup App Proportion Across Country
Destination](Airbnb-New-User-Bookings_files/figure-gfm/fig15-1.png) The
distribution of signup apps across countries does not appear to differ
significantly. The majority of users sign up via the method `Web`.

## Signup Flow

``` r
### 11.5
fact.destinations %>% 
  ggplot(., aes(
    country_destination, 
    fill = as.factor(signup_flow)
    )
  ) +
  geom_bar(position = "fill") + 
  theme_bw() + 
  labs(title = "Signup Flow Proportion Across Country Destinations", x = "Country", y = "Proportion") +
  theme(plot.title = element_text(hjust = 0.5))
```

![Fig. 17: First Affiliate Tracked Across Country
Destinations](Airbnb-New-User-Bookings_files/figure-gfm/fig17-1.png) The
majority of users sign up using the signup flow `0`.

## First Device Type

``` r
### 12.2
fact.destinations %>% 
  mutate(
    first_device_type_1 = recode(
      first_device_type, 
      "Android Phone" = "Phone", 
      "iPhone" = "Phone",
      "Android Tablet" = "Tablet",
      "iPad" = "Tablet",
      "Windows Desktop" = "Desktop", 
      "Mac Desktop" = "Desktop")
    ) %>% 
  filter(first_device_type_1 == "Phone" | first_device_type_1 == "Tablet"| first_device_type_1 == "Desktop" ) %>% 
  ggplot(., aes(
    reorder(
      country_destination,
      first_device_type_1, 
      function(x) -length(x)
    ), 
    fill = first_device_type_1)
  )+
  geom_bar(position = "fill") + 
  theme_bw() +
  labs(title = "First Device Type: Phone or tablet or desktop") +
  theme(plot.title = element_text(hjust = 0.5))
```

![Fig. 18: Proportion of first device type by
country](Airbnb-New-User-Bookings_files/figure-gfm/fig16-1.png)

The largest group here was users who use Mac Desktops to sign up. This
is followed by Windows Desktop and then iPhone. It appears that the
majority of users have initially signed up on an Apple device.

``` r
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
```

    ## [1] 20376

``` r
# Remove NAs
model_file <- model_file[complete.cases(model_file),]
which(is.na(model_file))
```

    ## integer(0)

``` r
library(dplyr)
library(gbm) # boosting
```

    ## Loaded gbm 2.1.8

``` r
library(UBL) # up and down sampling
```

    ## Loading required package: MBA

    ## Loading required package: gstat

    ## Loading required package: automap

    ## Loading required package: sp

    ## Loading required package: randomForest

    ## randomForest 4.6-14

    ## Type rfNews() to see new features/changes/bug fixes.

    ## 
    ## Attaching package: 'randomForest'

    ## The following object is masked from 'package:dplyr':
    ## 
    ##     combine

    ## The following object is masked from 'package:ggplot2':
    ## 
    ##     margin

``` r
library(knitr) # to run the kable
```

    ## Warning: package 'knitr' was built under R version 3.6.3

``` r
library(xgboost)
```

    ## Warning: package 'xgboost' was built under R version 3.6.3

    ## 
    ## Attaching package: 'xgboost'

    ## The following object is masked from 'package:dplyr':
    ## 
    ##     slice

    ## The following object is masked from 'package:plotly':
    ## 
    ##     slice

``` r
library(caret)
```

``` r
data<- subset(model_file, select = -dataset_type)

set.seed(123)
inTrain <- createDataPartition(data$country_destination, p = .7)[[1]]
train <- data[ inTrain,]
test  <- data[-inTrain,]


# boosting model

## preliminary training

gbm.model <- gbm(country_destination~., data=train, n.trees=500,
                 shrinkage = 0.02,interaction.depth = 3,cv.folds=5,keep.data = FALSE,
                 n.minobsinnode = 40)
```

    ## Distribution not specified, assuming multinomial ...

    ## Warning: Setting `distribution = "multinomial"` is ill-advised as it is currently
    ## broken. It exists only for backwards compatibility. Use at your own risk.

``` r
# Summary of the model results, with the importance plot of predictors.
summary(gbm.model, las = 2)
```

![](Airbnb-New-User-Bookings_files/figure-gfm/gmb-1.png)<!-- -->

    ##                                                       var    rel.inf
    ## hour_first_active                       hour_first_active 19.9587314
    ## age                                                   age 16.2244012
    ## days_from_account_to_booking days_from_account_to_booking 12.4776644
    ## first_booking_month                   first_booking_month 10.2736996
    ## days_from_active_to_booking   days_from_active_to_booking  7.5430145
    ## affiliate_provider                     affiliate_provider  6.9012458
    ## affiliate_channel                       affiliate_channel  4.9916376
    ## language                                         language  4.1395569
    ## first_device_type                       first_device_type  3.7478179
    ## gender                                             gender  3.0870502
    ## signup_app                                     signup_app  2.9514473
    ## signup_flow                                   signup_flow  2.8274675
    ## first_affiliate_tracked           first_affiliate_tracked  2.0767147
    ## first_browser                               first_browser  2.0611549
    ## signup_method                               signup_method  0.6382269
    ## days_from_active_to_account   days_from_active_to_account  0.1001691

``` r
# Check the best iteration number.
best.iter <- gbm.perf(gbm.model, method = "cv")
```

![](Airbnb-New-User-Bookings_files/figure-gfm/gmb-2.png)<!-- -->

``` r
# the optimal ntrees is 405.



# confusion matrix
preds <- predict(gbm.model, newdata = test , n.trees=best.iter, type="response")
preds.max<- colnames(preds)[apply(preds,1,which.max)]

print(mean(preds.max == test$country_destination))
```

    ## [1] 0.7093855

``` r
# output


kable(table(test$country_destination,preds.max),format = "markdown")
```

|       |    US |
|:------|------:|
| AU    |   130 |
| CA    |   323 |
| DE    |   255 |
| ES    |   511 |
| FR    |  1113 |
| GB    |   532 |
| IT    |   610 |
| NL    |   180 |
| other |  2272 |
| PT    |    47 |
| US    | 14580 |

``` r
model_file <- read.csv("input\\imputed_model_file_Testing.csv", header = T, sep = ",")

row.has.na <- apply(model_file, 1, function(x){any(is.na(x))})

sum(row.has.na)
```

    ## [1] 0

``` r
head(model_file)
```

    ##      gender age signup_method signup_flow language affiliate_channel
    ## 1    FEMALE  56         basic           3       en            direct
    ## 2    FEMALE  42      facebook           0       en            direct
    ## 3 -unknown-  41         basic           0       en            direct
    ## 4 -unknown-  37         basic           0       en             other
    ## 5    FEMALE  46         basic           0       en             other
    ## 6    FEMALE  47         basic           0       en            direct
    ##   affiliate_provider first_affiliate_tracked signup_app first_device_type
    ## 1             direct               untracked        Web   Windows Desktop
    ## 2             direct               untracked        Web       Mac Desktop
    ## 3             direct               untracked        Web       Mac Desktop
    ## 4              other                     omg        Web       Mac Desktop
    ## 5         craigslist               untracked        Web       Mac Desktop
    ## 6             direct                     omg        Web       Mac Desktop
    ##   first_browser country_destination hour_first_active
    ## 1            IE                  US                23
    ## 2       Firefox               other                 6
    ## 3        Chrome                  US                 6
    ## 4        Chrome                  US                21
    ## 5        Safari                  US                 1
    ## 6        Safari                  US                19
    ##   days_from_active_to_account days_from_account_to_booking
    ## 1                         476                          -57
    ## 2                         765                          278
    ## 3                         280                         -208
    ## 4                           0                            1
    ## 5                           0                            3
    ## 6                           0                           10
    ##   days_from_active_to_booking first_booking_month
    ## 1                         419                   8
    ## 2                        1043                   9
    ## 3                          72                   2
    ## 4                           1                   1
    ## 5                           3                   1
    ## 6                          10                   1

``` r
dim(model_file)
```

    ## [1] 5009   17

``` r
set.seed(123)
inTrain <- createDataPartition(model_file$country_destination, p = 0.75)[[1]]

fact.destinationsTrain <- model_file[ inTrain, ]
fact.destinationsTest  <- model_file[-inTrain, ]

knn.model <- train(country_destination ~ . ,
                   data = fact.destinationsTrain,
                   method = "knn",  
                   trControl = trainControl(method = "repeatedcv", 
                                            repeats = 5))

knn.train.pred <- predict(knn.model, newdata = fact.destinationsTrain)
knn.train.CM <- confusionMatrix(knn.train.pred, fact.destinationsTrain$country_destination)
knn.train.overall.accuracy <- knn.train.CM$overall['Accuracy']
print(paste0("Training Accuracy: ",knn.train.overall.accuracy))
```

    ## [1] "Training Accuracy: 0.708776595744681"

``` r
knn.test.pred <- predict(knn.model, newdata = fact.destinationsTest)
knn.test.CM <- confusionMatrix(knn.test.pred, fact.destinationsTest$country_destination)
knn.test.overall.accuracy <- knn.test.CM$overall['Accuracy']
print(paste0("Test Accuracy: ",knn.test.overall.accuracy))
```

    ## [1] "Test Accuracy: 0.704563650920737"

``` r
dim(fact.destinationsTrain)
```

    ## [1] 3760   17
