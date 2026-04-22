# Creating Azure VM images using Packer and Vault
## Introduction

Two Hashicorp tools will be used for this project, Packer and Vault.

### What is Packer?
Packer is a tool that lets you create identical machine images for multiple platforms from a single source template. Packer can create golden images to use in image pipelines.

### What is Vault?
Secure, store, and tightly control access to tokens, passwords, certificates, encryption keys for protecting secrets, and other sensitive data using a UI, CLI, or HTTP API.

### Objectives:
1. Create a locally hosted Hashicorp Vault VM to store confidential information.
2. Store Azure information in the Vault.
3. Install Packer.
4. Create the Packer template.
5. Initialise, Validate, Build.
