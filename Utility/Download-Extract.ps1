$clipath = $args[0]
$BackUpPath = [System.IO.Path]::Combine($args[1], "Great.zip")
$Destination = [System.IO.Path]::Combine($args[1], "Great_Directory")

Invoke-WebRequest -UseBasicParsing $clipath -OutFile $BackUpPath
Add-Type -assembly "system.io.compression.filesystem"
[io.compression.zipfile]::ExtractToDirectory($BackUpPath, $destination)
