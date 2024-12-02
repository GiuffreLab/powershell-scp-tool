Add-Type -AssemblyName PresentationFramework

# Create the GUI window
[void][System.Reflection.Assembly]::LoadWithPartialName('System.Drawing')
[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')

$form = New-Object System.Windows.Forms.Form
$form.Text = "SCP File Transfer"
$form.Size = New-Object System.Drawing.Size(400, 500)
$form.StartPosition = "CenterScreen"

# SSH Key Section
$sshKeyGroupBox = New-Object System.Windows.Forms.GroupBox
$sshKeyGroupBox.Text = "SSH Key"
$sshKeyGroupBox.Location = New-Object System.Drawing.Point(10, 10)
$sshKeyGroupBox.Size = New-Object System.Drawing.Size(360, 60)

$sshKeyLabel = New-Object System.Windows.Forms.Label
$sshKeyLabel.Text = "Select the SSH Key:"
$sshKeyLabel.Location = New-Object System.Drawing.Point(10, 20)
$sshKeyGroupBox.Controls.Add($sshKeyLabel)

$sshKeyComboBox = New-Object System.Windows.Forms.ComboBox
$sshKeyComboBox.Location = New-Object System.Drawing.Point(150, 20)
$sshKeyComboBox.Size = New-Object System.Drawing.Size(200, 20)

# Populate the ComboBox with available SSH keys in the current directory
$scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$sshKeys = Get-ChildItem -Path $scriptPath -File
foreach ($key in $sshKeys) {
    $sshKeyComboBox.Items.Add($key.Name)
}
$sshKeyGroupBox.Controls.Add($sshKeyComboBox)

$form.Controls.Add($sshKeyGroupBox)

# Remote Username Section
$remoteUsernameGroupBox = New-Object System.Windows.Forms.GroupBox
$remoteUsernameGroupBox.Text = "Remote Username"
$remoteUsernameGroupBox.Location = New-Object System.Drawing.Point(10, 80)
$remoteUsernameGroupBox.Size = New-Object System.Drawing.Size(360, 60)

$remoteUsernameLabel = New-Object System.Windows.Forms.Label
$remoteUsernameLabel.Text = "Enter the remote username:"
$remoteUsernameLabel.Location = New-Object System.Drawing.Point(10, 20)
$remoteUsernameGroupBox.Controls.Add($remoteUsernameLabel)

$remoteUsernameTextBox = New-Object System.Windows.Forms.TextBox
$remoteUsernameTextBox.Location = New-Object System.Drawing.Point(150, 20)
$remoteUsernameTextBox.Size = New-Object System.Drawing.Size(200, 20)
$remoteUsernameGroupBox.Controls.Add($remoteUsernameTextBox)

$form.Controls.Add($remoteUsernameGroupBox)

# Remote IP Section
$remoteIPGroupBox = New-Object System.Windows.Forms.GroupBox
$remoteIPGroupBox.Text = "Remote IP Address"
$remoteIPGroupBox.Location = New-Object System.Drawing.Point(10, 150)
$remoteIPGroupBox.Size = New-Object System.Drawing.Size(360, 60)

$remoteIPLabel = New-Object System.Windows.Forms.Label
$remoteIPLabel.Text = "Enter the remote IP address:"
$remoteIPLabel.Location = New-Object System.Drawing.Point(10, 20)
$remoteIPGroupBox.Controls.Add($remoteIPLabel)

$remoteIPTextBox = New-Object System.Windows.Forms.TextBox
$remoteIPTextBox.Location = New-Object System.Drawing.Point(150, 20)
$remoteIPTextBox.Size = New-Object System.Drawing.Size(200, 20)
$remoteIPGroupBox.Controls.Add($remoteIPTextBox)

$form.Controls.Add($remoteIPGroupBox)

# Remote Folder Section
$remoteFolderGroupBox = New-Object System.Windows.Forms.GroupBox
$remoteFolderGroupBox.Text = "Remote Folder Path"
$remoteFolderGroupBox.Location = New-Object System.Drawing.Point(10, 220)
$remoteFolderGroupBox.Size = New-Object System.Drawing.Size(360, 60)

$remoteFolderLabel = New-Object System.Windows.Forms.Label
$remoteFolderLabel.Text = "Enter the remote folder path:"
$remoteFolderLabel.Location = New-Object System.Drawing.Point(10, 20)
$remoteFolderGroupBox.Controls.Add($remoteFolderLabel)

$remoteFolderTextBox = New-Object System.Windows.Forms.TextBox
$remoteFolderTextBox.Location = New-Object System.Drawing.Point(150, 20)
$remoteFolderTextBox.Size = New-Object System.Drawing.Size(200, 20)
$remoteFolderGroupBox.Controls.Add($remoteFolderTextBox)

$form.Controls.Add($remoteFolderGroupBox)

# File to Copy Section
$fileToCopyGroupBox = New-Object System.Windows.Forms.GroupBox
$fileToCopyGroupBox.Text = "Local File to Copy"
$fileToCopyGroupBox.Location = New-Object System.Drawing.Point(10, 290)
$fileToCopyGroupBox.Size = New-Object System.Drawing.Size(360, 60)

$fileToCopyLabel = New-Object System.Windows.Forms.Label
$fileToCopyLabel.Text = "Select the local file to copy:"
$fileToCopyLabel.Location = New-Object System.Drawing.Point(10, 20)
$fileToCopyGroupBox.Controls.Add($fileToCopyLabel)

$fileToCopyComboBox = New-Object System.Windows.Forms.ComboBox
$fileToCopyComboBox.Location = New-Object System.Drawing.Point(150, 20)
$fileToCopyComboBox.Size = New-Object System.Drawing.Size(200, 20)

# Populate the ComboBox with files in the current directory
$files = Get-ChildItem -Path $scriptPath -File
foreach ($file in $files) {
    $fileToCopyComboBox.Items.Add($file.Name)
}
$fileToCopyGroupBox.Controls.Add($fileToCopyComboBox)

$form.Controls.Add($fileToCopyGroupBox)

# Copy File Button
$copyButton = New-Object System.Windows.Forms.Button
$copyButton.Text = "Copy File"
$copyButton.Location = New-Object System.Drawing.Point(150, 400)
$copyButton.Add_Click({
    $selectedKey = $sshKeyComboBox.SelectedItem
    $remoteUsername = $remoteUsernameTextBox.Text
    $remoteIP = $remoteIPTextBox.Text
    $remoteFolder = $remoteFolderTextBox.Text
    $fileToCopy = $fileToCopyComboBox.SelectedItem

    if (-not $fileToCopy) {
        [System.Windows.Forms.MessageBox]::Show("No file selected for copying.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }

    $fileToCopyPath = Join-Path -Path $scriptPath -ChildPath $fileToCopy
    if (-not (Test-Path -Path $fileToCopyPath)) {
        [System.Windows.Forms.MessageBox]::Show("The specified file '$fileToCopyPath' does not exist.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }

    $scpCommand = "scp -i `"$selectedKey`" -o BatchMode=no -o StrictHostKeyChecking=no `"$fileToCopyPath`" $remoteUsername@${remoteIP}:`"$remoteFolder`""
    try {
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c", $scpCommand -NoNewWindow -Wait
        [System.Windows.Forms.MessageBox]::Show("File successfully copied to ${remoteIP}:${remoteFolder}", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show("Failed to copy file: $_", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
})
$form.Controls.Add($copyButton)

# Show the form
[void]$form.ShowDialog()
