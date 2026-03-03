function Invoke-TransformImage {
    Param(
        [Parameter(Mandatory = $true)]
        [string]$SourceImage, # path to the source image

        [Parameter(Mandatory = $true)]
        [string]$OutputImage, # path to the output image

        [Parameter(Mandatory = $true)]
        [string]$MagickPath, # command name or path to magick

        [Parameter(Mandatory = $true)]
        [string]$ForegroundIconColor, # color of the icon foreground

        [Parameter(Mandatory = $true)]
        [string]$BackgroundIconColor, # color of the icon background

        [Parameter(Mandatory = $true)]
        [int]$BorderRadius, # border radius

        [Parameter(Mandatory = $true)]
        [float]$ZoomScale # by how much the icon will be zoomed in
    )

    $inPercentZoomScale = $ZoomScale * 100 # zoom scale in percent format
    $originalImageWidth = [int](& $MagickPath identify -format "%w" $SourceImage) # input image width
    $originalImageHeight = [int](& $MagickPath identify -format "%h" $SourceImage) # input image height

    # coordinates from where the image will be cropped after the zoom
    $cropX = [int](($originalImageWidth * $ZoomScale - $originalImageWidth) / 2) 
    $cropY = [int](($originalImageHeight * $ZoomScale - $originalImageHeight) / 2)

    $imageTransformArguments = @(
        # input image
        $SourceImage,

        # resize
        "-resize", "${inPercentZoomScale}%"
        
        # crop
        "-crop", "${originalImageWidth}x${originalImageHeight}+$cropX+$cropY"
        "+repage"
        
        # colorize foreground
        "-fill", $ForegroundIconColor,
        "-colorize", "100",
        
        # colorize background
        "-background", $BackgroundIconColor,
        "-flatten",
        
        # border radius
        "(", "+clone", "-alpha", "transparent", "-fill", "white", "-draw", "roundrectangle 0,0 %[fx:w],%[fx:h] $BorderRadius,$BorderRadius", ")",
        "-alpha", "set",
        "-compose", "DstIn",
        "-composite",
        
        # save the new image
        $OutputImage
    )

    # transform the image
    & $MagickPath $imageTransformArguments

    # check if the image has been created
    if (Test-Path $OutputImage) {
        Write-Host "image creation success : '$OutputImage'" -ForegroundColor Green
    }
    else {
        Write-Host "image creation failed" -ForegroundColor Red
    }
}

function Invoke-TransformImageBatch {
    Param(
        [Parameter(Mandatory = $true)]
        [string]$MagickPath,

        [Parameter(Mandatory = $true)]
        [string]$ForegroundIconColor,

        [Parameter(Mandatory = $true)]
        [string]$BackgroundIconColor,

        [Parameter(Mandatory = $true)]
        [int]$BorderRadius,

        [Parameter(Mandatory = $true)]
        [float]$ZoomScale,

        [Parameter(Mandatory = $true)]
        [boolean]$UseDefaultImages,

        [Parameter(Mandatory = $true)]
        [string]$projectRoot,

        [Parameter(Mandatory = $true)]
        [array]$Images
    )

    foreach ($image in $Images) {
        # get new name
        $sourceImageWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($image.Name)
        $sourceImageExtension = [System.IO.Path]::GetExtension($image.Name)

        Write-Host "image: $($image)"

        # get output image path based on the default flag
        if ($UseDefaultImages) {
            $outputImage = Join-Path "$projectRoot/assets/output-images/default" "$sourceImageWithoutExtension`_result$sourceImageExtension"
        }
        else {
            $outputImage = Join-Path "$projectRoot/assets/output-images/user" "$sourceImageWithoutExtension`_result$sourceImageExtension"
        }

        Write-Host "Processing: $($image.Name)..." -ForegroundColor Cyan

        # transform the image
        Invoke-TransformImage -SourceImage $image.FullName -OutputImage $outputImage -MagickPath $magickPath -ForegroundIconColor $foregroundIconColor -BackgroundIconColor $backgroundIconColor -BorderRadius $borderRadius -ZoomScale $ZoomScale
    }
}