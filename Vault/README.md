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

## Create a user
Now that access is granted to the Vault the first thing I will do is create a user account to access instead of using the root token each time. This can be done with the following steps:

1. From the Dashboard select `Access Control`.
2. Select `Authentication Methods`
3. `+ Enable a new method`
4. Select `Userpass`
5. Select `Enable method`
6. Go back to `Authentication methods` and select the new entry `userpass\`
7. Select `Create user`
8. Choose a username and password then click `Save`.

## Create ACL policy
With the user account created it will need to be granted permissions to use the Vault to access secrets. This is done with the creation and assignement of ACL policies:

1. Dashboard > `Access Control`
2. Select `ACL policies`
3. Select `Create a policy`
4. Give the policy a name ("secrets-access" for example).
5. In the `Rule` field enter the name of the policy with "/+/creds", e.g. `secrets-access/+/creds`.
6. In the `Capabilities` field you select the permissions for this policy. I selected `create, list, update, read`.
7. Click `Create policy`.

The policy will then be displayed in `HCL` format. You can store this in version control if required.

## Grant the new user permissions to secrets
Now the ACL policy needs to be applied ot the user account:

1. Select the newly created user from `Authentication methods`.
2. Select `Edit user`
3. Expand `Tokens`
4. Under ` Generated Token's Policies` type in the name of the new policy ("secrets-access") and click `Add`.
5. Click `Save`.

Now that the user is created and has permissions to the Vault log out of the root account and log back into the Vault using the `userpass` method and the credentials for the new account.