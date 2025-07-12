Get-InstalledModule | Select-Object Name, @{Name='InstalledVersion';Expression={$_.Version}}, @{Name='AvailableVersion';Expression={(Find-Module -Name $_.Name -Repository PSGallery).Version}} | Where-Object {$_.AvailableVersion -gt $_.InstalledVersion}

// to update them add `| Update-Module -Force -AccpetLicense` at the end
