import-module ~/Source/repos/ttrss-powershell/TTRSS/ttrss.psd1 -force
$ttrssCred = import-clixml -path ~/.passwords/ttrss.clixml
New-TTRSSLogin -credential $ttrssCred -url $url
Get-TTRSSApiLevel 
Get-TTRSSVersion
Get-TTRSSLogin
Get-TTRSSUnread
Get-TTRSSCounters
Get-TTRSSCounters -output_mode c
Get-TTRSSCounters -output_mode f
Get-TTRSSCounters -output_mode l
Get-TTRSSCounters -output_mode t
Get-TTRSSCounters -output_mode c,f,l,t  -Verbose
Get-TTRSSCounters -output_mode c,f,l
Get-TTRSSCounters -output_mode c,f

Get-TTRSSFeeds
Get-TTRSSFeeds -category 0 |Format-Table title,cat_id
Get-TTRSSFeeds -category 0 -limit 1 |Format-Table title,cat_id
Get-TTRSSFeeds -category 0 -offset 1 |Format-Table title,cat_id
Get-TTRSSFeeds -category 0 -offset 1  -limit 1|Format-Table title,cat_id
Get-TTRSSFeeds -category 1  -Verbose |Format-Table title,cat_id
Get-TTRSSFeeds -unread_only   -Verbose |Format-Table title,cat_id
Get-TTRSSFeeds -include_nested  -Verbose |Format-Table title,cat_id

Get-TTRSSCategories -Verbose
Get-TTRSSCategories -unread_only -Verbose
Get-TTRSSCategories -include_empty -Verbose
Get-TTRSSCategories -enable_nested -Verbose
Get-TTRSSCategories -unread_only -include_empty -Verbose
Get-TTRSSCategories -include_empty -enable_nested -Verbose
Get-TTRSSHeadlines -view_mode adaptive
Clear-TTRSSLogin
Get-TTRSSLogin