source "azure-arm" "image" {
  client_id       = var.client_id
  client_secret   = var.client_secret
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id

  location = var.location
  os_type  = "Linux"

  managed_image_resource_group_name = var.resource_group
  managed_image_name                = var.image_name

  image_publisher = "Canonical"
  image_offer     = "0001-com-ubuntu-server-focal"
  image_sku       = "20_04-lts"
  image_version   = "latest"
}