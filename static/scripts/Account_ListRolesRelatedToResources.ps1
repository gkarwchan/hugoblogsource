Get-AzRoleDefinition | Where-Object {$_.Name -like "*Key Vault*"} | Select-Object Name, Description, Id
