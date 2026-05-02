build {
  name    = "packer-windows-iis"
  sources = [
    "source.azure-arm.image"
  ]
  provisioner "powershell" {
    script = var.Install-WindowsUpdate
  }
  provisioner "powershell" {
    script = var.Install-IIS
  }
  post-processor "manifest" {
        output = "manifest.json"
        }
}