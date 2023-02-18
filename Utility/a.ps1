<#.
Author: Calvindd2f
This is meant to be ran from powershell cradle [one-liner].
This is not intended to be a function.
For example:
$i=https://rawlinktothis.com ; irm $i |% {iex $_}
.#>

Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms 

$signature = @'
[DllImport("user32.dll",CharSet=CharSet.Auto,CallingConvention=CallingConvention.StdCall)]
public static extern void mouse_event(long dwFlags, long dx, long dy, long cButtons, long dwExtraInfo);
'@
$SendMouseClick = Add-Type -MemberDefinition $signature -Name 'Win32MouseEventNew' -Namespace Win32Functions -PassThru 
$X = [Windows.Forms.Cursor]::Position.X
$Y = [Windows.Forms.Cursor]::Position.Y 
Write-Output -InputObject ('X: {0} | Y: {1}' -f $X, $Y) 
$X = 86 
$Y = 172
[Windows.Forms.Cursor]::Position = New-Object -TypeName System.Drawing.Point -ArgumentList ($X, $Y)
Start-Sleep -Seconds 01
Write-Output -InputObject 'Remote call me using this command'
Write-Output -InputObject ''
Start-Sleep -Seconds 01
while ($true) 
{
  $SendMouseClick::mouse_event(0x00000002, 0, 0, 0, 0)
  Start-Sleep -Milliseconds 555
  $SendMouseClick::mouse_event(0x00000004, 0, 0, 0, 0)
  Start-Sleep -Milliseconds 555
}
