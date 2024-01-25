# first you need to install the libraries DBI and RSQlite
# please do so by clicking on the Packages tab on the right, then Install.
# Type the name of the packages: "DBI, RSQLite" without the " and hit Install
library(tidyverse)
library(DBI)
library(jsonlite)
library(RSQLite)
library(RPostgres)
con <- dbConnect(RPostgres::Postgres(), dbname="remoteuser", host = "localhost", port = "5432",
	user = "dsma_student", password = "DSMA_Stud23")

# now you should be connected. Please check by clicking on Connections tab on the upper right. You should see the 
# name of the database "remoteuser".
# get businesses
fileName1=paste0("./sql_queries/business.sql") # the name of the file containing the query is first_example.sql
sqlquery1=readChar(fileName1, file.info(fileName1)$size)
business=dbGetQuery(con, statement = sqlquery1) # this stores the output in a variable called output


# get checkins, problem because of column with length over 255 characters
#
fileName2=paste0("./sql_queries/checkin.sql") # the name of the file containing the query is first_example.sql
sqlquery2=readChar(fileName2, file.info(fileName2)$size)
checkin=dbGetQuery(con, statement = sqlquery2) # this stores the output in a variable called output

# get photos
fileName3=paste0("./sql_queries/photo.sql") # the name of the file containing the query is first_example.sql
sqlquery3=readChar(fileName3, file.info(fileName3)$size)
photo=dbGetQuery(con, statement = sqlquery3) # this stores the output in a variable called output

# get reviews
fileName4=paste0("./sql_queries/review.sql") # the name of the file containing the query is first_example.sql
sqlquery4=readChar(fileName4, file.info(fileName4)$size)
review=dbGetQuery(con, statement = sqlquery4) # this stores the output in a variable called output

# get tips
fileName5=paste0("./sql_queries/tip.sql") # the name of the file containing the query is first_example.sql
sqlquery5=readChar(fileName5, file.info(fileName5)$size)
tip=dbGetQuery(con, statement = sqlquery5) # this stores the output in a variable called output

# get users
fileName6=paste0("./sql_queries/users.sql") # the name of the file containing the query is first_example.sql
sqlquery6=readChar(fileName6, file.info(fileName6)$size)
users=dbGetQuery(con, statement = sqlquery6) # this stores the output in a variable called output

DBI::dbDisconnect(con)

write_csv(business, "data/business.csv")
write_csv(photo, "data/photo.csv")
write_csv(users, "data/users.csv")
write_csv(tip, "data/tip.csv")
write_csv(review, "data/review.csv")
write_csv(checkin, "data/checkin.csv")
