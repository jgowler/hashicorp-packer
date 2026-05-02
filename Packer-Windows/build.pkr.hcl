build {
  name    = "packer-windows-iis"
  sources = [
    "source.azure-arm.image"
  ]
  provisioner "file" {
    source = "../scripts/Install-PSWindowsUpdate.ps1"
    destination = "C:/temp/Install-PSWindowsUpdate.ps1"
  }
  provisioner "file" {
    source = "../scripts/Install-IIS.ps1"
    destination = "C:/temp/Install-IIS.ps1"
  }
  provisioner "shell" {
    inline = ["powershell.exe C:/temp/Install-PSWindowsUpdate.ps1"]
  }
  provisioner "shell" {
    inline = ["powershell.exe C:/temp/Install-IIS.ps1"]
  }
  post-processor "manifest" {
        output = "manifest.json"
        }
}