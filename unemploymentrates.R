setwd("~/R/Unemployment Rates")
library(jsonlite)

census_api_key <- "YOUR API KEY HERE"


#get acs 2016 data for travel time to work and population for all urban areas
vars <- c("B01003_001E", "B23025_002E", "B23025_005E", "B23025_007E", "B23025_001E")
variable_list <- variable_list <- paste0(vars, collapse =",")

url <- paste0("https://api.census.gov/data/2016/acs/acs1?get=NAME,", variable_list, "&for=urban+area:*&key=", census_api_key)
employment_data <- fromJSON(url)
employment_data_frame <- as.data.frame(employment_data , stringsAsFactors = F)

names(employment_data_frame) <- c("urban_area", "total_population", "labor_force",
                                "unemployed_Workers", "not_in_labor_force", "total_population_over_16",
                                "urban_area")
employment_data_frame <- employment_data_frame[2:nrow(employment_data_frame), ]

for(i in 2:6) {
  employment_data_frame[,i] <- as.integer(employment_data_frame[,i])
}

#remove urban areas with a population less than 65,000. Only gets rid of 6 rows
employment_data_frame <- subset(employment_data_frame, employment_data_frame$total_population>64999)

employment_data_frame$employment_rate <- round(1- employment_data_frame$unemployed_Workers/employment_data_frame$labor_force, digits=2)

employment_data_frame$labor_force_participation_rate <- employment_data_frame$labor_force/employment_data_frame$total_population_over_16

#Round employment rate to 

highest_employment_rates <- employment_data_frame[order(-employment_data_frame$employment_rate,-employment_data_frame$labor_force_participation_rate),]
worst_employment_rates <- employment_data_frame[order(employment_data_frame$employment_rate, employment_data_frame$labor_force_participation_rate),]

write.csv(highest_employment_rates, "highest_employment_rates.csv")
write.csv(worst_employment_rates, "worst_employment_rates.csv")