Get-Module -ListAvailable | 
    Group-Object -Property Name | 
    Where-Object { $_.Count -gt 1 } | 
    ForEach-Object {
        # Sort by version descending to get newest first
        $sortedModules = $_.Group | Sort-Object Version -Descending
        $newestModule = $sortedModules[0]
        $olderModules = $sortedModules[1..($sortedModules.Count - 1)]
        
        Write-Host "Module: $($_.Name)" -ForegroundColor Green
    }