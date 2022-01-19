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

    param(
    )
    $requestObject = '' | Select-Object sid,op
    $requestObject.op = 'getCategories'
    $requestObject.sid = $script:session_id
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

Function Get-Feeds
{
    [cmdletbinding()]
    param(
        [int]$category
    )

   
    $requestObject = '' | Select-Object sid,op,cat_id
    $requestObject.op = 'getFeeds'
    $requestObject.cat_id = $category
    $requestObject.sid = $script:session_id
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

Function Get-Headlines
{
    [cmdletbinding()]
    param(
        [int]$feed_id,
        [Parameter(Mandatory=$true)]
        [ValidateSet("all_articles", "unread", "adaptive", "marked", "updated")]
        [string]$view_mode,
        [switch]$show_content
    )
    
    $requestObject = '' | Select-Object sid,op,feed_id,view_mode 
    $requestObject.op = 'getHeadlines'
    $requestObject.feed_id  = $feed_id 
    $requestObject.sid = $script:session_id
    $requestObject.view_mode = $view_mode
    
    if ($show_content)
    {
        $requestObject | Add-Member -NotePropertyName show_content -NotePropertyValue $true
    }

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