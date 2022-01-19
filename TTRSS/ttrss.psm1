function New-Login
{
  <#
.DESCRIPTION
New-login is the first fucntion to call in the module; this connects you to the server so that you can excecute any other commands


.NOTES
The login endpoint is typically the url that you hit + api/
example: https://tiny.example.com/ may be the normal endpoint
the url for the system would be https://tiny.example.com/api/ 



#>
    [cmdletbinding()]
    param(
    [pscredential]$credential,
    [string]$url
    )
    $script:uri = $url
    $requestObject = New-Object -TypeName psobject -Property @{
        op = 'login'
        user = $credential.UserName
        password = $credential.GetNetworkCredential().Password 
    }
    $requestJson = $requestObject | ConvertTo-Json -Compress
    write-verbose $requestJson
    $params = @{
        uri=$script:uri
        Method='POST'
    }
    $response = Invoke-WebRequest @params -Body $requestJson
    $script:session_id = ($response.Content |ConvertFrom-Json).content.session_id
    if (!$script:session_id){throw "login issue"}
    #$script:session_id
}

function Get-ApiLevel {

    $script:uri
    $requestObject = New-Object -TypeName psobject -Property @{
        op = 'getApiLevel'
        sid = $script:session_id
    }
    $requestJson = $requestObject | ConvertTo-Json -Compress
    write-verbose $requestJson
    $params = @{
        uri=$script:uri
        Method='POST'
    }
    $response = Invoke-WebRequest @params -Body $requestJson
    $response.content
}

function Get-Version {

    $script:uri
    $requestObject = New-Object -TypeName psobject -Property @{
        op = 'getVersion'
        sid = $script:session_id
    }
    $requestJson = $requestObject | ConvertTo-Json -Compress
    write-verbose $requestJson
    $params = @{
        uri=$script:uri
        Method='POST'
    }
    $response = Invoke-WebRequest @params -Body $requestJson
    $response.content
}


function Clear-Login {

    $script:uri
    $requestObject = New-Object -TypeName psobject -Property @{
        op = 'logout'
        sid = $script:session_id
    }
    $requestJson = $requestObject | ConvertTo-Json -Compress
    write-verbose $requestJson
    $params = @{
        uri=$script:uri
        Method='POST'
    }
    $response = Invoke-WebRequest @params -Body $requestJson
    $response.content
}


function Get-Login {

    $script:uri
    $requestObject = New-Object -TypeName psobject -Property @{
        op = 'isLoggedIn'
        sid = $script:session_id
    }
    $requestJson = $requestObject | ConvertTo-Json -Compress
    write-verbose $requestJson
    $params = @{
        uri=$script:uri
        Method='POST'
    }
    $response = Invoke-WebRequest @params -Body $requestJson
    $response.content
}


function Get-Unread {

    $script:uri
    $requestObject = New-Object -TypeName psobject -Property @{
        op = 'getUnread'
        sid = $script:session_id
    }
    $requestJson = $requestObject | ConvertTo-Json -Compress
    write-verbose $requestJson
    $params = @{
        uri=$script:uri
        Method='POST'
    }
    $response = Invoke-WebRequest @params -Body $requestJson
    $response.content
}


function Get-Counters {
    param(
        [ValidateSet("f","l","c","t")]
        [string[]]$output_mode = @("f","l","c")
    )
    $script:uri
    $requestObject = New-Object -TypeName psobject -Property @{
        op = 'getCounters'
        sid = $script:session_id
    }
    $requestJson = $requestObject | ConvertTo-Json -Compress
    write-verbose $requestJson
    $params = @{
        uri=$script:uri
        Method='POST'
    }
    $response = Invoke-WebRequest @params -Body $requestJson
    $response.content
}


