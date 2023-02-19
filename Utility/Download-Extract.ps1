#requires -Version 3.0
$clipath = $args[0]
$BackUpPath = [IO.Path]::Combine($args[1], 'latest.zip')
$Destination = [IO.Path]::Combine($args[1], 'dirname')

Invoke-WebRequest -UseBasicParsing -Uri $clipath -OutFile $BackUpPath
Add-Type -AssemblyName 'system.io.compression.filesystem'
[io.compression.zipfile]::ExtractToDirectory($BackUpPath, $Destination)
