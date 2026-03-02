Param(
    [string]$imageSourceFolder = "./inputImages", # path to the images source folder
    [string]$magickPath = "magick", # command name or path to magick
    [string]$foregroundIconColor = "#BDC1FE", # color of the icon foreground
    [string]$backgroundIconColor = "#2E2F43", # color of the icon background
    [int]$borderRadius = 80, # border radius
    [float]$zoomScale = 1.6 # by how much the icon will be zoomed in
)

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

# get all images in the source folder
$images = Get-ChildItem -Path $imageSourceFolder -Filter "*.png" -File

# transform every image
foreach ($image in $images) {
    # get new name
    $sourceImageWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($image.Name)
    $sourceImageExtension = [System.IO.Path]::GetExtension($image.Name)
    $outputImage = Join-Path "./outputImages" "$sourceImageWithoutExtension`_result$sourceImageExtension"

    Write-Host "Processing: $($image.Name)..." -ForegroundColor Cyan

    # transform the image
    transformImage -sourceImage $image.FullName -outputImage $outputImage -magickPath $magickPath -foregroundIconColor $foregroundIconColor -backgroundIconColor $backgroundIconColor -borderRadius $borderRadius -zoomScale $zoomScale
}