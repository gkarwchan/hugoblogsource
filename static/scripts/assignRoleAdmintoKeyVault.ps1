$keyVaultName = "your-keyvault-name"
$resourceGroupName = "your-resource-group"
$userPrincipalName = "user@yourdomain.com"  # or use object ID

# Get the Key Vault resource
$keyVault = Get-AzKeyVault -VaultName $keyVaultName -ResourceGroupName $resourceGroupName

# Assign the Key Vault Secrets Officer role
New-AzRoleAssignment -ObjectId (Get-AzADUser -UserPrincipalName $userPrincipalName).Id -RoleDefinitionName "Key Vault Administrator" -Scope $keyVault.ResourceId

# if Get-AzADUser is not working you can get the ObjectId directrly

Get-AzADUser

# find the ID you want to assign