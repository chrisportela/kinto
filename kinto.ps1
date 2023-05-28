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
    
    Invoke-WebRequest -Uri https://github.com/rbreaves/kinto/archive/refs/heads/master.zip -OutFile $env:USERPROFILE\Downloads\kinto.zip
    Expand-Archive -LiteralPath "$env:USERPROFILE\Downloads\kinto.zip" -DestinationPath "$env:USERPROFILE\Downloads" -Force
    Set-ExecutionPolicy Bypass -Scope Process -Force
    Invoke-WebRequest https://chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression
    Set-Location "$env:USERPROFILE\Downloads\kinto-master"
    Invoke-Kinto-Dependency-Check

    Copy-Item -Path ".\windows\kinto.bat" -Destination "$env:USERPROFILE\.kinto\" -Confirm
    Copy-Item -Path ".\windows\run_kinto.ps1" -Destination "$env:USERPROFILE\.kinto\" -Confirm
    New-Item -ItemType SymbolicLink -Value "$env:USERPROFILE\src\kinto\windows\run_kinto.ps1" \
        -Path "$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\STARTM~1\Programs\Startup\run_kinto.ps1"

    Invoke-Kinto
}

function Invoke-Kinto {
    param (
        [string] $keyboard_type = "mac"
    )
    Invoke-Expression -Command $AHKEXE "$env:USERPROFILE\.kinto\kinto.ahk" "$keyboard_type"
}

# TODO: Call kinto or run setup