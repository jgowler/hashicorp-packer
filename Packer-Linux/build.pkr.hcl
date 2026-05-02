build {
  name    = "packer-ubuntu"
  sources = [
    "source.azure-arm.image"
  ]
  provisioner "shell" {
    inline = [
        "sudo apt update",
        "sudo apt upgrade -y",
        "sudo apt install python3"
        ]
  }
  post-processor "manifest" {
        output = "manifest.json"
        }
}