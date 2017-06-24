
# load libraries
library(rvest)
library(tidyverse)
library(mailR)

setwd('/home/benbrew/Documents/databrew_misc/web_scraper')

# read in html for r users page 
the_page <- 'https://www.r-users.com/'

r_jobs <- read_html(the_page)

job_titles <- r_jobs %>% 
        html_nodes('strong a') %>%
        html_text()

job_loc <- r_jobs %>%
  html_nodes('dd strong') %>%
  html_text()

# make job loc a 3 column data frame 
job_dat <- data.frame(matrix(job_loc, ncol = 3, byrow = T))

# get column names
colnames(job_dat) <- c('title', 'location', 'date')

# get links to each job posting 
urls <- r_jobs %>%
  html_nodes('strong a') %>%
  html_attr('href')

job_dat$url <- urls

ids <- paste0(job_dat$url, job_dat$date)

job_dat$id <- ids

old_data <- read_csv('old_data.csv')

new_jobs <- job_dat[!job_dat$id %in% old_data$id,]

if (nrow(new_jobs > 0)) {
  
  from = 'benmbrew@gmail.com'
  password = read.csv('pword.csv') %>% .$password %>% as.character()
  to = 'joebrew@gmail.com'  #'xing@databrew.cc'
  subject = paste0(nrow(new_jobs), ' ', 'New R jobs')
  content = paste0(paste0(new_jobs$title, ": ",
                          new_jobs$location, ": ",
                          new_jobs$url), collapse = '\n\n')
  
  
  send.mail(from = from,
            to = to,
            subject = subject,
            body = content,
            smtp = list(host.name = "smtp.gmail.com", 
                        port = 465, 
                        user.name = from,
                        passwd=password, 
                        ssl=TRUE),
            authenticate = TRUE,
            send = TRUE)  
  
  
  write_csv(job_dat, 'old_data.csv')
  
}














# for (i in 1:nrow(job_dat)) {
#   
#   temp_url <- job_dat$url[i]
#   temp_html <- read_html(temp_url)
#   temp_text <- temp_html %>% 
#     html_nodes('div a') %>%
#     html_text()
#   has_email <- grepl('@', temp_text) & grepl('.com|.org', temp_text) & !grepl(' @ ', temp_text)
#   pos_email <- temp_text[has_email]
#   
#   
#   temp_list <- strsplit(temp_text, ' ')
#   is_email <- unlist( lapply(temp_list, 
#          function(x) {
#            grepl('@', x, fixed = T) & !is.na(x)
#          }))
#   
#   the_email <- temp_list[[1]][is_email]
#   # Remove NAs
#   the_email <- the_email[!is.na(the_email)]
#   
# }
