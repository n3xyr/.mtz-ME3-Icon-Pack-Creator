Param(
    [string]$List, # path to the list of installed apps on the phone
    [string]$FgColor = "#BDC1FE", # color of the icon foreground
    [string]$BgColor = "#2E2F43", # color of the icon background
    [int]$Radius = 125, # border Radius
    [float]$Zoom = 1.6, # by how much the icon will be zoomed in
    [boolean]$Default = $false, # whether to use default images or user images
    [string]$Dictionary, # path to the dictionary that associated images with package names
    [string]$IconBank # path to the folder containing the icons on which the program will search for the icons to use
)

$projectRoot = Split-Path $PSScriptRoot -Parent # path to the project root

# imports
. "$projectRoot/src/Utils.ps1"
. "$projectRoot/src/TransformImage.ps1"
. "$projectRoot/src/CleanAppList.ps1"
. "$projectRoot/src/SelectImagesFromList.ps1"

$magickPath = Get-MagickPath # use helper to find magick

function Start-App {
    Param(
        [string]$RawAppList = $List,
        [string]$foregroundIconColor = $FgColor,
        [string]$backgroundIconColor = $BgColor,
        [int]$borderRadius = $Radius,
        [float]$ZoomScale = $Zoom,
        [boolean]$UseDefaultSettings = $Default,
        [string]$DictionaryPath = $Dictionary,
        [string]$IconBankPath = $IconBank
    )
    
    if (-not [string]::IsNullOrWhiteSpace($RawAppList)) {
        # process images with user list

        $cleanedAppList = "$projectRoot/data/user/clean-app-list.txt"
        $cleanedLines = Invoke-CleanAppList -RawAppList $RawAppList 
        $cleanedLines | Set-Content -Path $cleanedAppList -Encoding UTF8

        Invoke-SelectImagesFromList -AppListPath $cleanedAppList -DictionaryPath $DictionaryPath -IconBankPath $IconBankPath -DestFolder "$projectRoot/assets/user/input-images"
        $images = Get-ChildItem -Path "$projectRoot/assets/user/input-images" -Filter "*.png" -File
        
        Invoke-TransformImageBatch -MagickPath $magickPath -ForegroundIconColor $foregroundIconColor -BackgroundIconColor $backgroundIconColor -BorderRadius $borderRadius -ZoomScale $ZoomScale -UseDefaultImages $UseDefaultSettings -projectRoot $projectRoot -Images $images
    }
    elseif ($UseDefaultSettings) {
        # process images with default list

        $cleanedAppList = "$projectRoot/data/default/default-clean-app-list.txt"
        $cleanedLines = Invoke-CleanAppList -RawAppList "$projectRoot/data/default/default-raw-app-list.txt"
        $cleanedLines | Set-Content -Path $cleanedAppList -Encoding UTF8

        Invoke-SelectImagesFromList -AppListPath $cleanedAppList -DictionaryPath "$projectRoot/data/default/default-dictionary.xml" -IconBankPath "$projectRoot/data/default/default-icon-bank" -DestFolder "$projectRoot/assets/default/input-images"
        $images = Get-ChildItem -Path "$projectRoot/assets/default/input-images" -Filter "*.png" -File

        Invoke-TransformImageBatch -MagickPath $magickPath -ForegroundIconColor $foregroundIconColor -BackgroundIconColor $backgroundIconColor -BorderRadius $borderRadius -ZoomScale $ZoomScale -UseDefaultImages $UseDefaultSettings -projectRoot $projectRoot -Images $images
    }
    else {
        Write-Host "Error: App list is empty." -ForegroundColor Red
        exit 1
    }
    
    if (-not $magickPath) {
        Write-Host "Error: ImageMagick not found in PATH or local folder." -ForegroundColor Red
        Write-Host "Please restart your IDE or check your installation."
        exit 1
    }

    Write-Host "All images processed."

    # create the icon pack
    if ($UseDefaultSettings) {
        # compress the images
        Compress-Archive -Path "$projectRoot/assets/default/icons/*" -DestinationPath "$projectRoot/data/default/icons.zip" -Force

        # remove the .zip extension 
        Move-Item -Path "$projectRoot/data/default/icons.zip" -Destination "$projectRoot/data/default/icons" -Force

        # create the zip
        Compress-Archive -Path "$projectRoot/data/default/icons", "$projectRoot/data/default/default-description.xml" -DestinationPath "$projectRoot/data/default/ME3-Icon-Pack.zip" -Force

        # finish the icon pack
        Move-Item -Path "$projectRoot/data/default/ME3-Icon-Pack.zip" -Destination "$projectRoot/ME3-Icon-Pack.mtz" -Force

        # remove unnecessary files
        Remove-Item -Path "$projectRoot/data/default/icons" -Force
        Remove-Item -Path "$projectRoot/assets/default/icons/*" -Force
        Remove-Item -Path "$projectRoot/assets/default/input-images/*" -Force

    }
    else {
        # compress the images
        Compress-Archive -Path "$projectRoot/assets/user/icons/*" -DestinationPath "$projectRoot/data/user/icons.zip" -Force

        # remove the .zip extension 
        Move-Item -Path "$projectRoot/data/user/icons.zip" -Destination "$projectRoot/data/user/icons" -Force

        # create the zip
        Compress-Archive -Path "$projectRoot/data/user/icons", "$projectRoot/data/default/default-description.xml" -DestinationPath "$projectRoot/data/user/ME3-Icon-Pack.zip" -Force

        # finish the icon pack
        Move-Item -Path "$projectRoot/data/user/ME3-Icon-Pack.zip" -Destination "$projectRoot/ME3-Icon-Pack.mtz" -Force

        # remove unnecessary files
        Remove-Item -Path "$projectRoot/data/user/icons" -Force
        Remove-Item -Path "$projectRoot/assets/user/icons/*" -Force
        Remove-Item -Path "$projectRoot/assets/user/input-images/*" -Force
    }

}

# run the app if this file is not being imported (don't run if imported)
if ($MyInvocation.InvocationName -ne '.') {
    Start-App
}