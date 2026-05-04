# Creating Windows images vs Linux images

When creating a Windows image a few things need ot be set differently compared to creating Linux images. These include:

1. Connection method
2. Provisioning method
3. Updates
4. Sysprep
5. Logging

## 1. Connection method

In Linux the provisioning during the build is done over `SSH` but with Windows this is instead done using `WinRM`.

TO use `WinRM` this connection method must be specified in the `sources` block. Here is an example block:

```
communicator = "winrm"                      # Connection method
winrm_username = "Packer"                   # Username Packer will use to connect
winrm_password  = var.WinRM-Passoword       # Temporary admin password Packer uses to log onto the VM
winrm_timeout = "10m"                       # Specify time before timeout on attempt to connect
winrm_use_ssl = true                        # Packer will use HTTPS instead of HTTP to connnect to Windows VM
winrm_insecure = true                       # Use HTTPS but will not check if cert is valid
```

A note on `winrm_insecure = true`; the traffic to the VM is still encrypted, along wiht the credentials used and the scripts run. During the build process an Azure Key Vault is made temporarily to host the certificate injected into the VM which will become the image. This allows Packer to connect using HTTPS and will be removed once the build is completed.

## 2. Provisioning method

Linux uses `Shell` to run any scripts required, whereas Windows can use `powershell` and `windows-shell`. In my exmaple I opted to create `powershell` scripts to be run on the VM from the `scripts` directory in this repo, then referencing their location in a variable to be passed to the build. This way, I can store multiple scripts and add whichever is needed at the time of build easily.

For more information on `Provisionser` review the documentation:
https://developer.hashicorp.com/packer/docs/provisioners

## 3. Updates

On an Ubuntu Linux machine, for example, the software packages can be updated using `sudo apt update` and the newest versions of all updated packages can be downloaded and installed using `sudo apt upgrade -y`. Combining the two into an inline shell command using a provisioner this process can be done using a single line: `sudo apt update && sudo apt upgrade -y`.

On a Windows machine it is not as straight forward. Depending on your preference this can be done using `powershell`, or possibly `USOCLient` through the `powershell` provisioner. An example of `USOClient` be found in the `scripts` folder.

## 4. Sysprep

Linux machines do not require a form of `Sysprep` whereas a Windows VM will need to run this before being converted into an image. If you clone a Windows machine without Sysprep, you could face the following issue:
```
duplicate SIDs
broken domain joins
broken Windows Update
certificate conflicts
activation issue
```
These are some examples of problems that can arise when a Windows machine is not prepped before image creation. Packer will tell Windows to run `Sysprep` before image creation, eliminating these potential issues.

## 5. Logging

When creating a Linux VM the log stream will be made available through the SSH connection, making monitoring of the build much more transparent. The Windows machine, however, will not display as much information as stdout and stderr are buffered and output in chunks. This is not ideal for interactive use.

Should logging be required it may be best to script in a log file to store output from the provisioning should this be required.