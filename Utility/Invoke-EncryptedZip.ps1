#requires -Version 2.0
## WIP please do not rely on me.
# Author: Calvindd2f

function Invoke-EncryptedZip 
{
  <#
      .SYNOPSIS
      Invoke-EncryptedZip
      .DESCRIPTION
      Create-EncryptedZip is a utility to make a Enrypted Zip compresed file from a provided folder.
      This allows users to stage files in designated folder for exfil, or protection from final storage location. 
      Refrence: https://technet.microsoft.com/en-us/library/2009.04.heyscriptingguy.aspx
      .PARAMETER SourceDirectory
      Required source directory to be Zip Encrypted archived
      .PARAMETER ZipFileName
      Required Zip file name to be outputed
      .PARAMETER ZipFilePath
      Required Zip file output directory
      .PARAMETER EncryptedFileName
      Required final encrypted file name 
      .PARAMETER EncryptedFilePath
      Required final encrypted file path
      .PARAMETER ZipMethod
      Select the Method (COM, NET) to be used to Zip file (DEFAULT: NET)
      .PARAMETER EncryptMethod
      Select the Method (Stream, Memory) to be used to to encrypt the (DEFAULT: Stream)
      Memory is only good to about 1MB max to prevent PS consuming to much mem.
      .PARAMETER CleanUp
      Switch to enable clean up of source folder and zip file created. (DEFAULT: False)
      .EXAMPLE
      Invoke-EncryptedZip -SourceDirectory "C:\CINEBENCHR15.038" -ZipFileName "test.zip" -ZipFilePath "C:\" -EncryptedFilePath "C:\"
        
      Invoke-EncryptedZip -SourceDirectory "C:\CINEBENCHR15.038" -ZipFileName "test.zip" -ZipFilePath "C:\\" -EncryptedFilePath "C:\" -ZipMethod  'COM' 
      Invoke-EncryptedZip -SourceDirectory "C:\CINEBENCHR15.038" -ZipFileName "test.zip" -ZipFilePath "C:\\" -EncryptedFilePath "C:\" -ZipMethod  'COM' -EncryptMethod 'Memory'
      Invoke-EncryptedZip -SourceDirectory "C:\CINEBENCHR15.038" -ZipFileName "test.zip" -ZipFilePath "C:\\" -EncryptedFilePath "C:\" -ZipMethod  'NET' -EncryptMethod 'Stream' -ZipMethod 'NET' -EncryptMethod 'Stream' -CleanUp -Verbose
        
  #>

  Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [String]
    $SourceDirectory,

    [Parameter(Mandatory = $true, Position = 1)]
    [string]
    $ZipFileName,

    [Parameter(Mandatory = $true, Position = 2)]
    [string]
    $ZipFilePath,

    [Parameter(Mandatory = $true, Position = 3)]
    [string]
    $EncryptedFileName,

    [Parameter(Mandatory = $true, Position = 4)]
    [string]
    $EncryptedFilePath,

    [Parameter(Position = 5)]
    [ValidateSet('COM', 'NET')]
    [String]
    $ZipMethod = 'NET',

    [Parameter(Position = 6)]
    [ValidateSet('Stream', 'Memory')]
    [String]
    $EncryptMethod = 'Stream',

    [Parameter(Position = 7)]
    [Switch]
    $CleanUp = $false
  )

  Begin {
    $ErrorActionPreference = 'Stop'
    if(![IO.Directory]::Exists($SourceDirectory))
    {
      Write-Error -Message ('[!] Cant find source directory {0}, baling out' -f $SourceDirectory)
      Exit
    }
    # Create zip file and test to make sure it was wrote to correct location
    if ($ZipMethod -eq 'COM') 
    {
      Create-ZipFileCOM -SourceDirectory $SourceDirectory -ZipFileName $ZipFileName -ZipFilePath $ZipFilePath
    }
    if ($ZipMethod -eq 'NET') 
    {
      Create-ZipFileNET -SourceDirectory $SourceDirectory -ZipFileName $ZipFileName -ZipFilePath $ZipFilePath
    } 
    $ZipFile = ('{0}{1}' -f $ZipFilePath, $ZipFileName)
    if(-not (Test-Path -Path ($ZipFile))) 
    {
      Write-Output -InputObject '[!] No zip present after creation, baling out!'
      Exit
    }
    Start-Sleep -Seconds 2
  }
    
    
  Process {
    #Begin main process block exec of encryption 
    if ($EncryptMethod -eq 'Stream') 
    {
      Write-Verbose -Message '[*] Stream encryption selected'
      $AesKey = Create-AesKey
      $Result = Encrypt-AESFileStream -SourceDirectory $ZipFilePath -SourceFile $ZipFileName -EncryptedFileName $EncryptedFileName -EncryptedFilePath $EncryptedFilePath -AesKey $AesKey
      Remove-Variable -Name AesKey
      [GC]::Collect()
    }
    if ($EncryptMethod -eq 'Memory') 
    {
      Write-Verbose -Message '[*] Memory encryption selected'
      $FileBytes = [IO.File]::ReadAllBytes($ZipFile)
      $AesKey = Create-AesKey
      $EncryptedBytes = Encrypt-Bytes -AesKey $AesKey -Bytes $FileBytes
      Remove-Variable -Name FileBytes
      [GC]::Collect()
      $EncryptedFile = ('{0}{1}' -f $EncryptedFilePath, $EncryptedFileName)
      [io.file]::WriteAllBytes($EncryptedFile, $EncryptedBytes)
      Remove-Variable -Name EncryptedBytes
      [GC]::Collect()
      $Result = New-Object -TypeName PSObject
      $Result | Add-Member -MemberType NoteProperty -Name Computer -Value $env:COMPUTERNAME
      $Result | Add-Member -MemberType NoteProperty -Name Key -Value $AesKey
      $Result | Add-Member -MemberType NoteProperty -Name Files -Value $EncryptedFile
    }
  }

  End {
    [GC]::Collect()
    if ($CleanUp) 
    {
      # start file clean up routine 
      Remove-Item -Path $SourceDirectory -Recurse -Force
      Write-Verbose -Message "[*] Source folder deleted: $SourceDirectory"
      Remove-Item -Path $ZipFile -Force
      Write-Verbose -Message "[*] Zip archive deleted: $ZipFile"
      if([IO.Directory]::Exists($SourceDirectory))
      {
        Write-Warning -Message "[!] WARNING: Source folder deletion failed, please manualy remove: $SourceDirectory"
      }
      if([IO.File]::Exists($ZipFileName))
      {
        Write-Warning -Message "[!] WARNING: Zip deletion failed, please manualy remove: $ZipFile"
      }
    }
    return $Result
  }
}


