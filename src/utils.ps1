function Get-MagickPath {
    # get the magick path from PATH

    $finalMagickPath = $null

    # try to get the magick path from PATH
    $standardCommands = @("magick", "magick.exe")
    foreach ($cmd in $standardCommands) {
        if (Get-Command $cmd -ErrorAction SilentlyContinue) {
            $finalMagickPath = (Get-Command $cmd).Source
            if (-not $finalMagickPath) { $finalMagickPath = $cmd }
            return $finalMagickPath
        }
    }

    # search through EVERY folder in the PATH for '*magick*.exe'
    $pathFolders = $env:PATH -split ';'
    foreach ($folder in $pathFolders) {
        if (Test-Path $folder) {
            $match = Get-ChildItem -Path $folder -Filter "*magick*.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($match) {
                return $match.FullName
            }
        }
    }

    # local fallback: check the local project folder
    $localFallback = Join-Path $PSScriptRoot "magick\magick.exe"
    if (Test-Path $localFallback) {
        return $localFallback
    }

    # if nothing found
    return $null
}
