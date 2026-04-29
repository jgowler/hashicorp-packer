# 3. Install Packer

Documentation:
```
https://developer.hashicorp.com/packer/tutorials/docker-get-started/get-started-install-cli
```
The above link is the official documentation for installing Hashicorp Packer.

# 4. Create the Packer template

## Create the Variables file

The variables file will be used to store information to be injected into the main file during the build, such as the resource group and location:
```
variable "resource_group" {
    type = string
    default = "hashicorp-packer"
}
variable "location" {
    type = string
    default = "UK South"
}
```
## Create the Local file

The function `vault()` will be used to get the `client_id` from the `kv/azure` secrets engine. All of the secret information stored previously in Vault will be accessed in the same way.

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
  image_offer     = "0001-com-ubuntu-server-focal-daily"
  image_sku       = "20_04-daily-lts-gen2"
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

Once validated the `VAULT_ADDR` and `VAULT_TOKEN` environment variables will be required:
```
export VAULT_ADDR=https://<vault ip address>:8200
export VAULT_TOKEN=<insert token here>
```
Last thing to do here is build:
`packer build .`

Packer will now build the resources needed to create the image as specified.

# Observations:

- The defaukt machine size was not available at the time of building. `var.vm_size` was used to specify one available.
- `build_resource_group_name` was used as I wanted to use a resource group that already existsed.
- Because `build_resource_group_name` was used I needed to remove the `location` values from `Sources`.
- The progress of installing Python was viewable from the console, no need to assume if it is working or not.
- After the build was successful more values were set in the variables file and variables used in the sources file. This will help smplify making changes and using this as a template for future builds.
- Using AZ CLI to query avilable images was helpful as `--location` helped to check what was avilable in my location.
- Once the `VAULT_ADDR` and `VAULT_TOKEN` environment variables were set the `locals` file helped with accessing Vault using the `vault()` function.
- The hardest part was ensuring Packer could access the secrets in Vault. It is always best to double check if the secrets engine is using `v1` or `v2`
- Always double check sensitive information is protected when injected using `variables` or `locals` by adding `sensitive = true` to the block.
- I experienced issues with TLS when trying to connect using HTTPS. The attached guide to set a new key pair was helpful to resolve this (Vault\VaultCert.md).
- Because `vault()` was used no sensitive data was included. Access to the Vault for Packer was allowed using environment variables on the machine using `export`.