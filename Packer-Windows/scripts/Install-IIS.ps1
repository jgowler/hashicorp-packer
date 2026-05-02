# Install IIS Web Server
Write-Host "Installing IIS..."
Install-WindowsFeature -Name Web-Server -IncludeManagementTools
Write-Host "IIS installed, VM rebooting..."
Restart-Computer -Force