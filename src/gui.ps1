$projectRoot = Split-Path $PSScriptRoot -Parent # path to the project root


. "$projectRoot/src/app.ps1" # import the main app

# load windows forms library
Add-Type -AssemblyName System.Windows.Forms

# create window
$form = New-Object System.Windows.Forms.Form
$form.Text = "Mon Interface PowerShell"
$form.Size = New-Object System.Drawing.Size(300, 200)

# temporary button
$bouton = New-Object System.Windows.Forms.Button
$bouton.Text = "Exécuter mon projet"
$bouton.Location = New-Object System.Drawing.Point(80, 60)
$bouton.Size = New-Object System.Drawing.Size(120, 40)

$bouton.Add_Click({
        startApp
    })

$form.Controls.Add($bouton)

$form.ShowDialog()