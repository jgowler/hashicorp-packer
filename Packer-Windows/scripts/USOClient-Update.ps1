Write-Host "Scanning for updates..."
UsoClient StartScan

Write-Host "Downloading updates..."
UsoClient StartDownload

Write-Host "Installing updates..."
UsoClient StartInstall

Write-Host "Rebooting..."
Restart-Computer -Force