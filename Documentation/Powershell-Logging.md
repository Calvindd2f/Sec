## Learning to log better in powershell

```powershell
$Logfile = "$env:USERPROFILE\log.txt"<#
    if (!(Test-Path $Logfile)){
    New-Item -path "C:\users\c\" -name "log.txt" -type "file"
    }
    Else{
    break
   }#>

# Get-DateSortable
function Get-datesortable
{
  $global:datesortable = Get-Date -Format "HH':'mm':'ss"
  return $global:datesortable
}# Get-DateSortable


# Add-Logs
function Add-Logs
{
  [CmdletBinding()]
  param ([Object]$text)
  Get-datesortable
  Add-content -Path $Logfile -Value ('[{0}] - {1}' -f $global:datesortable, $text)
  
  Set-Alias -Name alogs -Value Add-Logs -Description 'Add shit to Logs'
  Set-Alias -Name Add-Log -Value Add-Logs -Description 'Add shit to Logs'
}# Add Logs


Add-Logs "$env:COMPUTERNAME is ass"
Add-Logs "$env:LOGONSERVER is not ass" 
```

### Output
```powershell
PS C:\Users\c> cat .\log.txt
[22:19:33] - EXIT is ass
[22:19:33] - \\EXIT is not ass
```
