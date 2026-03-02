Param()

# imports
. "$PSScriptRoot\utils.ps1"
. "$PSScriptRoot\transformImage.ps1"

# use helper to find magick
$magickPath = getMagickPath

if (-not $magickPath) {
    Write-Host "Error: ImageMagick not found in PATH or local folder." -ForegroundColor Red
    Write-Host "Please restart your IDE or check your installation."
    exit 1
}

# transform an image
$sourceImage = "./inputImages/test_icon_1.png"

# get new name
$sourceImageWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($sourceImage)
$sourceImageExtension = [System.IO.Path]::GetExtension($sourceImage)
$outputImage = Join-Path "./outputImages" "$sourceImageWithoutExtension`_result$sourceImageExtension"

transformImage -sourceImage $sourceImage -outputImage $outputImage -magickPath $magickPath