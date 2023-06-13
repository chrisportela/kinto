$AHKEXE = "$env:ChocolateyInstall\lib\autohotkey.portable\tools\AutoHotKey.exe"

function Invoke-Kinto-Dependency-Check {
    # Dependency 
    param ()
    
    if (-not(Get-Command "choco" -errorAction SilentlyContinue)) {
        Write-Output "Seems Chocolatey is not installed, installing now"
        Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
        RefreshEnv.cmd
    }
    else {
        Write-Output "Chocolatey is already installed"
    }

    if (-not(test-path $AHKEXE)) {
        choco.exe install autohotkey.portable
    }
    else {
        Write-Output "Autohotkey is already installed"
    }
}

function Invoke-Kinto-Setup {
    param (
        [string] $keyboard
    )
    
    # Invoke-WebRequest -Uri https://github.com/rbreaves/kinto/archive/refs/heads/master.zip -OutFile $env:USERPROFILE\Downloads\kinto.zip
    # Expand-Archive -LiteralPath "$env:USERPROFILE\Downloads\kinto.zip" -DestinationPath "$env:USERPROFILE\Downloads" -Force
    # Set-ExecutionPolicy Bypass -Scope Process -Force
    # Invoke-WebRequest https://chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression
    Set-Location "$env:USERPROFILE\src\kinto"
    Invoke-Kinto-Dependency-Check

    Copy-Item -Path ".\windows\kinto.ahk" -Destination "$env:USERPROFILE\.kinto\" -Confirm
    Copy-Item -Path ".\windows\run_kinto.ps1" -Destination "$env:USERPROFILE\.kinto\" -Confirm

    # Create setup shortcut to launch kinto
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\STARTM~1\Programs\Startup\run_kinto.ps1")
    $Shortcut.TargetPath = "C:\Program Files\PowerShell\7\pwsh.exe"
    $Shortcut.Arguments = "-Command "
    $Shortcut.StartIn = "$env:USERPROFILE\.kinto\"
    $Shortcut.Save()

    Invoke-Kinto
}

function Invoke-Kinto {
    param (
        [string] $keyboard_type = "mac"
    )
    Invoke-Expression -Command $AHKEXE "$env:USERPROFILE\.kinto\kinto.ahk" "$keyboard_type"
}

# TODO: Call kinto or run setup