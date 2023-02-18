$clipath = $args[0]
$BackUpPath = [System.IO.Path]::Combine($args[1], "dotnet-latest.zip")
$Destination = [System.IO.Path]::Combine($args[1], "dotnet")

Invoke-WebRequest -UseBasicParsing $clipath -OutFile $BackUpPath
Add-Type -assembly "system.io.compression.filesystem"
[io.compression.zipfile]::ExtractToDirectory($BackUpPath, $destination)
