# Automated Development Setup for Windows Machines
#
# This file was initially based on aaronpowell/system-init repo
# https://github.com/aaronpowell/system-init
#
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
        Install-Module -Name $ModuleName -Scope CurrentUser -Confirm $true
        Import-Module $ModuleName -Confirm $true

        Invoke-Command -ScriptBlock $PostInstall
    } else {
        Write-Host "$ModuleName was already installed, skipping"
    }
}

Install-Chocolatey

Install-FromChocolatey 'git'
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/antunesl/dev-setup/master/common/.gitconfig' -OutFile (Join-Path $env:USERPROFILE '.gitconfig')

# Fonts
Install-FromChocolatey 'firacode'
Install-FromChocolatey 'cascadiacodepl'

# Utilities
Install-FromChocolatey '7zip'
Install-FromChocolatey 'vscode-insiders'
Install-FromChocolatey 'microsoft-windows-terminal'
Install-FromChocolatey 'insomnia-rest-api-client'
Install-FromChocolatey 'linqpad'
Install-FromChocolatey 'powershell-core'
Install-FromChocolatey 'azure-data-studio'

# Browsers
Install-FromChocolatey 'firefox'
Install-FromChocolatey 'googlechrome'

# Development
Install-FromChocolatey 'dotnetcore-sdk'
Install-FromChocolatey 'azure-cli'
Install-FromChocolatey 'pulumi'
Install-FromChocolatey 'nodejs'


Install-PowerShellModule 'Posh-Git' { Add-PoshGitToProfile -AllHosts }
Install-PowerShellModule 'oh-my-posh' { }
Install-PowerShellModule 'PSReadLine' { }

Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/antunesl/dev-setup/master/windows/powershell_profile.ps1' -OutFile $PROFILE