function Invoke-DecryptZip 
{
  <#
      .SYNOPSIS
      Invoke-EncryptedZip
      Author: dd2f
      License: BSD 3-Clause
      Required Dependencies: None
      Optional Dependencies: None
      .DESCRIPTION
      Invoke-DecryptZip is a utility to decrypt files created with this utility.
      Refrence: https://technet.microsoft.com/en-us/library/2009.04.heyscriptingguy.aspx
      .PARAMETER EncryptedFileName
      Required final encrypted file name 
      .PARAMETER EncryptedFilePath
      Required final encrypted file path
      .PARAMETER ZipMethod
      Select the Method (COM, NET) to be used to Zip file (DEFAULT: NET)
      .PARAMETER EncryptMethod
      Select the Method (Stream, Memory) to be used to to encrypt the (DEFAULT: Stream)
      Memory is only good to about 1MB max to prevent PS consuming to much mem.
      .PARAMETER CleanUp
      Switch to enable clean up of source folder and zip file created. (DEFAULT: False)
      .EXAMPLE
        
      Invoke-DecryptZip -EncryptedFileName 'shellcode.dat' -EncryptedFilePath 'C:\Users\admin\Desktop\' -AesKey  'H2dbIaoK2MFYU2ge/4cx00XjLuLSC63odhqhKP4vC84=' 
      Invoke-DecryptZip -EncryptedFileName 'shellcode.dat' -EncryptedFilePath 'C:\Users\admin\Desktop\' -AesKey  'H2dbIaoK2MFYU2ge/4cx00XjLuLSC63odhqhKP4vC84=' -CleanUp -Verbose
      Computer     Key                                          Files
      --------     ---                                          -----
      TEST         H2dbIaoK2MFYU2ge/4cx00XjLuLSC63odhqhKP4vC84= C:\Users\admin\Desktop\shellcode.zip
        
  #>

  Param (

    [Parameter(Mandatory = $true, Position = 1)]
    [string]
    $AesKey,

    [Parameter(Mandatory = $true, Position = 2)]
    [string]
    $EncryptedFileName,

    [Parameter(Mandatory = $true, Position = 3)]
    [string]
    $EncryptedFilePath,

    [Parameter(Position = 4)]
    [ValidateSet('COM', 'NET')]
    [String]
    $ZipMethod = 'NET',

    [Parameter(Position = 5)]
    [ValidateSet('Stream', 'Memory')]
    [String]
    $EncryptMethod = 'Stream',

    [Parameter(Position = 6)]
    [Switch]
    $CleanUp = $false
  )

  Begin {
    $ErrorActionPreference = 'Stop'
    $EncryptedFile = ('{0}{1}' -f $EncryptedFilePath, $EncryptedFileName)
    $DecryptedFile = $EncryptedFileName.Split('.')[0] + '.zip'
    if(![IO.File]::Exists($EncryptedFile))
    {
      Write-Error -Message "[!] Cant find Encrypted File $EncryptedFile, baling out"
    }
    if ($EncryptMethod -eq 'Stream') 
    {
      Write-Verbose -Message '[*] Stream dcryption selected'
      $Result = Decrypt-AESFileStream -DestionationDirectory $EncryptedFilePath -DestionationFile $DecryptedFile -EncryptedFileName $EncryptedFileName -EncryptedFilePath $EncryptedFilePath -AesKey $AesKey
      Remove-Variable -Name AesKey
      [GC]::Collect()
    }
  }
    
    
  Process {
    #Begin main process block exec of de ziping 
    $ZipFile = ('{0}{1}' -f $EncryptedFilePath, $DecryptedFile)
    $DecryptedFolder = $EncryptedFileName.Split('.')[0]
    $DecompressedZipFolder = ('{0}{1}' -f $EncryptedFilePath, $DecryptedFolder)
    if ($ZipMethod -eq 'NET') 
    {
      Create-DecompressedZipFileNET -ZipFilePath $ZipFile -OutputFolderPath $DecompressedZipFolder
    } 
    Write-Verbose -Message "[*] Zip decompressed to: $DecompressedZipFolder"
    if(![IO.Directory]::Exists($DecompressedZipFolder))
    {
      Write-Error -Message '[!] No folder Decompressed present after creation, baling out!'
    }
  }

  End {
    [GC]::Collect()
    if ($CleanUp) 
    {
      # start file clean up routine 
      Remove-Item -Path $EncryptedFile -Force
      Write-Verbose -Message "[*] Source file deleted: $EncryptedFile"
      Remove-Item -Path $ZipFile -Force
      Write-Verbose -Message "[*] Zip archive deleted: $ZipFile"
      if([IO.Directory]::Exists($EncryptedFile))
      {
        Write-Warning -Message "[!] WARNING: Source folder deletion failed, please manualy remove: $EncryptedFile"
      }
      if([IO.File]::Exists($ZipFile))
      {
        Write-Warning -Message "[!] WARNING: Zip deletion failed, please manualy remove: $ZipFile"
      }
    }
    return $Result
  }
}

