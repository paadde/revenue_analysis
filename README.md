# Revenue Analysis

# Data Cleaning Documentation
## Initial Cleaning using R Scripts
```
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
```

## Follow-up data cleaning in SQL
```
--check the conversion of date type for snapshot_date
SELECT TO_DATE(snapshot_date, 'MM/DD/YYYY') AS converted_snapshot_date
FROM customer_subscriber

--check the conversion of date type for period_end_date
SELECT TO_DATE(period_end_date, 'MM/DD/YYYY') AS converted_snapshot_date
FROM customer_revenue

--updated the data type of snapshot_date
ALTER TABLE customer_subscriber
ALTER COLUMN snapshot_date TYPE DATE USING TO_DATE(snapshot_date, 'MM/DD/YYYY')

--updated the data type of period_end_date
ALTER TABLE customer_revenue
ALTER COLUMN period_end_date TYPE DATE USING TO_DATE(period_end_date, 'MM/DD/YYYY')

--correct missing values in opted-in column
UPDATE customer_subscriber 
SET opted_in_count = total_brand_subscribers - opted_out_count
WHERE snapshot_date = TO_DATE('1/31/2024', 'MM/DD/YYYY') AND opted_in_count = 0
```

## Data Analysis for Net Revenue per Opted In Count
```
WITH monthly_totals AS (
    SELECT 
        EXTRACT(MONTH FROM period_end_date) AS month_number,
        EXTRACT(YEAR FROM period_end_date) AS year,
        brand_size,
        SUM(net_revenue) AS total_net_revenue,
        SUM(opted_in_count) AS total_opted_in_count
    FROM
        customer_revenue AS revenue
    JOIN
        customer_subscriber AS subscriber ON revenue.brand_id::text = subscriber.brand_id::text AND revenue.period_end_date = subscriber.snapshot_date
    WHERE
        brand_size IS NOT NULL
    GROUP BY
        month_number,
        year,
        brand_size
)
SELECT 
    brand_size,
    SUM(CASE WHEN month_number = 1 AND year = 2023 THEN total_net_revenue END) / SUM(CASE WHEN month_number = 1 AND year = 2023 THEN total_opted_in_count END) AS "1/31/2023",
    SUM(CASE WHEN month_number = 2 THEN total_net_revenue END) / SUM(CASE WHEN month_number = 2 THEN total_opted_in_count END) AS "2/28/2023",
    SUM(CASE WHEN month_number = 3 THEN total_net_revenue END) / SUM(CASE WHEN month_number = 3 THEN total_opted_in_count END) AS "3/31/2023",
    SUM(CASE WHEN month_number = 4 THEN total_net_revenue END) / SUM(CASE WHEN month_number = 4 THEN total_opted_in_count END) AS "4/30/2023",
    SUM(CASE WHEN month_number = 5 THEN total_net_revenue END) / SUM(CASE WHEN month_number = 5 THEN total_opted_in_count END) AS "5/31/2023",
    SUM(CASE WHEN month_number = 6 THEN total_net_revenue END) / SUM(CASE WHEN month_number = 6 THEN total_opted_in_count END) AS "6/30/2023",
    SUM(CASE WHEN month_number = 7 THEN total_net_revenue END) / SUM(CASE WHEN month_number = 7 THEN total_opted_in_count END) AS "7/31/2023",
    SUM(CASE WHEN month_number = 8 THEN total_net_revenue END) / SUM(CASE WHEN month_number = 8 THEN total_opted_in_count END) AS "8/31/2023",
    SUM(CASE WHEN month_number = 9 THEN total_net_revenue END) / SUM(CASE WHEN month_number = 9 THEN total_opted_in_count END) AS "9/30/2023",
    SUM(CASE WHEN month_number = 10 THEN total_net_revenue END) / SUM(CASE WHEN month_number = 10 THEN total_opted_in_count END) AS "10/31/2023",
    SUM(CASE WHEN month_number = 11 THEN total_net_revenue END) / SUM(CASE WHEN month_number = 11 THEN total_opted_in_count END) AS "11/30/2023",
    SUM(CASE WHEN month_number = 12 THEN total_net_revenue END) / SUM(CASE WHEN month_number = 12 THEN total_opted_in_count END) AS "12/31/2023",
    SUM(CASE WHEN month_number = 1 AND year = 2024 THEN total_net_revenue END) / SUM(CASE WHEN month_number = 1 AND year = 2024 THEN total_opted_in_count END) AS "1/31/2024"
FROM
    monthly_totals
GROUP BY
    brand_size
ORDER BY
    CASE
        WHEN brand_size = 'Extra Small' THEN 1
        WHEN brand_size = 'Small' THEN 2
        WHEN brand_size = 'Medium' THEN 3
        WHEN brand_size = 'Large' THEN 4
    END;
```

## Findings

```
 brand_size  |      1/31/2023      |      2/28/2023      |      3/31/2023      |      4/30/2023      |      5/31/2023       |      6/30/2023      |      7/31/2023       |      8/31/2023      |      9/30/2023      |     10/31/2023      |     11/30/2023      |     12/31/2023      |       1/31/2024       
-------------+---------------------+---------------------+---------------------+---------------------+----------------------+---------------------+----------------------+---------------------+---------------------+---------------------+---------------------+---------------------+-----------------------
 Extra Small | 0.09810108866268298 | 0.09218626715274782 | 0.09381498383196327 | 0.09394224192019017 |  0.09143337958523783 | 0.08836679971063507 |  0.08514862299992967 | 0.07779860340173171 |  0.0854845256974691 | 0.09156891779655954 | 0.11998822628788677 | 0.09007325158946415 |  0.011866917098939824
 Small       | 0.15392316579977486 | 0.14475199308613226 | 0.13049948347451293 | 0.18621591946917687 |  0.13709028112552063 | 0.13520460273629897 |  0.12847116376005974 | 0.12362835555706929 | 0.05956494565592932 | 0.11604170637231427 | 0.17316482474565753 | 0.10460095185152483 |  0.017120014590538194
 Medium      | 0.10090115389097913 |   0.120618752091937 | 0.11588357321368616 | 0.12206917822119187 |  0.13557226852717982 |   75.03596819949097 |  0.11039604002145237 | 0.10544124155781402 | 0.09660092720773303 |   25.85813977931925 | 0.14133572015312834 | 0.08469864698911246 |  0.009438629511532928
 Large       | 0.05572227312938291 |  0.0596956564973147 | 0.05924026161237873 | 0.05394210226559883 | 0.055994084542447926 | 0.04526949058717732 | 0.045958091150212335 | 0.04418542348127055 | 0.03870983712604352 | 0.04213102603996722 | 0.06460630755568883 | 0.04584473115519921 | 0.0019570942016877003
(4 rows)
```

