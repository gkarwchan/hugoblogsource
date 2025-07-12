$keyvaultName = "ai-tutorial-gk-keyvault"
$secretName = Read-Host -Prompt "Enter secret name"

# Validate secret name against the expected pattern
if ($secretName -notmatch '^[0-9a-zA-Z-]+$') {
    Write-Host "Error: Secret name must only contain alphanumeric characters and hyphens." -ForegroundColor Red
    exit
}

$secureSecretValue = Read-Host -Prompt "Enter secret value"
$secureValue = ConvertTo-SecureString -String $secureSecretValue -AsPlainText -Force
Set-AzKeyVaultSecret -VaultName $keyvaultName -Name $secretName -SecretValue $secureValue