function Create-AesManagedObject 
{
  <#
      .SYNOPSIS
      Author: dd2f
      License: BSD 3-Clause
      Required Dependencies: None
      Optional Dependencies: None
      .DESCRIPTION
      Makes the required AES object for encryption and decryption 
      Refrence: https://gist.github.com/ctigeek/2a56648b923d198a6e60
      .PARAMETER AesKey
      The required AES key being used for encryption (base64 key)
      .PARAMETER AesIV
      The required AES IV being used for encryption (base64 iv)
      .EXAMPLE
      Create-AesManagedObject $key $iv
  #>

  Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [String]
    $AesKey,

    [Parameter(Mandatory = $true, Position = 1)]
    [string]
    $AesIV
  )

  Begin {
    if ($AesKey) 
    {
      Write-Verbose -Message "[*] Key being used for encryption: $AesKey"
    }
    if ($AesIV) 
    {
      Write-Verbose -Message "[*] IV being used for encryption: $iv"
    }
  }
   
  Process {
    #Begin main process block
    $ErrorActionPreference = 'Stop'
    $aesManaged = New-Object -TypeName 'System.Security.Cryptography.AesManaged'
    $aesManaged.Mode = [Security.Cryptography.CipherMode]::CBC
    $aesManaged.Padding = [Security.Cryptography.PaddingMode]::Zeros
    $aesManaged.BlockSize = 128
    $aesManaged.KeySize = 256
    if ($AesIV) 
    {
      if ($AesIV.getType().Name -eq 'String') 
      {
        $aesManaged.IV = [Convert]::FromBase64String($AesIV)
      }
      else 
      {
        $aesManaged.IV = $AesIV
      }
    }
    if ($AesKey) 
    {
      if ($AesKey.getType().Name -eq 'String') 
      {
        $aesManaged.Key = [Convert]::FromBase64String($AesKey)
      }
      else 
      {
        $aesManaged.Key = $AesKey
      }
    }
  }

  End {

    Write-Verbose -Message '[*] Completed AES object creation'
    # return obj to pipeline
    $aesManaged
  }
}

