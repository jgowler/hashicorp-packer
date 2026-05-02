# Install IIS Web Server
Install-WindowsFeature -Name Web-Server -IncludeManagementTools
Restart-Computer -Force