# 1. Create a locally hosted Hashicorp Vault VM to store confidential information.

Documentation to install Vault can be found here: https://developer.hashicorp.com/vault/install
---

For this step I will install Vault on Ubuntu Server 24.04.4 LTS.

```
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vault
```

With Vault installed on the server the service is Enabled but it is not running. STrat the service using the following:

```
systemctl start vault.service
```
Then access the UI using the Vault IP address on port 8200. You will then be asked about the initial set of root keys. For a Production environment you may want to have a few of these Shares.

The Threshold is the minimum number of shares that are required to recover, so if you select 7 shares you may want a threshold of between 3 or 4, as an example.

After the Vaukt has been initialised you will see this message:

```
Please securely distribute the keys below. When the Vault is re-sealed, restarted, or stopped, you must provide at least 3 of these keys to unseal it again. Vault does not store the root key. Without at least 3 keys, your Vault will remain permanently sealed. 
```

The next step will require you to use the keys from the previous step to log in. Once this has been done the `Sign in to Vault` screen will ask how you would like to sign in. For this I will select `Token` and use the initial root token.