function Create-AesKey 
{
  <#
      .SYNOPSIS
      Author: dd2f
      License: BSD 3-Clause
      Required Dependencies: None
      Optional Dependencies: None
      .DESCRIPTION
      Makes the required AES key object to pass
      .EXAMPLE
      $b64key = Create-AesKey 
  #>

  Begin {
    Write-Verbose -Message '[*] AES key creation started'
  }
    
    
  Process {
    
    #Begin main process block
    $ErrorActionPreference = 'Stop'
    $aesManaged = Create-AesManagedObject
    $aesManaged.GenerateKey()
  }

  End {

    Write-Verbose -Message '[*] Completed AES key creation'
    # return obj to pipeline
    $AesKey = [Convert]::ToBase64String($aesManaged.Key)
    Write-Verbose -Message "[*] AES key created: $AesKey"
    return $AesKey
  }
}


function Encrypt-Bytes 
{
  <#
      .SYNOPSIS
      Author: dd2f
      License: BSD 3-Clause
      Required Dependencies: None
      Optional Dependencies: None
      .DESCRIPTION
      Makes the required AES object for encryption and decryption 
      .PARAMETER AesKey
      The required AES key being used for encryption (base64 key)
      .PARAMETER Bytes
      The bytes to be encrypted via AES
      .EXAMPLE
      Encrypt-Bytes $AesKey $FileBytes
  #>

  Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [String]
    $AesKey,

    [Parameter(Mandatory = $true, Position = 1)]
    [Object]$Bytes
  )

  Begin {
    Write-Verbose -Message "[*] Key being used for encryption of bytes: $key"
  }
    
    
  Process {
    $ErrorActionPreference = 'Stop'
    $aesManaged = Create-AesManagedObject -AesKey $AesKey
    $encryptor = $aesManaged.CreateEncryptor()
    $encryptedData = $encryptor.TransformFinalBlock($Bytes, 0, $Bytes.Length)

    [byte[]] $fullData = $aesManaged.IV + $encryptedData
    $aesManaged.Dispose()
    # $finalbytes = [System.Convert]::ToBase64String($fullData)
    $finalbytes = $fullData

  }

  End {

    Write-Verbose -Message '[*] Completed AES encryption of bytes'
    # return obj to pipeline
    $finalbytes
  }
}

function Create-ZipFileCOM 
{
  <#
      .SYNOPSIS
      Author: dd2f
      License: BSD 3-Clause
      Required Dependencies: None
      Optional Dependencies: None
      .DESCRIPTION
      Makes the required AES object for encryption and decryption
      .PARAMETER SourceDirectory
      Required source directory to be Zip archived
      .PARAMETER ZipFileName
      Required Zip file name to be outputed
      .PARAMETER ZipFilePath
      Required Zip file output directory
      .EXAMPLE
      Create-ZipFile -SourceDirectory "C:\Users\KILLSWITCH-GUI\Desktop\Ethereum-Wallet-win32-0-8-10\win-ia32-unpacked" -ZipFileName "test.zip" -ZipFilePath "C:\Users\KILLSWITCH-GUI\Desktop\" -Verbose
  #>

  Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [String]
    $SourceDirectory,

    [Parameter(Mandatory = $true, Position = 1)]
    [string]
    $ZipFileName,

    [Parameter(Mandatory = $true, Position = 1)]
    [string]
    $ZipFilePath
  )

  Begin {
    $ErrorActionPreference = 'Stop'
    $ZipFile = ('{0}{1}' -f $ZipFilePath, $ZipFileName)
    Write-Verbose -Message "[*] Full Zip file output path: $ZipFile"
    Write-Verbose -Message "[*] Full path of folder to be zipped: $SourceDirectory"
    #Prepare zip file on disk
    if(-not (Test-Path -Path ($ZipFile))) 
    {
      Set-Content -Path $ZipFile -Value ('PK' + [char]5 + [char]6 + ("$([char]0)" * 18))
      (dir -Path $ZipFile).IsReadOnly = $false  
    }
  }
    
  Process {
    $shellApplication = New-Object -ComObject shell.application
    $zipPackage = $shellApplication.NameSpace($ZipFile)
    $files = Get-ChildItem -Path $SourceDirectory 

    foreach($file in $files) 
    { 
      $zipPackage.CopyHere($file.FullName)
      while($zipPackage.Items().Item($file.name) -eq $null)
      {
        Write-Verbose -Message "[*] Completed compression on file: $file"
        Start-Sleep -Seconds 1
      }
    }

  }

  End {
    $len = (Get-Item -Path "$ZipFile").length
    # TODO: Fix addtype
    # $size = Convert-Size -Size $len
    $size = $len
    Write-Verbose -Message '[*] Completed Zip file creation'
    Write-Verbose -Message "[*] Final Zip file size: $size"
  }
}


