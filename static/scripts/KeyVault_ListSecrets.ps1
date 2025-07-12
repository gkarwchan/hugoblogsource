$keyvaultName = "gk-ai-keys"
$secrets = Get-AzKeyVaultSecret -vaultName $keyvaultname
foreach ($secret in $secrets) {
  $secretValue = (Get-AzKeyVaultSecret -VaultName $keyvaultName -Name $secret.Name).SecretValue | ConvertFrom-SecureString -AsPlainText
  Write-Host "$($secret.Name) : $($secretValue)"
}
