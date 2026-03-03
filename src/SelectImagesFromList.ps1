function Invoke-SelectImagesFromList {
    Param(
        [Parameter(Mandatory = $true)]
        [string]$AppListPath, # path to the text file containing package names (one per line)

        [Parameter(Mandatory = $true)]
        [string]$DictionaryPath, # path to the XML file containing icon mappings

        [Parameter(Mandatory = $true)]
        [string]$IconBankPath, # path to the folder containing the icons on which the program will search for the icons to use

        [Parameter(Mandatory = $true)]
        [string]$DestFolder # path where processed icons will be copied with new name
    )

    # Ensure the destination directory exists
    if (-not (Test-Path $DestFolder)) { 
        New-Item -ItemType Directory -Path $DestFolder | Out-Null 
    }

    Write-Host "Starting image sorting..." -ForegroundColor Cyan

    # Load XML content and package list
    $xmlContent = Get-Content -Path $DictionaryPath -Raw
    $packages = Get-Content -Path $AppListPath
    $counter = 0

    foreach ($pkg in $packages) {
        $pkg = $pkg.Trim()
        if ([string]::IsNullOrWhiteSpace($pkg)) { continue }

        # Regex to find the drawable name associated with the package in the XML
        # Extracts the value from drawable="name"
        $pattern = "(?s)ComponentInfo\{$pkg/.*?drawable=""([^""]+)"""
        
        if ($xmlContent -match $pattern) {
            $rawName = $Matches[1]
            
            # Clean the name: remove '_dym' suffix and normalize multiple underscores
            $cleanedName = $rawName -replace "_dym", ""
            
            # Append '_foreground' as the script specifically looks for foreground icons
            $finalSearchName = $cleanedName + "_foreground"

            # Ensure no double underscores exist after appending the suffix
            while ($finalSearchName -match "__") {
                $finalSearchName = $finalSearchName -replace "__", "_"
            }

            $imageFound = $false
            
            # Try to find the image with .png or .webp extension
            foreach ($ext in @(".png", ".webp")) {
                $sourcePath = "$IconBankPath\$finalSearchName$ext"
                $destPath = "$DestFolder\$pkg$ext"
                
                if (Test-Path $sourcePath) {
                    Copy-Item $sourcePath -Destination $destPath
                    Write-Host "[OK] Found $pkg -> $finalSearchName$ext" -ForegroundColor Green
                    $counter++
                    $imageFound = $true
                    break
                }
            }

            if (-not $imageFound) {
                Write-Host "[?] NOT FOUND: $pkg" -ForegroundColor Yellow
                Write-Host "    -> Searched for: $finalSearchName.png (Base XML: $rawName)" -ForegroundColor Gray
            }
        }
        else {
            Write-Host "[-] $pkg is not in the creator's XML dictionary" -ForegroundColor DarkRed
        }
    }

    Write-Host "`nFinished! $counter icons have been sorted." -ForegroundColor Cyan
}