function Create-DecompressedZipFileNET 
{
  <#
      .SYNOPSIS
      Author: dd2f
      License: BSD 3-Clause
      Required Dependencies: None
      Optional Dependencies: None
      .DESCRIPTION
      Uses .NET to Decompressed zip file to directory
      Refrence: https://stackoverflow.com/questions/1153126/how-to-create-a-zip-archive-with-powershell
      .PARAMETER ZipFilePath
      Required Zip file full file path Ex: C:\Windows\Tasks\test.zip
      .PARAMETER OutputFolderPath
      Required output directory that will be created Ex: C:\Windows\Tasks\test
      This creates a directory. As .NET can only zip a directory.
      
      .EXAMPLE
  #>

  Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [String]
    $ZipFilePath,

    [Parameter(Mandatory = $true, Position = 1)]
    [string]
    $OutputFolderPath
  )

  Begin {
    $ErrorActionPreference = 'Stop'
    Write-Verbose -Message "[*] Full path of file to be Decompressed: $ZipFilePath"
    Write-Verbose -Message "[*] Full path of zip file to be stored to: $OutputFolderPath"
  }
    
  Process {
    Add-Type -AssemblyName System.IO.Compression.FileSystem > $null
    [IO.Compression.ZipFile]::ExtractToDirectory($ZipFilePath,$OutputFolderPath)
  }

  End {
    Write-Verbose -Message '[*] Completed Decompressed file creation'
  }
}

function Invoke-ZipFileNET 
{
  <#
      .SYNOPSIS
      .DESCRIPTION
      Uses .NET to zip file directory
      Refrence: https://stackoverflow.com/questions/1153126/how-to-create-a-zip-archive-with-powershell
      .PARAMETER SourceDirectory
      Required source directory to be Zip archived
      .PARAMETER ZipFileName
      Required Zip file name to be outputed
      .PARAMETER ZipFilePath
      Required Zip file output directory
      .EXAMPLE
      Create-ZipFile -SourceDirectory "C:\Users\KILLSWITCH-GUI\Desktop\Ethereum-Wallet-win32-0-8-10\win-ia32-unpacked" -ZipFileName "test.zip" -ZipFilePath "C:\Users\KILLSWITCH-GUI\Desktop\" -Verbose
  #>

  Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [String]
    $SourceDirectory,

    [Parameter(Mandatory = $true, Position = 1)]
    [string]
    $ZipFileName,

    [Parameter(Mandatory = $true, Position = 1)]
    [string]
    $ZipFilePath
  )

  Begin {
    $ErrorActionPreference = 'Stop'
    $ZipFile = ('{0}{1}' -f $ZipFilePath, $ZipFileName)
    Write-Verbose -Message "[*] Full Zip file output path: $ZipFile"
    Write-Verbose -Message "[*] Full path of folder to be zipped: $SourceDirectory"
  }
    
  Process {
    Add-Type -AssemblyName System.IO.Compression.FileSystem > $null
    $compressionLevel = [IO.Compression.CompressionLevel]::Optimal
    [IO.Compression.ZipFile]::CreateFromDirectory($SourceDirectory,
    $ZipFile, $compressionLevel, $false)
  }

  End {
    $len = (Get-Item -Path ('{0}' -f $ZipFile)).length
    # TODO: Fix addtype
    # $size = Convert-Size -Size $len
    $size = $len
    Write-Verbose -Message '[*] Completed Zip file creation'
    Write-Verbose -Message "[*] Final Zip file size: $size"
  }
}

