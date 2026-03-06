$projectRoot = Split-Path $PSScriptRoot -Parent # path to the project root


. "$projectRoot/src/Start-App.ps1" # import the main app

# load windows forms library
Add-Type -AssemblyName System.Windows.Forms

# create window
$form = New-Object System.Windows.Forms.Form
$form.Text = "temp text"
$form.Size = New-Object System.Drawing.Size(800, 600)

# temporary button
$button = New-Object System.Windows.Forms.Button
$button.Text = "launch app"
$button.Location = New-Object System.Drawing.Point(80, 60)
$button.Size = New-Object System.Drawing.Size(120, 40)

$button.Add_Click({
        Start-App
    })

$form.Controls.Add($button)

$form.ShowDialog()