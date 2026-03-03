Param(
    [string]$List, # path to the list of installed apps on the phone
    [string]$FgColor = "#BDC1FE", # color of the icon foreground
    [string]$BgColor = "#2E2F43", # color of the icon background
    [int]$Radius = 80, # border Radius
    [float]$Zoom = 1.6, # by how much the icon will be zoomed in
    [string]$Folder # path to the images source folder
)

$projectRoot = Split-Path $PSScriptRoot -Parent # path to the project root

# path to the images source folder
if (-not $Folder) {
    $Folder = "$projectRoot/assets/input-images/default"
}

$magickPath = "magick" # path to the magick executable

# imports
. "$projectRoot/src/Utils.ps1"
. "$projectRoot/src/TransformImage.ps1"
. "$projectRoot/src/CleanAppList.ps1"

# use helper to find magick
$magickPath = Get-MagickPath

function Start-App {
    Param(
        [string]$RawAppList = $List,
        [string]$foregroundIconColor = $FgColor,
        [string]$backgroundIconColor = $BgColor,
        [int]$borderRadius = $Radius,
        [float]$ZoomScale = $Zoom,
        [string]$imageSourceFolder = $Folder
    )

    $CleanedAppList = Invoke-CleanAppList -RawAppList $RawAppList

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

        if ($imageSourceFolder -eq "$projectRoot/assets/input-images/default") {
            $outputImage = Join-Path "$projectRoot/assets/output-images/default" "$sourceImageWithoutExtension`_result$sourceImageExtension"
        }
        else {
            $outputImage = Join-Path "$projectRoot/assets/output-images/user" "$sourceImageWithoutExtension`_result$sourceImageExtension"
        }

        Write-Host "Processing: $($image.Name)..." -ForegroundColor Cyan

        # transform the image
        Invoke-TransformImage -sourceImage $image.FullName -outputImage $outputImage -magickPath $magickPath -foregroundIconColor $foregroundIconColor -backgroundIconColor $backgroundIconColor -borderRadius $borderRadius -zoomScale $ZoomScale
    }

    Write-Host "All images processed."
}

# run the app if this file is not being imported (don't run if imported)
if ($MyInvocation.InvocationName -ne '.') {
    Start-App
}