function Encrypt-AESFileStream 
{
  <#
      .SYNOPSIS
      Author: dd2f
      License: BSD 3-Clause
      Required Dependencies: None
      Optional Dependencies: None
      .DESCRIPTION
      Uses .NET to encrypt using file stream rather than fully in mem.
      Refrence: https://stackoverflow.com/questions/1153126/how-to-create-a-zip-archive-with-powershell
      https://msdn.microsoft.com/en-us/library/system.security.cryptography.cryptostream.cryptostream(v=vs.110).aspx
      https://gallery.technet.microsoft.com/scriptcenter/EncryptDecrypt-files-use-65e7ae5d
      .PARAMETER SourceDirectory
      Required source directory of file directory to be encrypted
    
      .PARAMETER SourceFile
      Required source file name to be encrypted
      .PARAMETER EncryptedFileName
      Required final encrypted file name 
      .PARAMETER EncryptedFilePath
      Required final encrypted file path
      .PARAMETER AesKey
      Required AES key to be used for encryption
    
      .NOTES
        
      Adapted from Tyler Siegrist.
      .EXAMPLE
      $key = Create-AesKey
      Encrypt-AESFileStream -SourceDirectory "C:\Users\admin\Desktop\" -SourceFile "secrets.txt" -EncryptedFileName "secrets.crypto" -EncryptedFilePath "C:\Users\admin\Desktop\" -AesKey $key
      Computer     Key                                          Files
      --------     ---                                          -----
      TEST         7f/3e9cQF8yx2UNhG/Dc6XYLKYqXptK1ALB+tP3QUwA= C:\Users\admin\Desktop\secrets.crypto
  #>

  Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [String]
    $SourceDirectory,

    [Parameter(Mandatory = $true, Position = 1)]
    [String]
    $SourceFile,

    [Parameter(Mandatory = $true, Position = 2)]
    [string]
    $EncryptedFileName,

    [Parameter(Mandatory = $true, Position = 3)]
    [string]
    $EncryptedFilePath,

    [Parameter(Mandatory = $true, Position = 4)]
    [string]
    $AesKey
  )

  Begin {
    $ErrorActionPreference = 'Stop'
    $EncryptedFile = "$EncryptedFilePath$EncryptedFileName"
    $SourceFileName = ('{0}{1}' -f $SourceDirectory, $SourceFile)
    $AESProvider = Create-AesManagedObject -AesKey $AesKey
    Add-Type -AssemblyName System.Security.Cryptography
    if(![IO.File]::Exists($SourceFileName))
    {
      Write-Verbose -Message "[*] File check failed: $SourceFileName"
      Write-Error -Message '[!] File not present? Check your self!'
    }
    Write-Verbose -Message "[*] File check passed: $SourceFileName"
  }
    
  Process {
    # create the file stream for the encryptor
    $FileStreamReader = New-Object -TypeName System.IO.FileStream -ArgumentList ($SourceFileName, [IO.FileMode]::Open)
       
   
    # create destination file
    Try
    {
      $FileStreamWriter = New-Object -TypeName System.IO.FileStream -ArgumentList ($EncryptedFile, [IO.FileMode]::Create)
    }
    Catch
    {
      Write-Error -Message "[!] Unable to open file to write: $FileStreamWriter"
      $FileStreamReader.Close()
      $FileStreamWriter.Close()
    }
    # write IV length & IV to encrypted file header
    $AESProvider.GenerateIV()
    $FileStreamWriter.Write([BitConverter]::GetBytes($AESProvider.IV.Length), 0, 4)
    $FileStreamWriter.Write($AESProvider.IV, 0, $AESProvider.IV.Length)
    # start encryption routine 
    Write-Verbose -Message "[*] Encrypting $SourceFileName with an IV of $([Convert]::ToBase64String($AESProvider.IV))"

    try
    {
      $Transform = $AESProvider.CreateEncryptor()
      $CryptoStream = New-Object -TypeName System.Security.Cryptography.CryptoStream -ArgumentList ($FileStreamWriter, $Transform, [Security.Cryptography.CryptoStreamMode]::Write)
      [Int]$Count = 0
      [Int]$BlockSizeBytes = $AESProvider.BlockSize / 8
      [Byte[]]$Data = New-Object -TypeName Byte[] -ArgumentList $BlockSizeBytes
      Do
      {
        $Count = $FileStreamReader.Read($Data, 0, $BlockSizeBytes)
        $CryptoStream.Write($Data, 0, $Count)
      }
      While($Count -gt 0)
    
      #Close open files
      $CryptoStream.FlushFinalBlock()
      $CryptoStream.Close()
      $FileStreamReader.Close()
      $FileStreamWriter.Close()
      # finshed
      Write-Verbose -Message "[*] Successfully encrypted file: $EncryptedFile"
    }
    catch
    {
      Write-Error -Message "[!] Failed to encrypt: $SourceFileName"
      $CryptoStream.Close()
      $FileStreamWriter.Close()
      $FileStreamReader.Close()
      Remove-Item -Path $EncryptedFile -Force
    }
  }

  End {
    $len = (Get-Item -Path "$EncryptedFile").length
    # TODO: Fix addtype
    # $size = Convert-Size -Size $len
    $size = $len
    Write-Verbose -Message "[*] Final encrypted file size: $size"
    $Result = New-Object -TypeName PSObject
    $Result | Add-Member -MemberType NoteProperty -Name Computer -Value $env:COMPUTERNAME
    $Result | Add-Member -MemberType NoteProperty -Name Key -Value $AesKey
    $Result | Add-Member -MemberType NoteProperty -Name Files -Value $EncryptedFile
    return $Result
  }
}

