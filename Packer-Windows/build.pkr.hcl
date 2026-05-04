build {
  name    = "packer-windows-iis"
  sources = [
    "source.azure-arm.image"
  ]
  provisioner "powershell" {
    script = var.USOClient-Update
  }
  provisioner "powershell" {
    script = var.Disable-WindowsSearch
  }
  provisioner "powershell" {
    script = var.Install-FSLogix
  }
  post-processor "manifest" {
        output = "manifest.json"
        }
}