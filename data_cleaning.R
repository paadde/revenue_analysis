#Installation of necessary packages to setup the environment
install.packages("tidyverse")
library(tidyverse)
library(janitor)

#Import datasets for data cleaning
customer_revenue <- read.csv("Data_Set_1.csv")
customer_subscriber <- read.csv("Data_Set_2.csv")

str(customer_revenue)
str(customer_subscriber)
summary(customer_revenue)
summary(customer_subscriber)
head(customer_revenue)

#Dataset 1 Cleaning
#Revise brand_ID to a number
customer_revenue$brand_id <- gsub("National Foundation for Gun Rights - 28671 - www.gunrightsfoundation.org", "28671", customer_revenue$brand_id)

#Revise the brand_size of brand_id 28671 to Medium
customer_revenue$brand_size[customer_revenue$brand_id == "28671"] <- "Medium"

#correct mispellings in the brand_size column
customer_revenue$brand_size <- gsub("Smal", "Small", customer_revenue$brand_size)
customer_revenue$brand_size <- gsub("Mediumm", "Medium", customer_revenue$brand_size)
customer_revenue$brand_size <- gsub("Smalll", "Small", customer_revenue$brand_size)
customer_revenue$brand_size <- gsub("Extra Smalll", "Extra Small", customer_revenue$brand_size)

#Dataset 2 Cleaning
#Convert customer_subscriber$brand_id to chr
customer_subscriber[, 1] <- as.character(customer_subscriber[, 1])

#Aligning variable names for uniformity to enhance readability and facilitate easier coding.
customer_subscriber <- janitor::clean_names(customer_subscriber)

#correct improper date in the snapshop_date column
customer_subscriber$snapshot_date <- gsub("2/29/2023", "2/28/2023", customer_subscriber$snapshot_date)

#create csv file of cleaned datasets for further analysis
write.csv(customer_revenue, "customer_revenue.csv", row.names = FALSE)
write.csv(customer_subscriber, "customer_subscriber.csv", row.names = FALSE)

unique <- unique(customer_revenue$brand_size)
str(unique)
