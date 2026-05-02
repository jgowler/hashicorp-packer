# Install PSWindowsUpdate
try{
    Install-WindowsUpdate -ErrorAction Stop
} catch {
    Write-Host "PSWindowsUpdate missing. Installing PSWindowsUpdate..."
    Install-Module PSWindowsUpdate
    Import-Module PSWindowsUpdate
    Install-WindowsUpdate -AcceptAll
}
Restart-Computer -Force