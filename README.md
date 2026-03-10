# .mtz ME3 Icon Pack Creator
Creates an .mtz theme file from app list that can be applied on Xiaomi devices.

## Prerequisites
This script requires **ImageMagick** to be installed on your system.
You can install it using [winget](https://docs.microsoft.com/en-us/windows/package-manager/winget/):
```powershell
winget install ImageMagick.ImageMagick
```
Or download it from the [official website](https://imagemagick.org/script/download.php).

## Usage
Run the script with the path to your source icon:

```powershell
.\src\Start-App.ps1 (parameters)
```

### Parameters
- `-List`: Path to the raw list of installed apps on the phone (NOTICE: if not specified, the default list is used)
- `-Dictionary`: Path to the dictionary that associated images with package names (NOTICE: if not specified, the default dictionary is used)
- `-IconBank`: Path to the folder containing the icons on which the program will search for the icons 
to use (NOTICE: if not specified, the default icon bank is used)
- `-FgColor`: Color of the icon foreground in hex format (e.g. #BDC1FE)
- `-BgColor`: Color of the icon background in hex format (e.g. #2E2F43)
- `-Radius`: Border Radius in pixels (e.g. 125)
- `-Zoom`: By how much the icon will be zoomed in (e.g. 1.6)
- `-Default`: Whether to use default images or user images (NOTICE: if true, the other parameters are ignored, and the default icon pack is created, intended for tests, not actual use)