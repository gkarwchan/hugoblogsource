$keyvaultName = "mykeyvault"
$secrets = get-azkeyvaultsecret -vaultName $keyvaultname
foreach ($secret in $secrets) {
  $secretValue = (get-azkeyvaultsecret -vaultname $kevaultname -name $secret $secret.name).SecretValue | ConvertFrom-SecureString -AsPlainText
  write-host "secret: $($secret.name) : $($secretValue)"
  }