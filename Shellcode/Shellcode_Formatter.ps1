<#.

Powershell shellcode formatter. Debating turning this into function but it works as is for now.
Taken from a private repo I own - DEC 12 2022

.#>

$fileName = 'C:\Users\User\Desktop\payload.bin'
$fileContent = [IO.File]::ReadAllBytes($fileName)
$filecontentsencoded = [convert]::ToBase64String($fileContent)
"Binary Blob base64 encoded:`n`n" + $filecontentsencoded | Set-Content ($fileName + '.b64')

$scformat = '\x' + (($fileContent | ForEach-Object -MemberName ToString x2) -join '\x')
"`nStandard shellcode format:`n`n" + $scformat | Add-Content ($fileName + '.b64')

$csharpformat = '0x' + (($fileContent |
    ForEach-Object -MemberName ToString x2 |
    ForEach-Object -Process {
      $_ + ',' 
}) -join '0x')
$csharpformat = $csharpformat.SubString(0, $csharpformat.Length-1)
"`nC# formatted shellcode:`n`n" + $csharpformat | Add-Content ($fileName + '.b64')

$Bytes = [System.Text.Encoding]::UTF8.GetBytes($csharpformat)
$EncodedText = [Convert]::ToBase64String($Bytes)
"`nBase64 Encoded C# shellcode:`n`n" + $EncodedText | Add-Content ($fileName + '.b64')

$fsharpformat = '0x' + (($fileContent |
    ForEach-Object -MemberName ToString x2 |
    ForEach-Object -Process {
      $_ + 'uy;' 
}) -join '0x')
$fsharpformat = $fsharpformat.SubString(0, $fsharpformat.Length-1)
"`nF# formatted shellcode:`n`n" + $fsharpformat | Add-Content ($fileName + '.b64')
