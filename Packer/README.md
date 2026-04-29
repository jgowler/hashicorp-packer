# 3. Install Packer

Documentation:
```
https://developer.hashicorp.com/packer/tutorials/docker-get-started/get-started-install-cli
```
The above link is the official documentation for installing Hashicorp Packer.

# 4. Create the Packer template

## Create the Variables file

The variables used will be stored in their own file as to segregate them reliably from the main files which may be uploaded to version control. The file is `variables.pkrvars.hcl`.

In the file variables will be added in to get the information from Vault to authenticate to Azure. they will look similar to this:
```
variable "client_id" {
    type = string
    default = vault("kv/azure", "client_id")
    sensitive = true
}
```
Here, the variable will use the `vault()` method to get the `client_id` from the `kv/azure` secrets engine. All of the secret information stored previously in Vault will be accessed in the same way. I will be renaming `variables.pkrvars.hcl` to `variables.auto.pkrvars.hcl` to ensure Packer will load these values automatically.

NOTE: The `VAULT_ADDR` and `VAULT_TOKEN` can not be injected using the variables file as these are required for Packer to connect. Use the following to to set these (Linux):

```
export VAULT_ADDR=https://<vault ip address>:8200
export VAULT_TOKEN=<insert token here>
```

## Create the plugins file

Not necessary for most cases but I prefer to seperate parts of the script. Create the file `plugins.pkr.hcl`, this will be used to specify the `plugins` used in the project:

Packer will seek out any files required, such as `plugins.pkr.hcl` as long as they contain the `*.pkr.hcl` suffix.

As I am using Packer to create a VM image in Azure I will need the Azure plugin. Plugins can be found here:
https://developer.hashicorp.com/packer/integrations

The plugin will look like this:

```
packer {
  required_plugins {
    azure = {
      source  = "github.com/hashicorp/azure"
      version = "~> 2"
    }
  }
}
```
This was taken directly from the link above. For now this is all I will require to run this.

## Create the Sources file

All components in Packer can be broken down into its own file, and `Sources` is no different. Sources will define how Packer will build the image, in this case using Azure ARM:

```
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
```
This block will pull information from the `variable.pkr.hcl` file to inject into the script.

## Create the Build file

The Build block use the Sources block to build the image. Build blocks can contain `provisioners` to run code inside he machine to install software or make other changes.

```
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
```
The sources block in the build file is the information in the sources file:

```
- sources.pkr.hcl

source "azure-arm" "image" {
  client_id       = var.client_id
  client_secret   = var.client_secret
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}
...

```
The `provisioner` block will tell Packer to run some code using `shell` during the process to update the package index, upgrade the installed packages, then install python3.

`inline` is used here but a `file` could also be transfered over to the image. More information on this can be found here:
https://developer.hashicorp.com/packer/docs/provisioners


A `Post-Processor` vlock will be added to output a `manifest.json` file used to describe the image created. This can be used for version tracking, as an example.

# 5. Initialise, Validate, Build.

First Packer needs to initialise in the folder containing the files vcreate previously:
`packer init .`
Packer will then download the required plugins.
Next, validate the build:
`packer validate .`