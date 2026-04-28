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

After the Vault has been initialised you will see this message:

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
4. Give the policy a name ("azure-secrets" for example).
5. In the `Rule` field enter the name of the policy with "*", e.g. `azure/*` (for testing purposes I will grant the user access to everything in this engine).
6. In the `Capabilities` field you select the permissions for this policy. I selected `list, read`.
7. Click `Create policy`.

The policy will then be displayed in `HCL` format. You can store this in version control if required.

## Grant the new user permissions to secrets

Now the ACL policy needs to be applied ot the user account:

1. Select the newly created user from `Authentication methods`.
2. Select `Edit user`
3. Expand `Tokens`
4. Under ` Generated Token's Policies` type in the name of the new policy ("azure-secrets") and click `Add`.
5. Click `Save`.

Now that the user is created and has permissions to the Vault log out of the root account and log back into the Vault using the `userpass` method and the credentials for the new account.

# 2. Store Azure information in the Vault.

To store credentials in the Vault a `Secret engine` must be created:
```
"Secrets engines in Vault securely manage, store, and dynamically generate secrets, certificates, and encryption keys."
```

1. Dashboard > `Secrets`
2. Select `+ Enable a Secret engine`
3. Select `KV`.
4. For the `Plugin registration type` I will be using the `Built-in plugin`:
```
Built-in plugin

"Preregistered plugins shipped with Vault. The plugin version is tied to your Vault version and cannot be specified."
```
5. In `Path` this can be left as `kv`.
6. For testing, click `Enable engine`.
7. You will then be presented with an empty `Secrets` screen.
8. Select `+ Create secret`.
9. In the `Path for this secret` field select `azure`.
10. Add in the Key Value pairs in the `Secret data` fields below, such as client_id and its value.
11. Click Save when completed.

To access the secrets in the secrets engine created we will need the new user's `token`. This can be done either by CLI or by GUI. For testing I will get the token from the GUI:

```
GUI:

1. Log into the GUI using the new user account
2. From the top-right corner click the User button.
3. Select Copy token.
```
```
CLI:
NOTE: Ensure 'VAULT_ADDR' is the address of vault, such as 'https://127.0.0.1:8200'. To set a new cert key pair see 'VaultCert.md'

vault login -method=userpass username=<user create earlier>
- Enter the password for the account and you should then be able to see the details of this account on screen.
```

Next, create the token using the following command:
```
vault token create -policy=azure-secrets -ttl=10m
```

At this stage you will see the following error:

```
Error creating token: Error making API request.

URL: POST https://127.0.0.1:8200/v1/auth/token/create
Code: 403. Errors:

* 1 error occurred:
        * permission denied
```

To resolve this, either use an account which has authorisation to create tokens or grant the user account the permissions to do this:

1. Dashboard > `Access Control`
2. Select `ACL policies`
3. Select `Create a policy`
4. Give the policy a name ("token-creator" for example).
5. In the `Rule` field enter the path seen in the error message (auth/token/create)
6. In the `Capabilities` field `create, update`.
7. Click `Create policy`.

Then assign this policy to the user account the same way as earlier and they will then be authorised to create tokens.
Once this authorisation issue is resolved log out of the Vault from CLI:
```
vault token revoke -self
```
Then sign back in:
```
vault login -method=userpass username=<USERNAME>
```
Then run the token creation again:
```
vault token create -policy=azure-secrets -ttl=10m
```
The token information will be presented on screen. You can test accessing the secret using the token using the following:

```
export VAULT_TOKEN=<insert token here>
vault kv get kv/azure
```

You will then see the 

I have select the TTL to 10 minutes for testing purposes. This token can now be used by Packer to access the Key-Value pairs in `kv/azure` to authenticate to Azure using a service principal.