Function Get-Feeds
{
    [cmdletbinding()]
    param(
        [int]$category,
        [switch]$unread_only,
        [int]$limit,
        [int]$offset,
        [switch]$include_nested
    )

   
    $requestObject = New-Object -TypeName psobject -Property @{
        op = 'getFeeds'
        sid = $script:session_id
    }

    if ($unread_only){Add-Member -InputObject $requestObject -NotePropertyName unread_only -NotePropertyValue $unread_only.IsPresent }
    if ($limit){Add-Member -InputObject $requestObject -NotePropertyName limit -NotePropertyValue $limit }
    if ($offset){Add-Member -InputObject $requestObject -NotePropertyName offset -NotePropertyValue $offset }
    if ($include_nested){Add-Member -InputObject $requestObject -NotePropertyName include_nested -NotePropertyValue $include_nested.IsPresent }
    if ($category){Add-Member -InputObject $requestObject -NotePropertyName cat_id -NotePropertyValue $category }

    $requestJson = $requestObject | ConvertTo-Json -Compress
        $iwr = @{
        uri=$script:uri
        Method='POST'
    }
    write-verbose $requestJson   
    $response = Invoke-WebRequest @iwr  -Body $requestJson
    #$session_id = $response
    ($response.Content |ConvertFrom-Json).content
}


Function Get-Categories
{
    [cmdletbinding()]
    param(
       
        [switch]$unread_only,
        [switch]$include_empty ,
        [switch]$enable_nested
    )
    $requestObject = New-Object -TypeName psobject -Property @{
        op = 'getCategories'
        sid = $script:session_id
    }

    if ($unread_only){Add-Member -InputObject $requestObject -NotePropertyName unread_only -NotePropertyValue $unread_only.IsPresent }
    if ($include_empty){Add-Member -InputObject $requestObject -NotePropertyName include_empty -NotePropertyValue $include_empty.IsPresent }
    if ($enable_nested){Add-Member -InputObject $requestObject -NotePropertyName enable_nested -NotePropertyValue $enable_nested.IsPresent }
    


    $requestJson = $requestObject | ConvertTo-Json -Compress
    $script:params = @{
        uri=$script:uri
        ContentType='application/x-www-form-urlencoded'
        Method='POST'
    }
    $iwr = @{
        uri=$script:uri
        Method='POST'
    }
    Write-Debug $requestJson
    write-verbose $requestJson   
    $response = Invoke-WebRequest @iwr -Body $requestJson
    #$session_id = $response
    ($response.Content |ConvertFrom-Json).content
}

Function Get-Headlines
{
    <#
.DESCRIPTION
Get-Headlines Returns JSON-encoded list of headlines.


.NOTES
feed_id (integer|string) - only output articles for this feed (supports string values to retrieve tag virtual feeds since API level 18, otherwise integer)
view_mode (string = all_articles, unread, adaptive, marked, updated)

limit (integer) - limits the amount of returned articles (see below)
skip (integer) - skip this amount of feeds first
filter (string) - currently unused (?)
is_cat (bool) - requested feed_id is a category
show_excerpt (bool) - include article excerpt in the output
show_content (bool) - include full article text in the output
include_attachments (bool) - include article attachments ( e.g. enclosures) requires version:1.5.3
since_id (integer) - only return articles with id greater than since_id requires version:1.5.6
include_nested (boolean) - include articles from child categories requires version:1.6.0
order_by (string) - override default sort order requires version:1.7.6
sanitize (bool) - sanitize content or not requires version:1.8 (default: true)
force_update (bool) - try to update feed before showing headlines requires version:1.14 (api 9) (default: false)
has_sandbox (bool) - indicate support for sandboxing of iframe elements (default: false)
include_header (bool) - adds status information when returning headlines, instead of array(articles) return value changes to array(header, array(articles)) (api 12)

.LINK
https://tt-rss.org/wiki/ApiReference

#>

    
    [cmdletbinding()]
    param(
        [int]$feed_id,
        [Parameter(Mandatory=$true)]
        [ValidateSet("all_articles", "unread", "adaptive", "marked", "updated")]
        [string]$view_mode,
        [int]$limit,
        [int]$skip,
        #[string]$filter #currently unused
        [switch]$is_cat,
        [switch]$show_excerpt,
        [switch]$show_content,
        [switch]$include_attachments,
        [int]$since_id,
        [switch]$include_nested,
        [ValidateSet("date_reverse","feed_dates")]
        [string]$order_by,
        [switch]$sanitize,
        [switch]$force_update,
        [switch]$has_sandbox,
        [switch]$include_header,
        [string]$search,
        [ValidateSet("all_feeds","this_feed","this_cat")]
        [string]$search_mode
        
    )
    $requestObject = New-Object -TypeName psobject -Property @{
        op = 'getCategories'
        sid = $script:session_id
    }


    if ($limit){Add-Member -InputObject $requestObject -NotePropertyName limit -NotePropertyValue $limit }
    if ($skip){Add-Member -InputObject $requestObject -NotePropertyName skip -NotePropertyValue $skip }
    if ($is_cat){Add-Member -InputObject $requestObject -NotePropertyName is_cat -NotePropertyValue $is_cat.IsPresent }
    if ($show_excerpt){Add-Member -InputObject $requestObject -NotePropertyName show_excerpt -NotePropertyValue $show_excerpt.IsPresent }
    if ($show_content){Add-Member -InputObject $requestObject -NotePropertyName show_content -NotePropertyValue $show_content.IsPresent }
    if ($include_attachments){Add-Member -InputObject $requestObject -NotePropertyName include_attachments -NotePropertyValue $include_attachments.IsPresent }
    if ($since_id){Add-Member -InputObject $requestObject -NotePropertyName since_id -NotePropertyValue $since_id }
    if ($include_nested){Add-Member -InputObject $requestObject -NotePropertyName include_nested -NotePropertyValue $include_nested.IsPresent }
    if ($order_by){Add-Member -InputObject $requestObject -NotePropertyName order_by -NotePropertyValue $order_by }
    if ($sanitize){Add-Member -InputObject $requestObject -NotePropertyName sanitize -NotePropertyValue $sanitize.IsPresent }
    if ($force_update){Add-Member -InputObject $requestObject -NotePropertyName force_update -NotePropertyValue $force_update.IsPresent }
    if ($has_sandbox){Add-Member -InputObject $requestObject -NotePropertyName has_sandbox -NotePropertyValue $has_sandbox.IsPresent }
    if ($include_header){Add-Member -InputObject $requestObject -NotePropertyName include_header -NotePropertyValue $include_header.IsPresent }
    if ($search){Add-Member -InputObject $requestObject -NotePropertyName search -NotePropertyValue $search }
    if ($search_mode){Add-Member -InputObject $requestObject -NotePropertyName search_mode -NotePropertyValue $search_mode }

    $requestJson = $requestObject | ConvertTo-Json
    write-verbose $requestJson   
    $iwr = @{
        uri=$script:uri
        Method='POST'
    }
    $response = Invoke-WebRequest @iwr -Body $requestJson

    ($response.Content |ConvertFrom-Json).content
}

