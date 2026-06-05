$domain = Read-Host "Type the domain here: "
$web = Invoke-WebRequest -Uri "http://$domain" -Method Options
$web.header.server
$web.header.allow
$webSub = Invoke-WebRequest -uri "http://$domain"
$webSub.links.href | Select-String http://