function Decrypt-AESFileStream 
{
  <#
      .SYNOPSIS
      Author: dd2f
      License: BSD 3-Clause
      Required Dependencies: None
      Optional Dependencies: None
      .DESCRIPTION
      Uses .NET to decrypt using file stream rather than fully in mem.
      Refrence: https://stackoverflow.com/questions/1153126/how-to-create-a-zip-archive-with-powershell
      https://msdn.microsoft.com/en-us/library/system.security.cryptography.cryptostream.cryptostream(v=vs.110).aspx
      https://gallery.technet.microsoft.com/scriptcenter/EncryptDecrypt-files-use-65e7ae5d
      .PARAMETER DestionationDirectory
      Required Destionation directory of file to be placed on disk
    
      .PARAMETER DestionationFile
      Required Destionation file name to be placed on disk
      .PARAMETER EncryptedFileName
      Required encrypted file name 
      .PARAMETER EncryptedFilePath
      Required encrypted file path
      .PARAMETER AesKey
      Required AES key to be used for decryption
    
      .NOTES
        
      Adapted from Tyler Siegrist.
      .EXAMPLE
      Decrypt-AESFileStream -DestionationDirectory 'C:\Users\admin\Desktop\' -DestionationFile 'secrets2.txt' -EncryptedFileName 'secrets.crypto' -EncryptedFilePath 'C:\Users\admin\Desktop\' -AesKey 7f/3e9cQF8yx2UNhG/Dc6XYLKYqXptK1ALB+tP3QUwA= -Verbose
        
      Computer     Key                                          Files
      --------     ---                                          -----
      RYMDEKO-TEST 7f/3e9cQF8yx2UNhG/Dc6XYLKYqXptK1ALB+tP3QUwA= C:\Users\admin\Desktop\secrets2.txt
  #>

  Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [String]
    $DestionationDirectory,

    [Parameter(Mandatory = $true, Position = 1)]
    [String]
    $DestionationFile,

    [Parameter(Mandatory = $true, Position = 2)]
    [string]
    $EncryptedFileName,

    [Parameter(Mandatory = $true, Position = 3)]
    [string]
    $EncryptedFilePath,

    [Parameter(Mandatory = $true, Position = 4)]
    [string]
    $AesKey
  )

  Begin {
    $ErrorActionPreference = 'Stop'
    $EncryptedFile = "$EncryptedFilePath$EncryptedFileName"
    $FileName = "$DestionationDirectory$DestionationFile"
    Add-Type -AssemblyName System.Security.Cryptography
    $AESProvider = Create-AesManagedObject -AesKey $AesKey
  }
    
  Process {
    # create the file stream for the encryptor
    Try
    {
      $FileStreamReader = New-Object -TypeName System.IO.FileStream -ArgumentList ($EncryptedFile, [IO.FileMode]::Open)
    }
    Catch
    {
      Write-Error -Message "[!] Unable to open file stream object: $EncryptedFile "
      exit
    }
    # create destination file
    Try
    {
      $FileStreamWriter = New-Object -TypeName System.IO.FileStream -ArgumentList ($FileName, [IO.FileMode]::Create)
    }
    Catch
    {
      Write-Error -Message "[!] Unable to open file to write: $FileStreamWriter"
      $FileStreamReader.Close()
      $FileStreamWriter.Close()
      exit
    }
    #Get IV
    try
    {
      [Byte[]]$LenIV = New-Object -TypeName Byte[] -ArgumentList 4
      $null = $FileStreamReader.Seek(0, [IO.SeekOrigin]::Begin)
      $null = $FileStreamReader.Read($LenIV,  0, 3)
      [Int]$LIV = [BitConverter]::ToInt32($LenIV,  0)
      [Byte[]]$iv = New-Object -TypeName Byte[] -ArgumentList $LIV
      $null = $FileStreamReader.Seek(4, [IO.SeekOrigin]::Begin)
      $null = $FileStreamReader.Read($iv, 0, $LIV)
      $AESProvider.IV = $iv
      Write-Verbose -Message "[*] Decrypting $EncryptedFile with an IV of $([Convert]::ToBase64String($AESProvider.IV))"
    }
    catch
    {
      Write-Error -Message '[!] Bad IV or File coruption of IV header, check back to backup data returned from encryption.'
      return
    }

    # decrypt routine
    try
    {
      $Transform = $AESProvider.CreateDecryptor()
      [Int]$Count = 0
      [Int]$BlockSizeBytes = $AESProvider.BlockSize / 8
      [Byte[]]$Data = New-Object -TypeName Byte[] -ArgumentList $BlockSizeBytes
      $CryptoStream = New-Object -TypeName System.Security.Cryptography.CryptoStream -ArgumentList ($FileStreamWriter, $Transform, [Security.Cryptography.CryptoStreamMode]::Write)
      Do
      {
        $Count = $FileStreamReader.Read($Data, 0, $BlockSizeBytes)
        $CryptoStream.Write($Data, 0, $Count)
      }
      While ($Count -gt 0)

      $CryptoStream.FlushFinalBlock()
      $CryptoStream.Close()
      $FileStreamWriter.Close()
      $FileStreamReader.Close()
      Write-Verbose -Message ('Successfully decrypted file: {0}' -f $EncryptedFile)
    }
    catch
    {
      Write-Error -Message ('Failed to decrypt ptedFile')
      $CryptoStream.Close()
      $FileStreamWriter.Close()
      $FileStreamReader.Close()
      Remove-Item -Path $FileName -Force
    } 
  }

  End {
    $len = (Get-Item -Path "$FileName").length
    # TODO: re write the add-type before using this
    # $size = Convert-Size -Size $len
    $size = $len
    Write-Verbose -Message ('[*] Final decrypted file size: {0}' -f $size)
    $Result = New-Object -TypeName PSObject
    $Result | Add-Member -MemberType NoteProperty -Name Computer -Value $env:COMPUTERNAME
    $Result | Add-Member -MemberType NoteProperty -Name Key -Value $AesKey
    $Result | Add-Member -MemberType NoteProperty -Name Files -Value $FileName
    return $Result
  }
}

