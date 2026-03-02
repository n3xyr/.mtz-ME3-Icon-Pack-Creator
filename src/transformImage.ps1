function Invoke-TransformImage {
    Param(
        [Parameter(Mandatory = $true)]
        [string]$sourceImage, # path to the source image

        [Parameter(Mandatory = $true)]
        [string]$outputImage, # path to the output image

        [Parameter(Mandatory = $true)]
        [string]$magickPath, # command name or path to magick

        [Parameter(Mandatory = $true)]
        [string]$foregroundIconColor, # color of the icon foreground

        [Parameter(Mandatory = $true)]
        [string]$backgroundIconColor, # color of the icon background

        [Parameter(Mandatory = $true)]
        [int]$borderRadius, # border radius

        [Parameter(Mandatory = $true)]
        [float]$zoomScale # by how much the icon will be zoomed in
    )

    $inPercentZoomScale = $zoomScale * 100 # zoom scale in percent format
    $originalImageWidth = [int](& $magickPath identify -format "%w" $sourceImage) # input image width
    $originalImageHeight = [int](& $magickPath identify -format "%h" $sourceImage) # input image height

    # coordinates from where the image will be cropped after the zoom
    $cropX = [int](($originalImageWidth * $zoomScale - $originalImageWidth) / 2) 
    $cropY = [int](($originalImageHeight * $zoomScale - $originalImageHeight) / 2)

    $imageTransformArguments = @(
        # input image
        $sourceImage,

        # resize
        "-resize", "${inPercentZoomScale}%"
        
        # crop
        "-crop", "${originalImageWidth}x${originalImageHeight}+$cropX+$cropY"
        "+repage"
        
        # colorize foreground
        "-fill", $foregroundIconColor,
        "-colorize", "100",
        
        # colorize background
        "-background", $backgroundIconColor,
        "-flatten",
        
        # border radius
        "(", "+clone", "-alpha", "transparent", "-fill", "white", "-draw", "roundrectangle 0,0 %[fx:w],%[fx:h] $borderRadius,$borderRadius", ")",
        "-alpha", "set",
        "-compose", "DstIn",
        "-composite",
        
        # save the new image
        $outputImage
    )

    # transform the image
    & $magickPath $imageTransformArguments

    # check if the image has been created
    if (Test-Path $outputImage) {
        Write-Host "image creation success : '$outputImage'" -ForegroundColor Green
    }
    else {
        Write-Host "image creation failed" -ForegroundColor Red
    }
}