source "azure-arm" "image" {
  client_id       = local.client_id
  client_secret   = local.client_secret
  subscription_id = local.subscription_id

  os_type  = var.os_type
  vm_size = var.vm_size

  build_resource_group_name = var.resource_group
  managed_image_resource_group_name = var.resource_group
  managed_image_name                = var.image_name

  image_publisher = var.image_publisher
  image_offer     = var.image_offer
  image_sku       = var.image_sku
  image_version   = var.image_version
}