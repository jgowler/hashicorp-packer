# Variables
$downloadURL = "https://aka.ms/fslogix_download"
$tempPath = "C:\Windows\Temp\FSLogix"
$zipPath = "$tempPath\fslogix.zip"
$extractPath = "$tempPath\Extracted"
$Installer = "$extractPath\x64\Release\FSLogixAppsSetup.exe"

# Create directory
Write-Host "Creating temp directory..."
New-Item -Path $tempPath -ItemType Directory -Force | Out-Null

# Download FSLogix
Write-Host "Downloading FSLogix..."
Invoke-WebRequest -Uri $downloadURL -OutFile $zipPath

# Extract archive
Write-Host "Extracting FSLogix..."
Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force

# Validate
if (!(Test-Path $Installer)) {
    throw "FSLogix installer not found at: $Installer"
}

# Install silently
Write-Host "Installing FSLogix..."
Start-Process -FilePath $Installer -ArgumentList "/install /quiet /norestart" -Wait -NoNewWindow

# Validate installation
$installPath = "C:\Program Files\FSLogix\Apps\frxsvc.exe"
if (!(Test-Path $installPath)) {
    throw "FSLogix installation failed - executable not found"
}

# Installation confirmation
Write-Host "FSLogix installed successfully."

# Base configuration
$RegPath = "HKLM:\SOFTWARE\FSLogix\Profiles"

Write-Host "Configuring FSLogix base registry..."
New-Item -Path $RegPath -Force | Out-Null

New-ItemProperty -Path $RegPath -Name "Enabled" -Value 1 -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path $RegPath -Name "DeleteLocalProfileWhenVHDShouldApply" -Value 1 -PropertyType DWORD -Force | Out-Null

# Cleanup
Write-Host "Cleaning up..."
Remove-Item -Path $tempPath -Recurse -Force

Write-Host "FSLogix setup complete."