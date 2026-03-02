Param(
    [string]$folder, # path to the images source folder
    [string]$fgColor = "#BDC1FE", # color of the icon foreground
    [string]$bgColor = "#2E2F43", # color of the icon background
    [int]$radius = 80, # border radius
    [float]$zoom = 1.6 # by how much the icon will be zoomed in
)

$projectRoot = Split-Path $PSScriptRoot -Parent # path to the project root

# path to the images source folder
if (-not $folder) {
    $folder = "$projectRoot/assets/inputImages"
}

$magickPath = "magick" # path to the magick executable

# imports
. "$projectRoot/src/utils.ps1"
. "$projectRoot/src/transformImage.ps1"

# use helper to find magick
$magickPath = getMagickPath

function startApp {
    Param(
        [string]$imageSourceFolder = $folder,
        [string]$foregroundIconColor = $fgColor,
        [string]$backgroundIconColor = $bgColor,
        [int]$borderRadius = $radius,
        [float]$zoomScale = $zoom
    )


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
        $outputImage = Join-Path "$projectRoot/assets/outputImages" "$sourceImageWithoutExtension`_result$sourceImageExtension"

        Write-Host "Processing: $($image.Name)..." -ForegroundColor Cyan

        # transform the image
        transformImage -sourceImage $image.FullName -outputImage $outputImage -magickPath $magickPath -foregroundIconColor $foregroundIconColor -backgroundIconColor $backgroundIconColor -borderRadius $borderRadius -zoomScale $zoomScale
    }

    Write-Host "All images processed."
}

# run the app if this file is not being imported (don't run if imported)
if ($MyInvocation.InvocationName -ne '.') {
    startApp
}