---
title: Use Azure Key Vault to retrieve secured parameters during  Azure deployment.
date: 2023-02-04T20:42:03-07:00
tags: ["azure", "ci/cd", "security"]
---

You have an ARM template to deploy, and you need to pass secure parameters. Instead of storing secure values in the parameter file, you can just retrieve these values from Key Vault.

To be able to access the key vault by the resource manager you need to change access policy to allow "Azure Resource Manager for template deployment", as shown here.

![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/e693x90rrx04ul7bpd5e.jpg)

Or you can do it from Powershell:

```powershell
// to update an existing key vault
Set-AzKeyVaultAccessPolicy -VaultName MyVaultName -EnabledForTemplateDeployment

// to create a new key vault with this feature enabled
New-AzKeyVault `
  -VaultName MyVaultName `
  -resourceGroupName myresourcegroup `
  -Location centralus `
  -EnabledForTemplateDeployment
```

## How to use it?

in the deployment parameter file specify the location of the secured string to be the `keyvault` as follows:

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "location": {
            "value": "eastus"
        },

        "adminUsername": {
            "value": "companyAdmin"
        },
        "adminPassword": {
            "reference": {
        "keyVault": {
          "id": "/subscriptions/<subscription-id>/resourceGroups/<rg-name>/providers/Microsoft.KeyVault/vaults/MyVaultName"
        },
        "secretName": <the name of the secret>
      }
        }
    }
}

```
Permissions to run deployments:

The beauty of this feature is the user who is doing deployment doesn't need to have access to the secrets, even read access. Just need a special permission called deploy permission, or more specifically this permission
```
Microsoft.keyVault/Vaults/deploy/action
```
To assign this permission to the user, it is easier if we create a custom role with this permission and then assign this role to any user want to deploy.  
First we create a json to represent the definition of the custom role:

```json
{
  "Name": "TemplateDeploymentForResourceManagerRole",
  "IsCustom": true,
  "Description": "Lets you deploy a resource manager template with the access to the secrets in the Key Vault.",
  "Actions": [
    "Microsoft.KeyVault/vaults/deploy/action"
  ],
  "NotActions": [],
  "DataActions": [],
  "NotDataActions": [],
  "AssignableScopes": [
    "/subscriptions/<your subscription id>"
  ]
}
```

And then create the role and assign it to the user.  
This powershell script does this:  

```powershell
New-AzRoleDefinition -InputFile "<path-to-role-file>"
New-AzRoleAssignment `
  -ResourceGroupName ExampleGroup `
  -RoleDefinitionName "TemplateDeploymentForResourceManagerRole" `
  -SignInName <user-principal-name>
```
