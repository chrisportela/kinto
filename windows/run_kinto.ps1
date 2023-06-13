$AHKEXE = "$env:ChocolateyInstall\lib\autohotkey.portable\tools\AutoHotKey.exe"
Invoke-Expression -Command "$AHKEXE $env:USERPROFILE\src\kinto\windows\kinto.ahk mac"
