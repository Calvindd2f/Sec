# TODO: Turn into function

$url = "https://dread.ie/"
$webReq = Invoke-WebRequest -uri $url -Method Get # -Headers $headers 
$foo = $webReq.Content -replace "\r?\n"
$foo | Out-File -FilePath .\Dread.html -Encoding  default
