# Automated Development Setup for Windows Machines
#
# This file was initially based on aaronpowell/system-init repo
# https://github.com/aaronpowell/system-init
#


#--- Enable developer mode on the system ---
function Enable-DevMode {
    Set-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\AppModelUnlock -Name AllowDevelopmentWithoutDevLicense -Value 1
}

function Set-ExplorerSettings {
	#--- Configuring Windows properties ---
	#--- Windows Features ---
	# Show hidden files, Show protected OS files, Show file extensions
	Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -EnableShowProtectedOSFiles -EnableShowFileExtensions

	#--- File Explorer Settings ---
	# will expand explorer to the actual folder you're in
	Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name NavPaneExpandToCurrentFolder -Value 1
	#adds things back in your left pane like recycle bin
	Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name NavPaneShowAllFolders -Value 1
	#opens PC to This PC, not quick access
	Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name LaunchTo -Value 1
	#taskbar where window is open for multi-monitor
	Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name MMTaskbarMode -Value 2
}

#--- Uninstall unnecessary applications that come with Windows out of the box ---
$applicationList = @(
	"Microsoft.BingFinance"
	"Microsoft.3DBuilder"
	"Microsoft.BingFinance"
	"Microsoft.BingNews"
	"Microsoft.BingSports"
	"Microsoft.BingWeather"
	"Microsoft.CommsPhone"
	"Microsoft.Getstarted"
	"Microsoft.WindowsMaps"
	"*MarchofEmpires*"
	"Microsoft.GetHelp"
	"Microsoft.Messaging"
	"*Minecraft*"
	"Microsoft.MicrosoftOfficeHub"
	"Microsoft.OneConnect"
	"Microsoft.WindowsPhone"
	"Microsoft.WindowsSoundRecorder"
	"*Solitaire*"
	"Microsoft.MicrosoftStickyNotes"
	"Microsoft.Office.Sway"
	"Microsoft.XboxApp"
	"Microsoft.XboxIdentityProvider"
	"Microsoft.ZuneMusic"
	"Microsoft.ZuneVideo"
	"Microsoft.NetworkSpeedTest"
	"Microsoft.FreshPaint"
	"Microsoft.Print3D"
	"Microsoft.SkypeApp"
	"*Autodesk*"
	"*BubbleWitch*"
        "king.com*"
        "G5*"
	"*Dell*"
	"*Facebook*"
	"*Keeper*"
	"*Netflix*"
	"*Twitter*"
	"*Plex*"
	"*.Duolingo-LearnLanguagesforFree"
	"*.EclipseManager"
	"ActiproSoftwareLLC.562882FEEB491" # Code Writer
	"*.AdobePhotoshopExpress"
);
function Clean-PreInstalled-Apps {
    Write-Host "Uninstall some applications that come with Windows out of the box" -ForegroundColor "Yellow"
	
    foreach ($appName in $applicationList) {
        Write-Output "Trying to remove $appName"
	Get-AppxPackage $appName -AllUsers | Remove-AppxPackage
	Get-AppXProvisionedPackage -Online | Where DisplayName -like $appName | Remove-AppxProvisionedPackage -Online
    }
}

function Install-Chocolatey {
    Set-ExecutionPolicy Bypass -Scope Process -Force;
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

function Install-FromChocolatey {
    param(
        [string]
        [Parameter(Mandatory = $true)]
        $PackageName
    )
    param(
        [switch]
        $PreRelease
    )

    if ($PreRelease) 
    {
        choco install $PackageName --pre --yes
    }
    else
    {
        choco install $PackageName --yes
    }
}

function Install-PowerShellModule {
    param(
        [string]
        [Parameter(Mandatory = $true)]
        $ModuleName,

        [ScriptBlock]
        [Parameter(Mandatory = $true)]
        $PostInstall = {}
    )

    if (!(Get-Command -Name $ModuleName -ErrorAction SilentlyContinue)) {
        Write-Host "Installing $ModuleName"
        Install-Module -Name $ModuleName -Scope CurrentUser -Confirm:$False
        Import-Module $ModuleName -Confirm:$False

        Invoke-Command -ScriptBlock $PostInstall
    } else {
        Write-Host "$ModuleName was already installed, skipping"
    }
}

# // ---------------------------------------------------------------


# Update Execution Policy
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Confirm

# Update PowershellGet
Install-Module PowerShellGet -Scope CurrentUser -Force -AllowClobber

# Chocolatey
Install-Chocolatey

# Run Windows Scripts
Clean-PreInstalled-Apps
Enable-DevMode
Set-ExplorerSettings



# Fonts
Install-FromChocolatey 'firacode'
Install-FromChocolatey 'cascadiacodepl'


# Browsers
Install-FromChocolatey 'microsoft-edge-insider-dev'
Install-FromChocolatey 'firefox'
Install-FromChocolatey 'googlechrome'


# Generic Tools
Install-FromChocolatey '7zip'
Install-FromChocolatey 'vlc'
Install-FromChocolatey '1password'
Install-FromChocolatey 'vscode-insiders'
Install-FromChocolatey 'powertoys'
Install-FromChocolatey 'screentogif'
Install-FromChocolatey 'microsoft-windows-terminal --pre'


# Dev Tools
Install-FromChocolatey 'insomnia-rest-api-client'
Install-FromChocolatey 'azure-data-studio'
Install-FromChocolatey 'gitkraken'
## git
Install-FromChocolatey 'git'
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/antunesl/dev-setup/master/common/.gitconfig' -OutFile (Join-Path $env:USERPROFILE '.gitconfig')


# Messaging
Install-FromChocolatey 'discord'
Install-FromChocolatey 'microsoft-teams'


# Audio
Install-FromChocolatey 'spotify'


# Development
Install-FromChocolatey 'dotnetcore-sdk'
Install-FromChocolatey 'azure-cli'
Install-FromChocolatey 'pulumi'
Install-FromChocolatey 'nodejs-lts'


# Powershell Customization
Install-Module posh-git -Scope CurrentUser -AllowPrerelease -Force
Install-Module oh-my-posh -Scope CurrentUser -AllowPrerelease
Install-Module PSReadLine -AllowPrerelease -Force
## Set powershell profile
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/antunesl/dev-setup/master/windows/powershell_profile.ps1' -OutFile $PROFILE

