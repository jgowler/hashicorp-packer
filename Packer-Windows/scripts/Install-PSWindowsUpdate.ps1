# Install PSWindowsUpdate
try{
    Install-WindowsUpdate -ErrorAction Stop
    Write-Host "Windows updated using PSWindowsUpdate."
} catch {
    Write-Host "PSWindowsUpdate missing. Installing PSWindowsUpdate..."
    Install-Module PSWindowsUpdate
    Write-Host "Importing PSWindowsUpdate module..."
    Import-Module PSWindowsUpdate
    Write-Host "PSWindowsUpdate installed."
    Write-Host "Installing Windows updates..."
    Install-WindowsUpdate -AcceptAll
}
Write-Host "Restarting VM..."
Restart-Computer -Force