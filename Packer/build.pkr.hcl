build {
  name    = "packer-ubuntu"
  sources = [
    "source.azure-arm.image"
  ]
  provisioner "install-python" {
    inline = [
        "sudo apt update",
        "sudo apt upgrade -y",
        "sudo apt install python3"
        ]
  }
  post-processor "output manifest" {
        output = "manifest.json"
        }
}