# SIG # Begin signature block
  # MIID2AYJKoZIhvcNAQcCoIIDyTCCA8UCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
  # gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
  # AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUynte7isS5YkdPqfmpIkVOHxJ
  # 9R2gggH5MIIB9TCCAV6gAwIBAgIQOvUwdmWc8odDxq4ie6uLQjANBgkqhkiG9w0B
  # AQUFADAVMRMwEQYDVQQDDApDYWx2aW5kZDJmMB4XDTIzMDIxODIyMjcwMFoXDTI3
  # MDIxODAwMDAwMFowFTETMBEGA1UEAwwKQ2FsdmluZGQyZjCBnzANBgkqhkiG9w0B
  # AQEFAAOBjQAwgYkCgYEAwwIO/WIECt0pMTFvEqNrASIoybgEvUyvbG04V6tuAgYW
  # FyHi3eCZpEN40CKt4utOidbdtoRTXHag2oEc5fMZSx9SSxkAtIhEIMb6KCn42+ga
  # TuckbfY9yavMyuuhIM5Cxf+R5t+8OIcsOj32Op9c0oRhtpf2iw7vgGT2jbHnROEC
  # AwEAAaNGMEQwEwYDVR0lBAwwCgYIKwYBBQUHAwMwHQYDVR0OBBYEFGiMl9XJES+c
  # eVMnKIsZHMXWMeKgMA4GA1UdDwEB/wQEAwIHgDANBgkqhkiG9w0BAQUFAAOBgQAC
  # QbBY9VV5j74fkdyVGcFwI8TuOeABOFYYiL85KX1Gnf975DfjVbvqSfnciJypKiHL
  # jl7roGVG9ezRJADPI0hz4yD6JTUMEXMENjZFVrp/lU0d8zrz943p2ycGgDjDAUdz
  # lZ9YS/Dgcq3IIHHxxWD4awAkqQFU0VsRRbKQG3+mrzGCAUkwggFFAgEBMCkwFTET
  # MBEGA1UEAwwKQ2FsdmluZGQyZgIQOvUwdmWc8odDxq4ie6uLQjAJBgUrDgMCGgUA
  # oHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYB
  # BAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0B
  # CQQxFgQUQIdP+z6rRzRPY3ztB3gIqcYgy3swDQYJKoZIhvcNAQEBBQAEgYCABFTk
  # H9mCyLnI0M7AxjTDU4MCyfILACyXfnl4JP/bXwLLnqItT6oYM8DISy7LO79HcUEm
  # x187veApKRwiZ3cAyqWhq+dYu+pBi5vxhI5jMNULvB7Pig9yBPFDc+I/ve4Cljo/
  # 7/6p1Ff4/ef9/1RszdRaylYHHPGSL45IpnnDAA==
# SIG # End signature block