Function Set-Article{
    <#
.DESCRIPTION
Set-Article modifies the article read/starred/published setting in TTRSS.
article_ids (comma-separated list of integers) - article IDs to operate on
mode (integer) - type of operation to perform (0 - set to false, 1 - set to true, 2 - toggle)
field (integer) - field to operate on (0 - starred, 1 - published, 2 - unread, 3 - article note since api level 1)

.NOTES
updateArticle
Update information on specified articles.

Parameters:

article_ids (comma-separated list of integers) - article IDs to operate on
mode (integer) - type of operation to perform (0 - set to false, 1 - set to true, 2 - toggle)
field (integer) - field to operate on (0 - starred, 1 - published, 2 - unread, 3 - article note since api level 1)
data (string) - optional data parameter when setting note field (since api level 1)
E.g. to set unread status of articles X and Y to false use the following:

?article_ids=X,Y&mode=0&field=2

Since version:1.5.0 returns a status message:

{"status":"OK","updated":1}
“Updated” is number of articles updated by the query.

.LINK
https://tt-rss.org/wiki/ApiReference

#>
    [cmdletbinding()]
    param(
    [int[]]$article,
    [ValidateSet(0,1,2)]
    [int]$mode,
    [ValidateSet(0,1,2,3)]
    [int]$field,
    [string]$data
    )
    

    $requestObject = New-Object -TypeName psobject -Property @{
        op = 'updateArticle'
        sid = $script:session_id
        article_ids = $article -join ','
        mode = $mode
        field = $field
        data = $data
    }
    $requestJson = $requestObject | ConvertTo-Json -Compress

    write-verbose $requestJson
    $params = @{
        uri=$script:uri
        Method='POST'
    }
    $response = Invoke-WebRequest @params -Body $requestJson

    ($response.Content |ConvertFrom-Json).content
    #$script:session_id
}

Function ConvertTo-Text {
    [cmdletbinding()]
    param(
    [Parameter(Mandatory=$true)]
    [string]$html
    
    )
    begin{}
    process{
    $d = [HtmlAgilityPack.HtmlDocument]::new()
    $d.LoadHtml($html)
    $d.DocumentNode.InnerText
    }
    end{}
}