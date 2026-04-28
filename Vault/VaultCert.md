# TLS Setup Guide for HashiCorp Vault

This guide explains how to generate a TLS certificate and private key, and configure HashiCorp Vault to use them for HTTPS access.

---

## Overview

To enable TLS in Vault, you need:

- A private key file (`.key`)
- A certificate file (`.crt`) that includes valid Subject Alternative Names (SANs)

Both files must match and be trusted by clients connecting to Vault.

---

## 1. Create a Certificate Configuration File

Create a file called `san.cnf`:

```
[req]
default_bits = 2048
prompt = no
distinguished_name = dn
x509_extensions = v3_req

[dn]
CN = localhost

[v3_req]
subjectAltName = @alt_names

[alt_names]
DNS.1 = localhost
IP.1 = 127.0.0.1
```

## 2. Generate Key and Certificate

```
openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout tls.key \
  -out tls.crt \
  -config san.cnf
```

Optional: Verify Cert SANs

```
openssl x509 -in tls.crt -noout -text | grep -A1 "Subject Alternative Name"
```

Expected output:
DNS:localhost, IP Address:127.0.0.1

## 3. Install new files to Vault

```
sudo cp tls.crt /opt/vault/tls/tls.crt
sudo cp tls.key /opt/vault/tls/tls.key
```

## 4. Set correct permissions

```
sudo chown vault:vault /opt/vault/tls/tls.key
sudo chmod 600 /opt/vault/tls/tls.key
sudo chmod 644 /opt/vault/tls/tls.crt
```

## 5. Configure Vault HTTPS Listener

```
/etc/vault.d/vault.hcl

listener "tcp" {
  address       = "0.0.0.0:8200"
  tls_cert_file = "/opt/vault/tls/tls.crt"
  tls_key_file  = "/opt/vault/tls/tls.key"
}
```

## 6. Restart Vault

```
sudo systemctl restart vault
```

## 7. Trust the new Cert

```
Add to system trust store:

sudo cp /opt/vault/tls/tls.crt /usr/local/share/ca-certificates/vault.crt
sudo update-ca-certificates
```

## 8. Set VAULT_ADDR

```
export VAULT_ADDR=https://127.0.0.1:8200

alternatively, set in .bashrc:
add "alias VAULT_ADDR='https://127.0.0.1:8200'"
```
