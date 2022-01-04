# ttrss-powershell
Powershell module to interact with the TT-RSS API
https://tt-rss.org/wiki/ApiReference

# Functions
## New-Login
function to login

## Get-Categories
the categories in your ttrss login

## Get-Feeds 
the feeds in your login, can be filtered by category

## Get-Headlines
based on feed id; requires you specify a view_mode ("all_articles", "unread", "adaptive", "marked", "updated")

## Set-Article
api function to modify the article (set unread;starred;published)
