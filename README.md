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
.\main.ps1 .\your_icon.png
```