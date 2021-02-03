# Automated Development Setup for Windows Machines
#
# This file was initially based on aaronpowell/system-init repo
# https://github.com/aaronpowell/system-init
#

# Get the base URI path from the ScriptToCall value
$bstrappackage = "-bootstrapPackage"
$helperUri = $Boxstarter['ScriptToCall']
$strpos = $helperUri.IndexOf($bstrappackage)
$helperUri = $helperUri.Substring($strpos + $bstrappackage.Length)
$helperUri = $helperUri.TrimStart("'", " ")
$helperUri = $helperUri.TrimEnd("'", " ")
$helperUri = $helperUri.Substring(0, $helperUri.LastIndexOf("/"))
$helperUri += "/Scripts"
write-host "helper script base URI is $helperUri"

function Execute-Script {
    Param ([string]$script)
    write-host "executing $helperUri/$script ..."
	# iex ((new-object net.webclient).DownloadString("$helperUri/$script"))
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

    choco install $PackageName --yes
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

# Update Execution Policy
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Confirm

# Update PowershellGet
Install-Module PowerShellGet -Scope CurrentUser -Force -AllowClobber

# Chocolatey
Install-Chocolatey

# Run Windows Scripts
Execute-Script 'WindowsDevMode.ps1'





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
Install-FromChocolatey 'spotify --ignore-checksums'


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

